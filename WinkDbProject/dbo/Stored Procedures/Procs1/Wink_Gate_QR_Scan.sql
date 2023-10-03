
CREATE PROC [dbo].[Wink_Gate_QR_Scan]          
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
DECLARE @Valid int 
Declare @default_image_id int
DECLARE @admin_user_email_for_lock_account  varchar(255) 

SET @admin_user_email_for_lock_account = 'admin@winkwink.sg'

SET @Valid = 1

set @default_image_id = 481

if(@qrcode like 'RTSA_Event_%')
BEGIN
set @default_image_id = 481
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


	--IF EXISTS(SELECT 1 FROM CUSTOMER WHERE auth_token = @customer_tokenid and customer.status='enable')                                                     
	
	--BEGIN  -- 4.. Check customer is enable
	     

		 -- check if it's within the specific time frame 
		IF EXISTS (SELECT 1 FROM asset_type_management as s
		WHERE  s.qr_code_value = @qrcode
		AND s.asset_status = '1'  AND Lower(s.special_campaign) ='yes'
		AND 
		(
		Cast(@CURRENT_DATETIME as date) >= CAST(s.scan_start_date as date)
		AND 
		Cast(@CURRENT_DATETIME as date) <= CAST(s.scan_end_date as date)
		))
		 		 
		 BEGIN

				Update customer set customer.ip_scanned = @ip_address ,customer.ip_address = @ip_address where customer_id=@CUSTOMER_ID

				--CHECK LAST SCANNED TIME 				
				DECLARE @validScan int = 0;
				  IF NOT EXISTS (SELECT
					  1
					FROM CUSTOMER_EARNED_POINTS
					WHERE CUSTOMER_ID = @CUSTOMER_ID
					AND QR_CODE = @qrcode)
				  BEGIN
					SET @validScan = 1;
				  END

					IF (@validScan = 1)  
					BEGIN
						INSERT INTO CUSTOMER_EARNED_POINTS (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at,ip_address,GPS_location) VALUES
						(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME,@ip_address,@GPS_location)
						IF(@@ROWCOUNT>0)
						BEGIN
							IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
							BEGIN
								UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+@SCAN_VALUE 
									,total_scans = (SELECT total_scans FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+1
									WHERE CUSTOMER_ID =@CUSTOMER_ID;

								SET @RETURN_NO='000' -- survey                           
								GOTO Err
								
							END
							ELSE
							BEGIN
								INSERT INTO customer_balance 
									(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans)VALUES
									(@CUSTOMER_ID,@SCAN_VALUE,0,0,0,0,0,1) 
								IF (@@ROWCOUNT>0)
								BEGIN
									SET @RETURN_NO='000' -- success                        
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
					ELSE
					BEGIN

						SET @RETURN_NO='007' -- already scanned once                    
						GOTO Err
				
					END
				END
				
		ELSE
		BEGIN
			SET @RETURN_NO='003'   -- INVALID QR CODE --                       
			GOTO Err
		END
		

	
	
	Err:                                         
	IF @RETURN_NO='001' 
	                          
	BEGIN 
	     SELECT '3' as response_code, 'Your account may be locked. No scanning allowed.' as response_message , 3 as timer_interval_second

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
	ELSE IF @RETURN_NO='007' -- Already scanned QR Code once
	BEGIN  
		SELECT '0' as response_code, 'Oops! You can only scan this QR Code once.' as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
		RETURN 
	END
	ELSE IF @RETURN_NO='000' -- success
	BEGIN
		DECLARE @successMsg varchar(150);

		if(@qrcode like 'RTSA_Event_%')
		BEGIN
		SET @successMsg = 'Head over to RTS wink+ gates';
		END
		ELSE
		BEGIN
			SET @successMsg = 'Head over to WINK+ gates';
		END

		SELECT '1' as response_code,@successMsg as response_message, @SMALL_IMAGE_URL AS small_banner_url, @SCAN_VALUE as scan_value,@SMALL_WEBSITE_URL AS small_website_url
		, 3 as timer_interval_second,@default_image_id as image_id
		RETURN 
	END
	
END
