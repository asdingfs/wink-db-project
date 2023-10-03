CREATE PROC [dbo].[Get_Scan_Points_GPSLocation_NewLogic]          
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
DECLARE @MERCHANT_ID INT
DECLARE @SMALL_IMAGE_URL VARCHAR(255)
DECLARE @SMALL_WEBSITE_URL VARCHAR(255)
-- GET LOCAL TIME
--DECLARE @CURRENT_DATETIME datetimeoffset = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');

DECLARE @CURRENT_DATETIME Datetime
DECLARE @CURRENT_SINGAPORE_TIME Datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_SINGAPORE_TIME output	

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
Declare @total_scan_limit int 


declare @noOfDays int
declare @maxWinnerCount int
declare @luckyNum int
declare @pastWinnerCount int
declare @successMsg varchar(200)
set @successMsg = 'Success';

DECLARE @locked_reason varchar(255)
DECLARE @locked_customer_id int 
DECLARE @admin_user_email_for_lock_account  varchar(255) 


SET @admin_user_email_for_lock_account = 'admin@winkwink.sg'

SET @Valid = 1

------Testing --------
--- Set Default Pop Up image

set @default_image_id =62
if(@qrcode like '%PSD%' OR @qrcode like '%iView%' )
BEGIN
set @default_image_id =5
END
else if(@qrcode like '%SMRTDay2022_QR_WelcomeSMRTDay_01_34037%')
BEGIN
set @default_image_id =506		
END
--- Town Hall Dhoby Gaut 2023 & Town Hall Paya Lebar 2023 --- 
else if(@qrcode = 'Townhall_TownHallDhobyGhaut2023_01_34060' or @qrcode = 'Townhall_TownHallPayaLebar2023_02_34061')
BEGIN
set @default_image_id =551		
END


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
    	 )>=150
   		BEGIN
		SELECT '0' as response_code, 'Daily limit reached' as response_message , 3 as timer_interval_second
        RETURN 
        END  -- END check time between 00:30 and 05:30

   
   
-- 5.. Check and Blocking Running By Script 10 panel within 30 second
   
--   IF (
--(select COUNT(*) from customer_earned_points 
--where customer_earned_points.customer_id =@CUSTOMER_ID
-- and CAST (created_at as DATE) = CAST (@CURRENT_DATETIME as Date)
--  Group by CAST (created_at as DATE)
--  --Having DATEDIFF(second,MIN(created_at),MAX(created_at))<=3
--  --
--  )>10)
--  BEGIN
--  --Print ('Check script >10')
-- IF ( (select DATEDIFF(second,MIN(created_at),MAX(created_at))
--from (select top 10 * from customer_earned_points 
--where customer_earned_points.customer_id =
--   (Select customer.customer_id from customer where customer.auth_token = @customer_tokenid)
--  and CAST (created_at as DATE) = CAST (@CURRENT_DATETIME as Date)
  
--  order by earned_points_id desc

--)a )<=30)


--BEGIN
-- --Print ('check scan within 30 second')

--Update customer set customer.status = 'disable',
--customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid

--IF (@@ROWCOUNT>0)
--BEGIN
--	Insert into System_Log (customer_id, action_status,created_at,reason)
--	Select customer.customer_id,
--	'disable',@CURRENT_DATETIME,'Script Scanning'
--	 from customer where customer.auth_token = @customer_tokenid

	 
--	 	-----INSERT INTO ACCOUNT FILTERING LOCK
			
--			    Select @locked_customer_id = customer.customer_id from customer where customer.auth_token = @customer_tokenid
--				set @locked_reason ='Script Scanning'
				 
--			    EXEC Create_WINK_Account_Filtering @locked_customer_id,@locked_reason,@admin_user_email_for_lock_account


--END
-- SET @RETURN_NO='001' -- Invalid scan                          
--	GOTO Err
--END

--END


--6. Check and Blocking Same Train Scan Count <= 15
--IF( (select SUBSTRING ( @qrcode, 1 , 5)) = 'Train') 
 
-- BEGIN
   
--   IF (
--(select COUNT(*)+1 from customer_earned_points 
--where 
--customer_earned_points.customer_id =   (Select customer.customer_id from customer where customer.auth_token = @customer_tokenid)
--AND  (select SUBSTRING ( @qrcode, 1 , 9) ) = SUBSTRING ( qr_code, 1, 9 )
--  and CAST (created_at as DATE) = CAST (@CURRENT_DATETIME as Date)) >= 128
--  )

--		 BEGIN
--		 Print ('Begin Train 2')

--		Update customer set customer.status = 'disable',
--		customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid

--		IF (@@ROWCOUNT>0)
--		BEGIN
--			Insert into System_Log (customer_id, action_status,created_at,reason)
--			Select customer.customer_id,
--			'disable',@CURRENT_DATETIME,'Same Train Scan Count >= 72'
--			 from customer where customer.auth_token = @customer_tokenid

			 
--	 	-----INSERT INTO ACCOUNT FILTERING LOCK
			
--			    Select @locked_customer_id = customer.customer_id from customer where customer.auth_token = @customer_tokenid
--				set @locked_reason ='Same Train Scan'
				 
--			    EXEC Create_WINK_Account_Filtering @locked_customer_id,@locked_reason,@admin_user_email_for_lock_account


--		END
--		 SET @RETURN_NO='001' -- scan time is too frequent                           
--			GOTO Err
--		END


--END
--END Train

--7. Block LBS Can not detected
--IF NOT Exists (Select 1 from customer_earned_points as p where p.GPS_location not like '%detected%'
--and cast(created_at as date ) =cast(@CURRENT_DATETIME as date ) and customer_id =@CUSTOMER_ID  )
-- --08/10/2017
--BEGIN
--		IF EXISTS (
--		select *
--		from (
--		select top 25 customer_id,GPS_location from customer_earned_points  
--		where Cast(created_at as DATE) between  CAST (@CURRENT_DATETIME as date) and CAST (@CURRENT_DATETIME as date) 
--		and customer_id =@CUSTOMER_ID
--		order by created_at desc
--		) as c
--		where c.GPS_location like '%detected%'
--		group by c.customer_id,c.GPS_location
--		having COUNT(*)>=25)
--		BEGIN
--			Print ('Begin LBS')
--			--IF (@@ROWCOUNT>0)
--			--BEGIN
--			IF NOT EXISTS (
--				SELECT 1 from wink_account_filtering 
--				where customer_id =@customer_id 
--				and filtering_status = 'verified' 
--				AND reason like '%no location data received.%'
--				AND cast(created_at as date) = CAST (@CURRENT_DATETIME as date)
--			)BEGIN
--				Insert into System_Log (customer_id, action_status,created_at,reason)
--				values (@CUSTOMER_ID,
--					'disable',
--					@CURRENT_DATETIME,
--					'LBS');
			
--				-----INSERT INTO ACCOUNT FILTERING LOCK
			
--				Set @locked_reason = CONCAT('On ',cast(@CURRENT_DATETIME as date),', no location data received.');

--				-- 1 is verified. Do not need to return the error pop-up message
--				DECLARE @verified INT 
--				EXEC @verified = Create_LBS_AFM @CUSTOMER_ID, @locked_reason,@admin_user_email_for_lock_account 
--				--END
--				print(@verified)
--				if(@verified = 0)
--				BEGIN
--					SET @RETURN_NO='001'; -- account is locked due to LBS                    
--					GOTO Err
--				END

--			END
			
		
			
			
--		END

--END
-- End LBS

--8. IP Address (52.74.3.233)
--IF(@ip_address ='52.74.3.233')
--if (@ip_address = '52.74.3.233' or @ip_address = '103.83.122.171')
--BEGIN
--		 Print ('Begin block IP')

--		Update customer set customer.status = 'disable',
--		customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid

--		IF (@@ROWCOUNT>0)
--		BEGIN
--			Insert into System_Log (customer_id, action_status,created_at,reason)
--			Select customer.customer_id,
--			'disable',@CURRENT_DATETIME,@ip_address
--			 from customer where customer.auth_token = @customer_tokenid


--			 -----INSERT INTO ACCOUNT FILTERING LOCK
			
--			Select @locked_customer_id = customer.customer_id from customer where customer.auth_token = @customer_tokenid
--			set @locked_reason ='Blocked IP'
				 
--			EXEC Create_WINK_Account_Filtering @locked_customer_id,@locked_reason,@admin_user_email_for_lock_account

--		END
--		 SET @RETURN_NO='001' -- scan time is too frequent                           
--			GOTO Err
--END

--9. Scanning the same QR code using the same IP addresses within +- 30s
  --declare @maxTime datetime;
  --declare @minTime datetime;
  --declare @otherCustomerId int;
  --declare @triggeringWID varchar(10)


  --SELECT @maxTime = DATEADD(SECOND, 30, @CURRENT_DATETIME);
  --SELECT @minTime = DATEADD(SECOND, -30, @CURRENT_DATETIME);

  --SELECT @otherCustomerId = customer_id FROM [winkwink].[dbo].[customer_earned_points] 
  --where ip_address like @ip_address
  --and customer_id !=@CUSTOMER_ID
  --and qr_code = @qrcode
  --and created_at between @minTime AND @maxTime


  --IF (@otherCustomerId is not null)
  --BEGIN

		--SELECT @triggeringWID = WID from customer where customer.customer_id = @CUSTOMER_ID;


		--Update customer set customer.status = 'disable',
		--customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid;

		--Update customer set customer.status = 'disable',
		--customer.updated_at = @CURRENT_DATETIME where customer.customer_id= @otherCustomerId;

		--IF (@@ROWCOUNT>0)
		--BEGIN

		--	Set @locked_reason = 'Same IP-' + @triggeringWID

		--	Insert into System_Log (customer_id, action_status,created_at,reason)
		--	Select customer.customer_id,
		--	'disable',@CURRENT_DATETIME,@locked_reason
		--		from customer where customer.auth_token = @customer_tokenid

		--	-----INSERT INTO ACCOUNT FILTERING LOCK
			
		--	Select @locked_customer_id = customer.customer_id from customer where customer.auth_token = @customer_tokenid
	
				 
		--	EXEC Create_WINK_Account_Filtering @locked_customer_id,@locked_reason,@admin_user_email_for_lock_account;


		--	--For the other customer

		--	Insert into System_Log (customer_id, action_status,created_at,reason)
		--	Select customer.customer_id,
		--	'disable',@CURRENT_DATETIME,@locked_reason
		--		from customer where customer.customer_id = @otherCustomerId

		--	-----INSERT INTO ACCOUNT FILTERING LOCK
			
		--	EXEC Create_WINK_Account_Filtering @otherCustomerId,@locked_reason,@admin_user_email_for_lock_account

		--END
		--SET @RETURN_NO='001' -- scan time is too frequent                           
		--GOTO Err
  --END
-- END Same IP, same QR within +- 30s

-- 10. Time gap between scanning of two QR codes from different stations is less than 30s
--Declare @prevStnCode varchar(100)
--Declare @curStnCode varchar(100)
--Declare @prevCreatedAt datetime

--IF((SELECT special_campaign from asset_type_management where qr_code_value like @qrcode) like 'No'  AND @qrcode not like 'Train%' AND @qrcode not like '%VendingMachine%')
--BEGIN
--	SET @curStnCode = LEFT(@qrcode, 3);

--	Select TOP(1) @prevStnCode = qr_code, @prevCreatedAt = created_at FROM customer_earned_points
--	WHERE customer_id = @CUSTOMER_ID
--	AND qr_code not like 'Train%'
--	AND qr_code not like '%VendingMachine%'
--	AND qr_code in (
--		SELECT qr_code_value from [winkwink].[dbo].asset_type_management where special_campaign like 'No'
--	)
--	AND cast (created_at as date) = cast(@CURRENT_DATETIME as date)
--	order by created_at desc;

	
--	SET @prevStnCode = LEFT(@prevStnCode, 3);
	
--	IF(@prevStnCode != @curStnCode)
--	BEGIN	
--		IF(DATEDIFF(second,@prevCreatedAt, @CURRENT_DATETIME) < 30)
--		BEGIN			
--			print('shorter than 30s');

--			Update customer set customer.status = 'disable',
--			customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid;

--			IF (@@ROWCOUNT>0)
--			BEGIN
--				Set @locked_reason = 'Minute Lock ('+@qrcode+')';

--				Insert into System_Log (customer_id, action_status,created_at,reason)
--				Select customer.customer_id,
--				'disable',@CURRENT_DATETIME,@locked_reason
--					from customer where customer.auth_token = @customer_tokenid

--				-----INSERT INTO ACCOUNT FILTERING LOCK
			
--				Select @locked_customer_id = customer.customer_id from customer where customer.auth_token = @customer_tokenid;
--				EXEC Create_WINK_Account_Filtering @locked_customer_id,@locked_reason,@admin_user_email_for_lock_account;
--			END
--		END
--	END
--END


-- END Scanning codes from different stations within 30s

-- End Safeguard----------------------------------------------------------------------------


	--IF EXISTS(SELECT 1 FROM CUSTOMER WHERE auth_token = @customer_tokenid and customer.status='enable')                                                     
	
	--BEGIN  -- 4.. Check customer is enable
	     
	     
	    -- Set @CUSTOMER_ID = (select customer.customer_id from customer where customer.auth_token = @customer_tokenid) 
	     
	     -----------Update Customer Scanned IP 
	     Update customer set customer.ip_scanned = @ip_address ,customer.ip_address = @ip_address where customer_id=@CUSTOMER_ID
	
	     -- Asset is Booked ?
	     IF EXISTS (SELECT ASB.booking_id FROM ASSET_MANAGEMENT_BOOKING as ASB WHERE 
		 Cast(@CURRENT_DATETIME as date) >= Cast (ASB.start_date as date)
		 and 
		 Cast(@CURRENT_DATETIME as date) <= Cast (ASB.end_date as date)
		 and 
		 QR_CODE_VALUE = @qrcode
		 and 
		 Lower(ASB.booked_status) = 'true')
				
		BEGIN
		
			SELECT @CAMPAIGN_ID = asmb.CAMPAIGN_ID,@BOOKING_ID= BOOKING_ID ,
			@SCAN_INTERVAL=SCAN_INTERVAL,
		    @SCAN_VALUE = SCAN_VALUE,
		    @SMALL_IMAGE_URL = m.small_image_name,
		    @SMALL_WEBSITE_URL =m.small_image_url,
			@default_image_id =m.id
			FROM 
			ASSET_MANAGEMENT_BOOKING as asmb,
			campaign_small_image as m
			WHERE 
			Cast(@CURRENT_DATETIME as date) >= Cast (asmb.start_date as date)
		    AND 
		    Cast(@CURRENT_DATETIME as date) <= Cast (asmb.end_date as date)
			AND QR_CODE_VALUE = @qrcode
			AND Lower(asmb.booked_status) = 'true'
			AND m.campaign_id = asmb.campaign_id
			AND m.id = asmb.image_id

			--print (@CAMPAIGN_ID)
			--print (@BOOKING_ID)
	
		END
		ELSE IF EXISTS (SELECT 1 FROM asset_type_management as s
		WHERE  s.qr_code_value = @qrcode
		AND s.asset_status = '1'  AND Lower(s.special_campaign) !='yes'
		AND 
		(
		(scan_start_date is null OR  scan_start_date ='')
		 AND 
		 (scan_end_date is null or scan_end_date ='')
		 )
		 )
		
		
	 --- Global Asset
			BEGIN
		
		--print('Global Asset')
		
		SET @CAMPAIGN_ID =1 --- Set Default Global Campagin ID Testing
		--SET @CAMPAIGN_ID =5 --- Set Default Global Campagin ID Live
		
		SET @BOOKING_ID = 0 --- Set Default Booking ID
		
		SELECT @SMALL_IMAGE_URL = small_image_name ,@SMALL_WEBSITE_URL = small_image_url FROM campaign_small_image WHERE CAMPAIGN_ID = @CAMPAIGN_ID
		and id= @default_image_id
		--and small_image_status = '1'
		
        SELECT @SCAN_INTERVAL=SCAN_INTERVAL, @SCAN_VALUE = SCAN_VALUE,@Valid = 1 FROM 
			asset_type_management WHERE
		    QR_CODE_VALUE = @qrcode
			AND Lower(asset_type_management.asset_status) = '1';

			-- SimplyGo UOB Mastercard
			 IF(CAST(@CURRENT_DATETIME AS datetime)between '2019-05-27 05:30:00.000' AND '2019-09-04 23:59:59.000')
				BEGIN
					-- check if the user has already won for today
					IF NOT EXISTS(SELECT customer_id FROM spg_uob_mc where customer_id = @CUSTOMER_ID AND cast(created_at as date) = cast(@CURRENT_DATETIME as date))
					BEGIN
						SELECT @noOfDays = DATEDIFF(day, '2019-05-27', cast (@CURRENT_DATETIME as date));
						print('day difference: ');
						print(@noOfDays);

						SELECT @pastWinnerCount = COUNT(winner_id) FROM spg_uob_mc where cast(created_at as date) < cast(@CURRENT_DATETIME as date);
						print('past winner count: ');
						print(@pastWinnerCount);

						set @maxWinnerCount = @noOfDays * 5 - @pastWinnerCount +5;
						print('max winner count: ');
						print(@maxWinnerCount);

						IF( 
							(
								SELECT COUNT(winner_id) FROM spg_uob_mc where cast(created_at as date) = cast(@CURRENT_DATETIME as date)
							) 
							< @maxWinnerCount)
						BEGIN
							SELECT @luckyNum = ROUND(((17000 - 1 -1) * RAND() + 1), 0)
							print('lucky number: ');
							print(@luckyNum);

							IF(@luckyNum <= @maxWinnerCount)
							BEGIN
								SET @SCAN_VALUE = 500;
								print('won 500 points');
							END
						END

						
					END
					
				END			
			
					
		END
		
		---------------Global Asset For Special Asset-----------
		ELSE IF EXISTS (SELECT 1 FROM asset_type_management as s
		WHERE  s.qr_code_value = @qrcode
		AND s.asset_status = '1'  AND Lower(s.special_campaign) ='yes'
		AND 
		(
		Cast(@CURRENT_DATETIME as date) >= CAST(s.scan_start_date as Date)
		AND 
		Cast(@CURRENT_DATETIME as date) <= CAST(s.scan_end_date as Date)
		
		))
		 		 
		 BEGIN
		 --print('Global Asset For Special Asset')
		 SET @CAMPAIGN_ID =1 --- Set Default Global Campagin ID Testing
		--SET @CAMPAIGN_ID =5 --- Set Default Global Campagin ID Live
		
		SET @BOOKING_ID = 0 --- Set Default Booking ID
		SELECT @SMALL_IMAGE_URL = small_image_name ,@SMALL_WEBSITE_URL = small_image_url FROM campaign_small_image WHERE CAMPAIGN_ID = @CAMPAIGN_ID
		and id= @default_image_id
		--and small_image_status = '1'
		
        SELECT @SCAN_INTERVAL=SCAN_INTERVAL, @SCAN_VALUE = SCAN_VALUE,@Valid = 1 FROM 
			asset_type_management WHERE
		    QR_CODE_VALUE = @qrcode
			AND Lower(asset_type_management.asset_status) = '1'
			
			--print('@SMALL_IMAGE_URL')
			--print(@SMALL_IMAGE_URL)
		 
		 END
		
		ELSE
		
		BEGIN
		
			/******************************************************/
			SET @RETURN_NO='003'   -- INVALID QR CODE                        
			GOTO Err
		END    
		
			
	  -- SELECT @MERCHANT_ID = MERCHANT_ID ,@total_scan_limit = ISNULL(scan_limit,0) FROM CAMPAIGN WHERE CAMPAIGN_ID = @CAMPAIGN_ID;
	  --Transaction BEGIN
	  	--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	  BEGIN TRANSACTION;
		SAVE TRANSACTION QrScanSavePoint;
	
		BEGIN TRY
		
			IF(@qrcode not like 'TL_Demo_01%'  and @qrcode not like 'GWAN_NAME%')
			BEGIN
				print('not TL code');
				--DBS LMBS 2.0 CityHall '2022-07-07 09:00:00.000' AND '2022-08-31 23:59:59.000')
				DECLARE @dbsStartDate datetime = '2022-06-23 09:00:00.000';
				DECLARE @dbsEndDate datetime = '2022-08-31 23:59:59.000';
				DECLARE @dbsCTHiView varchar(50) = 'CTH_iView_%';
				DECLARE @dbsPts int = 25
							
				IF(
					(@CURRENT_DATETIME BETWEEN @dbsStartDate AND @dbsEndDate)
					AND
					(@qrcode LIKE @dbsCTHiView AND @qrcode NOT LIKE 'CTH_iView_V05_%')
				)
				BEGIN
					print(@qrcode);

					--DECLARE @dbsInt int = 2;
					DECLARE @dbsInt int = 7888;
					IF(
						(SELECT COUNT(1)
						FROM CUSTOMER_EARNED_POINTS
						WHERE qr_code LIKE @dbsCTHiView
						AND (created_at BETWEEN  @dbsStartDate AND @dbsEndDate)
						AND points = @dbsPts
						)
						< @dbsInt)
					BEGIN
						print('DBS check exists');
						IF NOT EXISTS(
							SELECT 1
							FROM customer_earned_points
							WHERE qr_code LIKE @dbsCTHiView
							AND CAST(created_at AS DATE) = CAST(@CURRENT_DATETIME AS DATE)
							AND points = @dbsPts
							AND customer_id = @CUSTOMER_ID)
						BEGIN
							SET @SCAN_VALUE = @dbsPts;
							print('DBS points');
						END
					END
				END

				IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE = @qrcode  and (CAST(created_at AS date) = cast(@CURRENT_DATETIME as date)))  
				BEGIN
					SELECT TOP 1 @LAST_SCANNED_TIME = LAST_SCANNED_TIME FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE = @qrcode ORDER BY LAST_SCANNED_TIME DESC
					print('CHECK LAST SCANNED TIME ')
					--SELECT @DATE_DIFF = DATEDIFF(HOUR,@LAST_SCANNED_TIME,@CURRENT_DATETIME)+8
					SELECT @DATE_DIFF = DATEDIFF(HOUR,@LAST_SCANNED_TIME,@CURRENT_SINGAPORE_TIME)
					print('@DATE_DIFF')
					print(@DATE_DIFF);
					print (@SCAN_INTERVAL);

				
					IF (@DATE_DIFF < @SCAN_INTERVAL and @SCAN_INTERVAL !=24 and @SCAN_INTERVAL!=0)
					BEGIN
									     
						SET @RETURN_NO='002' -- scan time is too frequent                           
						--GOTO Err
					END
					ELSE
					BEGIN
						--- Check one day per scan
						print('Check one day per scan ')
						print (@CURRENT_SINGAPORE_TIME)
						IF  (@SCAN_INTERVAL=24) AND (Cast(@CURRENT_SINGAPORE_TIME as date) <= Cast (@LAST_SCANNED_TIME as date))
						BEGIN
							--print('007 ')
							SET @RETURN_NO='007' -- scan time is too frequent                           
							--GOTO Err
						END
						ELSE
						BEGIN
					
							-- spg uob mastercard winner
							/*
							IF(@SCAN_VALUE = 500)
							BEGIN
								INSERT INTO spg_uob_mc(customer_id,points,qr_code,created_at,GPS_location,ip_address) VALUES
								(@CUSTOMER_ID,@SCAN_VALUE,@qrcode,@CURRENT_DATETIME,@GPS_location,@ip_address);
					
							END
							*/
							
							INSERT INTO CUSTOMER_EARNED_POINTS (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at,ip_address,GPS_location) VALUES
								(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME,@ip_address,@GPS_location)
							IF(@@ROWCOUNT>0)
							BEGIN
								-- print ('-----------Insert earned points ----------')
								IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
								BEGIN
									UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = TOTAL_POINTS + @SCAN_VALUE 
									,total_scans = total_scans +1
									WHERE CUSTOMER_ID =@CUSTOMER_ID
									SET @RETURN_NO='000' -- SUCCESS                           
									--GOTO Err
								END
								ELSE
								BEGIN
									INSERT INTO customer_balance 
									(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans,total_redeemed_amt)VALUES
									(@CUSTOMER_ID,@SCAN_VALUE,0,0,0,0,0,1,0.00) 
									IF(@@ROWCOUNT>0)
									BEGIN
										SET @RETURN_NO='000' -- SUCCESS                           
										--GOTO Err
									END
									ELSE	
									BEGIN 
										SET @RETURN_NO='004' -- INSERT FAIL                         
										--GOTO Err
									END
								END

							END
					
							ELSE
							BEGIN
								SET @RETURN_NO='004' -- INSERT FAIL                         
								--GOTO Err
							END	
						END			
					END
				END
				ELSE
				BEGIN

					-- spg uob mastercard winner
					/*
					IF(@SCAN_VALUE = 500)
					BEGIN
						INSERT INTO spg_uob_mc(customer_id,points,qr_code,created_at,GPS_location,ip_address) VALUES
						(@CUSTOMER_ID,@SCAN_VALUE,@qrcode,@CURRENT_DATETIME,@GPS_location,@ip_address);
					END
					*/

					INSERT INTO CUSTOMER_EARNED_POINTS (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at,ip_address,GPS_location) VALUES
						(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME,@ip_address,@GPS_location)
				
					IF(@@ROWCOUNT>0)
					BEGIN
						IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
						BEGIN
							UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = TOTAL_POINTS + @SCAN_VALUE 
								,total_scans = total_scans + 1
								WHERE CUSTOMER_ID =@CUSTOMER_ID
							SET @RETURN_NO='000' -- SUCCESS                           
							--GOTO Err
						END
						ELSE
						BEGIN
							INSERT INTO customer_balance 
								(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans,total_redeemed_amt)VALUES
								(@CUSTOMER_ID,@SCAN_VALUE,0,0,0,0,0,1,0.00) 
							IF(@@ROWCOUNT>0)
							BEGIN
								SET @RETURN_NO='000' -- SUCCESS                           
								--GOTO Err
							END
							ELSE	
							BEGIN 
								SET @RETURN_NO='004' -- INSERT FAIL                         
								--GOTO Err
							END
						END

					
					END
				
					ELSE
					BEGIN
						SET @RETURN_NO='004' -- INSERT FAIL                         
						--GOTO Err
					END	
				END
			END
			ELSE IF @qrcode like 'TL_Demo_01%'
			BEGIN 
				IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'TL_Demo_01%')
				BEGIN
					SET @RETURN_NO='008'   -- INVALID QR CODE                        
					
				END
				ELSE
				BEGIN
					INSERT INTO CUSTOMER_EARNED_POINTS (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at,ip_address,GPS_location) VALUES
						(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME,@ip_address,@GPS_location)
				
					IF(@@ROWCOUNT>0)
					BEGIN
						IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
						BEGIN
							UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = TOTAL_POINTS + @SCAN_VALUE 
								,total_scans = total_scans + 1
								WHERE CUSTOMER_ID =@CUSTOMER_ID
							SET @RETURN_NO='000' -- SUCCESS                           
							--GOTO Err
						END
						ELSE
						BEGIN
							INSERT INTO customer_balance 
								(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans,total_redeemed_amt)VALUES
								(@CUSTOMER_ID,@SCAN_VALUE,0,0,0,0,0,1,0.00) 
							IF(@@ROWCOUNT>0)
							BEGIN
								SET @RETURN_NO='000' -- SUCCESS                           
								--GOTO Err
							END
							ELSE	
							BEGIN 
								SET @RETURN_NO='004' -- INSERT FAIL                         
								--GOTO Err
							END
						END

					
					END
				
					ELSE
					BEGIN
						SET @RETURN_NO='004' -- INSERT FAIL                         
						--GOTO Err
					END	
				END  
			END
			ELSE IF @qrcode like 'GWAN_NAME%'
			BEGIN 
			IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like @qrcode)
				BEGIN
					SET @RETURN_NO='008'   -- INVALID QR CODE                        
					
				END
				ELSE
				BEGIN
					INSERT INTO CUSTOMER_EARNED_POINTS (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at,ip_address,GPS_location) VALUES
						(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME,@ip_address,@GPS_location)
				
					IF(@@ROWCOUNT>0)
					BEGIN
						IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
						BEGIN
							UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = TOTAL_POINTS + @SCAN_VALUE 
								,total_scans = total_scans + 1
								WHERE CUSTOMER_ID =@CUSTOMER_ID
							SET @RETURN_NO='000' -- SUCCESS                           
							--GOTO Err
						END
						ELSE
						BEGIN
							INSERT INTO customer_balance 
								(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans,total_redeemed_amt)VALUES
								(@CUSTOMER_ID,@SCAN_VALUE,0,0,0,0,0,1,0.00) 
							IF(@@ROWCOUNT>0)
							BEGIN
								SET @RETURN_NO='000' -- SUCCESS                           
								--GOTO Err
							END
							ELSE	
							BEGIN 
								SET @RETURN_NO='004' -- INSERT FAIL                         
								--GOTO Err
							END
						END

					
					END
				
					ELSE
					BEGIN
						SET @RETURN_NO='004' -- INSERT FAIL                         
						--GOTO Err
					END	
				END  
	
			END
           
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION QrScanSavePoint
			END
			SET @RETURN_NO='005' -- INSERT FAIL 
		END CATCH
	 --Transaction END

	
	
	Err:                                         
	IF @RETURN_NO='001' 
	                          
	BEGIN 
	     SELECT '3' as response_code, 'Your account may be locked. No scanning allowed.' as response_message , 3 as timer_interval_second                                             
		---SELECT '0' as response_code, 'Invalid Scan' as response_message , 3 as timer_interval_second
		--SELECT '0' as response_code, 'Invalid Scan' as response_message  
		RETURN                           
	END 
	ELSE IF @RETURN_NO='002' 
	BEGIN  
		--SELECT '0' as response_code, 'Scan interval per code : 24 hours' as response_message , 3 as timer_interval_second
		IF @SCAN_INTERVAL = 1
		BEGIN
			SELECT '0' as response_code, Concat('Scan interval per code: ',@SCAN_INTERVAL,' hour') as response_message , 3 as timer_interval_second
			RETURN 
		END
		ELSE
		BEGIN
			SELECT '0' as response_code, Concat('Scan interval per code: ',@SCAN_INTERVAL,' hours') as response_message , 3 as timer_interval_second
			RETURN 
		END
	END
	ELSE IF @RETURN_NO='003' 
	BEGIN  
		SELECT '0' as response_code, 'Invalid QR Code' as response_message , 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='004' 
	BEGIN  
		SELECT '0' as response_code, 'Insert Fail' as response_message , 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='005' 
	BEGIN  
		SELECT '0' as response_code, 'Invalid Scan' as response_message , 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='006' 
	BEGIN  
		SELECT '0' as response_code, 'Please login-in again ' as response_message , 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='007' -- Update 24 hours can interval
	BEGIN  
		SELECT '0' as response_code, 'Scan interval: One scan per code per day' as response_message , 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='000' 
	BEGIN 

		IF(@qrcode like 'TL_Demo_01%')
		BEGIN
			set @successMsg = 'Hannah welcomes you!';
			set @SMALL_IMAGE_URL = 'hannah_banner_large.png';
			set @SMALL_WEBSITE_URL = 'https://www.facebook.com/winkwinksg/';
			set @default_image_id = 413;
		END
		ELSE IF(@SCAN_VALUE = 500)
		BEGIN
			set @successMsg = 'Congrats! It’s your lucky day! You’ve earned 500 WINK+ points credited directly to your WINK+ account.';
			set @SMALL_IMAGE_URL = 'SPG_UOBMC_Roadshow.jpg';
			set @SMALL_WEBSITE_URL = 'https://www.facebook.com/winkwinksg/';
			set @default_image_id = 302;
	   END
	   IF(@qrcode like 'GWAN_NAME%')
		BEGIN
			set @successMsg = 'Go to WINK+ PLAY to submit an entry and earn 25 points!';
			set @SMALL_IMAGE_URL = 'name_wink_popup.jpg';
			set @SMALL_WEBSITE_URL = 'https://www.facebook.com/winkwinksg/';
			set @default_image_id = 421;
		END
		/*
		 IF(@qrcode like '104_test_test%')
		BEGIN
			set @successMsg = 'Go to WINK+ PLAY to submit an entry and earn 25 points!';
			set @SMALL_IMAGE_URL = 'MB21_4911_Maybank_V2.jpg';
			set @SMALL_WEBSITE_URL = 'https://www.facebook.com/winkwinksg/';
			set @default_image_id = 421;
		END
		 */
		
	 
		SELECT '1' as response_code,@successMsg as response_message, @SMALL_IMAGE_URL AS small_banner_url, @SCAN_VALUE as scan_value,@SMALL_WEBSITE_URL AS small_website_url
		, 3 as timer_interval_second,@default_image_id as image_id, 'aa' as prize
		RETURN 
	END
	ELSE IF @RETURN_NO='008' -- Scan TL Demo QR again
	BEGIN  
		SELECT '0' as response_code, 'You have already scanned this QR code.' as response_message , 3 as timer_interval_second
		RETURN 
	END
END
