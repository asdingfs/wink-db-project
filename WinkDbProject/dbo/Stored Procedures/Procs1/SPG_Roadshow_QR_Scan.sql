CREATE PROC [dbo].[SPG_Roadshow_QR_Scan]          
@customer_tokenid VARCHAR(255),                                       
@qrcode VARCHAR(50),
@ip_address varchar(30),
@GPS_location varchar(250)                                                                                                                 

AS
BEGIN 

DECLARE @auth_token VARCHAR(255)
DECLARE @RETURN_NO VARCHAR(10)
DECLARE @CUSTOMER_ID INT
DECLARE @LAST_SCANNED_TIME DATETIME
DECLARE @DATE_DIFF INT
DECLARE @SCAN_INTERVAL INT
DECLARE @SCAN_VALUE INT
DECLARE @CAMPAIGN_ID INT
DECLARE @BOOKING_ID INT
DECLARE @SMALL_IMAGE_URL VARCHAR(255)
DECLARE @SMALL_WEBSITE_URL VARCHAR(255)

DECLARE @CURRENT_DATETIME Datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT

DECLARE @QR_ScanInterval decimal(10,2)

DECLARE @last_station_code varchar(50)
DECLARE @current_station_code varchar(50)
DECLARE @last_station_qrCode varchar(50)
DECLARE  @LAST_SCANNED_TIME_Log  datetime 

DECLARE @Valid int 
DECLARE @Last_Active_ScanQR_Code varchar(50)
DECLARE @Last_Active_Scan_Time_log datetime
DECLARE @Last_Active_Station_Code varchar(50)

Declare @default_image_id int

Declare @winner varchar(250)
Declare @redemptionStatus varchar(5)
Declare @prize varchar(250)

DECLARE @locked_reason varchar(255)
DECLARE @locked_customer_id int 
DECLARE @admin_user_email_for_lock_account  varchar(255) 
DECLARE @row_count int = 0

SET @admin_user_email_for_lock_account = 'admin@winkwink.sg'

SET @Valid = 1

print (CAST(@CURRENT_DATETIME as time))

-- this small logo image is only for SimplyGo UOB MasterCard roadshow
set @default_image_id =302


If CAST(@CURRENT_DATETIME as time) > '00:00:00' 
   AND CAST(@CURRENT_DATETIME as time) <= '05:30:00'
   BEGIN
   print('Time')
   
	SELECT '0' as response_code, 'Invalid Scan' as response_message , 3 as timer_interval_second
		RETURN 
END-- END check time between 00:30 and 05:30



-- 2. Check Account Locked
    IF EXISTS (select 1 from customer where customer.auth_token = @customer_tokenid and status ='disable')
     BEGIN
   
	--SELECT '0' as response_code, 'Your account is locked. Please contact customer service.' as response_message , 3 as timer_interval_second
	SELECT '3' as response_code, 'Your account may be locked. No scanning allowed.' as response_message , 3 as timer_interval_second
		RETURN 
	END-- END

    Select @CUSTOMER_ID =customer_id from customer where customer.auth_token = @customer_tokenid and status ='enable'

	-- 3. Check Multiple Login

	IF NOT Exists (SELECT 1 FROM CUSTOMER WHERE auth_token = @customer_tokenid )

	BEGIN
			 SELECT '2' as response_code, 'Multiple logins not allowed' as response_message , 3 as timer_interval_second
			RETURN 
	END  

	--4.. Begin Daily Limit Checking	
	IF (Select COUNT(*) from customer_earned_points where customer_earned_points.customer_id = @CUSTOMER_ID
    	
    	 and CAST(customer_earned_points.created_at as Date) = CAST(@CURRENT_DATETIME as Date)
    	 )>=250
   		BEGIN
		SELECT '0' as response_code, 'Daily limit reached' as response_message , 3 as timer_interval_second
        RETURN 
        END  -- END check time between 00:30 and 05:30

   
   
-- 5.. Check and Blocking Running By Script 10 panel within 30 second
   
   IF (
(select COUNT(*) from customer_earned_points 
where customer_earned_points.customer_id =@CUSTOMER_ID
 and CAST (created_at as DATE) = CAST (@CURRENT_DATETIME as Date)
  Group by CAST (created_at as DATE)
  --Having DATEDIFF(second,MIN(created_at),MAX(created_at))<=3
  --
  )>10)
  BEGIN
  --Print ('Check script >10')
 IF ( (select DATEDIFF(second,MIN(created_at),MAX(created_at))
from (select top 10 * from customer_earned_points 
where customer_earned_points.customer_id =
   (Select customer.customer_id from customer where customer.auth_token = @customer_tokenid)
  and CAST (created_at as DATE) = CAST (@CURRENT_DATETIME as Date)
  
  order by earned_points_id desc

)a )<=30)


BEGIN
 --Print ('check scan within 30 second')

Update customer set customer.status = 'disable',
customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid

IF (@@ROWCOUNT>0)
BEGIN
	Insert into System_Log (customer_id, action_status,created_at,reason)
	Select customer.customer_id,
	'disable',@CURRENT_DATETIME,'Script Scanning'
	 from customer where customer.auth_token = @customer_tokenid


	 	-----INSERT INTO ACCOUNT FILTERING LOCK
			
			    Select @locked_customer_id = customer.customer_id from customer where customer.auth_token = @customer_tokenid
				set @locked_reason ='Script Scanning'
				 
			 EXEC Create_WINK_Account_Filtering @locked_customer_id,@locked_reason,@admin_user_email_for_lock_account
END
 SET @RETURN_NO='001' -- Invalid scan                          
	GOTO Err
END

END


--7. Block LBS Can not detected
IF NOT Exists (Select 1 from customer_earned_points as p where p.GPS_location not like '%detected%'
and cast(created_at as date ) =cast(@CURRENT_DATETIME as date ) and customer_id =@CUSTOMER_ID  )
 --08/10/2017
BEGIN
		IF EXISTS (
		select *
		from (
		select top 25  customer_id,GPS_location from customer_earned_points  
		where Cast(created_at as DATE) between  CAST (@CURRENT_DATETIME as date) and CAST (@CURRENT_DATETIME as date) 
		and customer_id =@CUSTOMER_ID
		order by created_at desc
		) as c
		where c.GPS_location like '%detected%'
		group by c.customer_id,c.GPS_location
		having COUNT(*)>=25)
		 BEGIN
				 Print ('Begin LBS')

				Update customer set customer.status = 'disable',
				customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid

				IF (@@ROWCOUNT>0)
				BEGIN
					Insert into System_Log (customer_id, action_status,created_at,reason)
					Select customer.customer_id,
					'disable',@CURRENT_DATETIME,'LBS'
					 from customer where customer.auth_token = @customer_tokenid

	          -----INSERT INTO ACCOUNT FILTERING LOCK
			
			    Select @locked_customer_id = customer.customer_id from customer where customer.auth_token = @customer_tokenid
				set @locked_reason ='LBS'
				 
			    EXEC Create_WINK_Account_Filtering @locked_customer_id,@locked_reason,@admin_user_email_for_lock_account
				
				END
				 SET @RETURN_NO='001' -- scan time is too frequent                           
					GOTO Err
				END

END
-- End LBS

--8. IP Address (52.74.3.233)
IF(@ip_address ='52.74.3.233')
BEGIN
		

		Update customer set customer.status = 'disable',
		customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid

		IF (@@ROWCOUNT>0)
		BEGIN
			Insert into System_Log (customer_id, action_status,created_at,reason)
			Select customer.customer_id,
			'disable',@CURRENT_DATETIME,'52.74.3.233'
			 from customer where customer.auth_token = @customer_tokenid

			    -----INSERT INTO ACCOUNT FILTERING LOCK
			
			    Select @locked_customer_id = customer.customer_id from customer where customer.auth_token = @customer_tokenid
				set @locked_reason ='52.74.3.233'
				 
			    EXEC Create_WINK_Account_Filtering @locked_customer_id,@locked_reason,@admin_user_email_for_lock_account

		END
		 SET @RETURN_NO='001' -- scan time is too frequent                           
			GOTO Err
END

--9. Scanning the same QR code using the same IP addresses within +- 30s
  declare @maxTime datetime;
  declare @minTime datetime;
  declare @otherCustomerId int;
  declare @triggeringWID varchar(10)


  SELECT @maxTime = DATEADD(SECOND, 30, @CURRENT_DATETIME);
  SELECT @minTime = DATEADD(SECOND, -30, @CURRENT_DATETIME);

  SELECT @otherCustomerId = customer_id FROM [winkwink].[dbo].[customer_earned_points] 
  where ip_address like @ip_address
  and customer_id !=@CUSTOMER_ID
  and qr_code = @qrcode
  and created_at between @minTime AND @maxTime


  IF (@otherCustomerId is not null)
  BEGIN

		SELECT @triggeringWID = WID from customer where customer.customer_id = @CUSTOMER_ID;


		Update customer set customer.status = 'disable',
		customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid;

		Update customer set customer.status = 'disable',
		customer.updated_at = @CURRENT_DATETIME where customer.customer_id= @otherCustomerId;

		IF (@@ROWCOUNT>0)
		BEGIN

			Set @locked_reason = 'Same IP-' + @triggeringWID

			Insert into System_Log (customer_id, action_status,created_at,reason)
			Select customer.customer_id,
			'disable',@CURRENT_DATETIME,@locked_reason
				from customer where customer.auth_token = @customer_tokenid

			-----INSERT INTO ACCOUNT FILTERING LOCK
			
			Select @locked_customer_id = customer.customer_id from customer where customer.auth_token = @customer_tokenid
	
				 
			EXEC Create_WINK_Account_Filtering @locked_customer_id,@locked_reason,@admin_user_email_for_lock_account;


			--For the other customer

			Insert into System_Log (customer_id, action_status,created_at,reason)
			Select customer.customer_id,
			'disable',@CURRENT_DATETIME,@locked_reason
				from customer where customer.customer_id = @otherCustomerId

			-----INSERT INTO ACCOUNT FILTERING LOCK
			
			EXEC Create_WINK_Account_Filtering @otherCustomerId,@locked_reason,@admin_user_email_for_lock_account

		END
		SET @RETURN_NO='001' -- scan time is too frequent                           
		GOTO Err
  END
-- END Same IP, same QR within +- 30s

-- End Safeguard----------------------------------------------------------------------------


--print('Global Asset For Special Asset')
SET @CAMPAIGN_ID =1 --- Set Default Global Campagin ID Testing
--SET @CAMPAIGN_ID =5 --- Set Default Global Campagin ID Live
		
SET @BOOKING_ID = 0 --- Set Default Booking ID
SELECT @SMALL_IMAGE_URL = small_image_name ,@SMALL_WEBSITE_URL = small_image_url FROM campaign_small_image WHERE CAMPAIGN_ID = @CAMPAIGN_ID
and id= @default_image_id;
--and small_image_status = '1'
		
SELECT @SCAN_INTERVAL=SCAN_INTERVAL, @SCAN_VALUE = SCAN_VALUE,@Valid = 1 FROM 
	asset_type_management WHERE
	QR_CODE_VALUE = @qrcode
	AND Lower(asset_type_management.asset_status) = '1';


	IF EXISTS(SELECT 1 FROM CUSTOMER WHERE auth_token = @customer_tokenid and customer.status='enable')                                                     
	
	BEGIN  -- 4.. Check customer is enable
	     

		 -- check if it's within the specific time frame 
		IF EXISTS (SELECT 1 FROM asset_type_management as s
			WHERE  s.qr_code_value = @qrcode
			AND s.asset_status = '1'  AND Lower(s.special_campaign) ='yes'
			AND 
			(
			Cast(@CURRENT_DATETIME as date) >= CAST(s.scan_start_date as date)
			AND 
			Cast(@CURRENT_DATETIME as date) <= CAST(s.scan_end_date as date)
			)
		)
		 		 
		 BEGIN

			IF(
				(CAST (@CURRENT_DATETIME as datetime) < '2019-04-02 09:59:59.000') 
				or 
				(CAST (@CURRENT_DATETIME as datetime) between '2019-04-03 20:01:00.000' and '2019-04-04 09:59:59.000')
				or
				(CAST (@CURRENT_DATETIME as datetime) > '2019-04-04 20:01:00.000') 
			)
			BEGIN
				SET @RETURN_NO='005' -- Invalid Scan                    
				GOTO Err
			END

			IF(
				(SELECT COUNT(*) from customer_earned_points 
				where qr_code like 'SPG_UOBMC_01%'
				) 
				< 1000 )
				BEGIN
					-----------Update Customer Scanned IP 
					Update customer set customer.ip_scanned = @ip_address ,customer.ip_address = @ip_address where customer_id=@CUSTOMER_ID

					--CHECK LAST SCANNED TIME 
			
					---------------- Start To Check Scan Interval------------------
					IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE = @qrcode)  
					BEGIN
						
						--print('007 ')
						SET @RETURN_NO='007' -- scan time is too frequent                           
						GOTO Err
						
					END
					ELSE
					BEGIN

						--UPATE CUSTOMER_BALANCE TABLE
						INSERT INTO CUSTOMER_EARNED_POINTS (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at,ip_address,GPS_location) VALUES
							(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME,@ip_address,@GPS_location)
				
						IF(@@ROWCOUNT>0)
						BEGIN
							IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
							BEGIN
								UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+@SCAN_VALUE 
									,total_scans = (SELECT total_scans FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+1
									WHERE CUSTOMER_ID =@CUSTOMER_ID;
								
									SET @RETURN_NO='000' -- SUCCESS                           
									GOTO Err
							END
							ELSE
							BEGIN
								INSERT INTO customer_balance 
									(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans)VALUES
									(@CUSTOMER_ID,@SCAN_VALUE,0,0,0,0,0,1) 
								IF(@@ROWCOUNT>0)
								BEGIN
									SET @RETURN_NO='000' -- SUCCESS                           
									GOTO Err
								END
								ELSE	
								BEGIN 
									SET @RETURN_NO='004' -- INSERT FAIL                         
									GOTO Err
								END
							END
						END
				
						ELSE
						BEGIN
							SET @RETURN_NO='004' -- INSERT FAIL                         
							GOTO Err
						END	
					END

				END

			ELSE
				BEGIN
				 -- there are already 1000 scans for today 
					SET @RETURN_NO='009' -- Max 50,000 points given out already           
					GOTO Err
				END
		
		END
		ELSE
		BEGIN
			SET @RETURN_NO='003'   -- INVALID QR CODE                        
			GOTO Err
		END
	
	END 
	ELSE -- Customer disable
	BEGIN
		SET @RETURN_NO='001'   -- Customer disable                     
		GOTO Err
	END
	
	
	Err:                                         
	IF @RETURN_NO='001' 
	                          
	BEGIN 
	     SELECT '3' as response_code, 'Your account may be locked. No scanning allowed.' as response_message , 3 as timer_interval_second

		RETURN                           
	END 
	ELSE IF @RETURN_NO='002' 
	BEGIN  
		SELECT '0' as response_code, Concat('Scan interval per code: ',@SCAN_INTERVAL,' hours') as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
		RETURN 
	END
	ELSE IF @RETURN_NO='003' 
	BEGIN  
		SELECT '0' as response_code, 'Invalid QR Code' as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
		RETURN 
	END
	ELSE IF @RETURN_NO='004' 
	BEGIN  
		SELECT '0' as response_code, 'Insert Fail' as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
		RETURN 
	END
	ELSE IF @RETURN_NO='005' 
	BEGIN  
		SELECT '0' as response_code, 'Invalid Scan' as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
		RETURN 
	END
	ELSE IF @RETURN_NO='006' 
	BEGIN  
		SELECT '0' as response_code, 'Please login-in again ' as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
		RETURN 
	END
	ELSE IF @RETURN_NO='007' -- Already scanned QR Code once
	BEGIN  
		SELECT '0' as response_code, 'Oops! You can only scan this QR Code once.' as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
		RETURN 
	END

	ELSE IF @RETURN_NO='008' -- Promo ended
	BEGIN  
		SELECT '0' as response_code, 'Promotion has ended. Thanks for participating!' as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
		RETURN 
	END

	ELSE IF @RETURN_NO='009' -- Max 50,000 points given out already
	BEGIN  
		SELECT '0' as response_code, 'All our WINK+ points have been given out. Tip: Start earning WINK+ points daily when you scan WINK+ QR Codes in SMRT stations.' as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
		RETURN 
	END
	ELSE IF @RETURN_NO='000' -- Congrats Message for successful scanning

	BEGIN 
	 SELECT '1' as response_code,'Congrats! You’ve earned 50 WINK+ points. Points will be credited directly to your WINK+ account.' as response_message, @SMALL_IMAGE_URL AS small_banner_url, @SCAN_VALUE as scan_value,@SMALL_WEBSITE_URL AS small_website_url
		, 3 as timer_interval_second,@default_image_id as image_id
		RETURN 
	END
	 
	
END