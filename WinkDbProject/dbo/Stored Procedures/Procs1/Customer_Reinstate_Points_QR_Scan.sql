CREATE PROC [dbo].[Customer_Reinstate_Points_QR_Scan]
@customer_tokenid VARCHAR(255),
@cid VARCHAR(255),                                    
@qrcode VARCHAR(50),
@ip_address VARCHAR(30),
@GPS_location VARCHAR(250)

AS
BEGIN 
DECLARE @RETURN_NO VARCHAR(10)
DECLARE @CUSTOMER_ID INT
DECLARE @SCAN_INTERVAL INT
DECLARE @SCAN_VALUE INT
DECLARE @CAMPAIGN_ID INT
DECLARE @BOOKING_ID INT
DECLARE @MERCHANT_ID INT
DECLARE @SMALL_IMAGE_URL VARCHAR(255)
DECLARE @SMALL_WEBSITE_URL VARCHAR(255)
DECLARE @success_msg VARCHAR(255)
DECLARE @attempt_failed_msg VARCHAR(255)
DECLARE @invalid_msg VARCHAR(255)
-- GET LOCAL TIME
DECLARE @CURRENT_DATETIME datetimeoffset = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');

DECLARE @CURRENT_SINGAPORE_TIME DATETIME
DECLARE @Valid int 

DECLARE @default_image_id int
DECLARE @total_scan_limit int
DECLARE @scanLimit int

--Reinstate Points
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_SINGAPORE_TIME output

-- Set WB image
set @default_image_id =5

-- Set QR Scan limit to ONCE ONLY
SET @scanLimit = 1;

-- Start Safeguard

SELECT @CUSTOMER_ID =customer_id FROM customer WHERE customer.auth_token = @customer_tokenid AND status ='enable'

IF (@CUSTOMER_ID != @cid)
	BEGIN
		SET @RETURN_NO='310' -- invalid user
	GOTO ERR
END

-- 2. Check Account Locked
    IF (@CUSTOMER_ID = 0 or @CUSTOMER_ID ='' or @CUSTOMER_ID is null)
     BEGIN
   
	 SELECT '0' as response_code, 'Your account is locked. Please contact customer service.' as response_message , 3 as timer_interval_second
		RETURN 
	END-- END

-- 3. Check Multiple Login

IF NOT Exists (SELECT 1 FROM CUSTOMER WHERE auth_token = @customer_tokenid )

BEGIN
	     SELECT '2' as response_code, 'Multiple logins not allowed' as response_message , 3 as timer_interval_second
        RETURN 
END  

--7. Block LBS Can not detected

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
		END
		 SET @RETURN_NO='001' -- scan time is too frequent                           
			GOTO Err
		END

-- End LBS

--8. IP Address (52.74.3.233)
IF(@ip_address ='52.74.3.233')
BEGIN
		 Print ('Begin LBS')

		Update customer set customer.status = 'disable',
		customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid

		IF (@@ROWCOUNT>0)
		BEGIN
			Insert into System_Log (customer_id, action_status,created_at,reason)
			Select customer.customer_id,
			'disable',@CURRENT_DATETIME,'52.74.3.233'
			 from customer where customer.auth_token = @customer_tokenid
		END
		 SET @RETURN_NO='001' -- scan time is too frequent                           
			GOTO Err
END

-- End Safeguard----------------------------------------------------------------------------


	IF EXISTS(SELECT 1 FROM CUSTOMER WHERE auth_token = @customer_tokenid and customer.status='enable')                                                     
	
	BEGIN  -- 4.. Check customer is enable
	     -----------Update Customer Scanned IP 
	     Update customer set customer.ip_scanned = @ip_address ,customer.ip_address = @ip_address where customer_id=@CUSTOMER_ID
	
	     -- Asset is Booked ?
	     IF EXISTS (SELECT ASSET_MANAGEMENT_BOOKING.booking_id FROM ASSET_MANAGEMENT_BOOKING WHERE CONVERT(CHAR(10),@CURRENT_DATETIME,111) >= CONVERT(CHAR(10),START_DATE,111) and CONVERT(CHAR(10),@CURRENT_DATETIME,111) <= CONVERT(CHAR(10),END_DATE,111) AND QR_CODE_VALUE = @qrcode
		AND Lower(asset_management_booking.booked_status) = 'true')
		
		BEGIN
		
			SELECT @CAMPAIGN_ID = asmb.CAMPAIGN_ID,@BOOKING_ID= BOOKING_ID ,
			@SCAN_INTERVAL=SCAN_INTERVAL,
		    @SCAN_VALUE = SCAN_VALUE,
		    @SMALL_IMAGE_URL = m.small_image_name,
		    @SMALL_WEBSITE_URL =m.small_image_url
			FROM 
			ASSET_MANAGEMENT_BOOKING as asmb,
			campaign_small_image as m
			 WHERE CONVERT(CHAR(10),@CURRENT_DATETIME,111) 
			BETWEEN CONVERT(CHAR(10),START_DATE,111) and CONVERT(CHAR(10),END_DATE,111) 
			AND QR_CODE_VALUE = @qrcode
			AND Lower(asmb.booked_status) = 'true'
			AND m.campaign_id = asmb.campaign_id
			AND m.id = asmb.image_id

			print (@CAMPAIGN_ID)
			print (@BOOKING_ID)
	
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
		
		print('Global Asset')
		
		SET @CAMPAIGN_ID =1 --- Set Default Global Campagin ID Testing
		--SET @CAMPAIGN_ID =5 --- Set Default Global Campagin ID Live
		
		SET @BOOKING_ID = 0 --- Set Default Booking ID
		
		SELECT @SMALL_IMAGE_URL = small_image_name ,@SMALL_WEBSITE_URL = small_image_url FROM campaign_small_image WHERE id= @default_image_id
		--and small_image_status = '1'
		
        SELECT @SCAN_INTERVAL=SCAN_INTERVAL, @SCAN_VALUE = SCAN_VALUE,@Valid = 1 FROM 
			asset_type_management WHERE
		    QR_CODE_VALUE = @qrcode
			AND Lower(asset_type_management.asset_status) = '1'
			
			print('@SMALL_IMAGE_URL')
			print(@SMALL_IMAGE_URL)
					
		END
		ELSE IF EXISTS (SELECT 1 FROM asset_type_management as s
		WHERE  s.qr_code_value = @qrcode
		AND s.asset_status = '1'  AND Lower(s.special_campaign) ='yes'
		AND 
		(
		CONVERT(CHAR(10),@CURRENT_DATETIME,111) 
			BETWEEN CAST(s.scan_start_date as Date) and CAST(s.scan_end_date as Date)
		))
		 		 
		 BEGIN
		 print('Global Asset For Special Asset')
		SET @CAMPAIGN_ID =1 --- Set Default Global Campagin ID Testing
		--SET @CAMPAIGN_ID =5 --- Set Default Global Campagin ID Live
		
		SET @BOOKING_ID = 0 --- Set Default Booking ID
		SELECT @SMALL_IMAGE_URL = small_image_name ,@SMALL_WEBSITE_URL = small_image_url FROM campaign_small_image WHERE id= @default_image_id
		--and small_image_status = '1'
		
        SELECT @SCAN_INTERVAL=SCAN_INTERVAL, @SCAN_VALUE = SCAN_VALUE,@Valid = 1 FROM 
			asset_type_management WHERE
		    QR_CODE_VALUE = @qrcode
			AND Lower(asset_type_management.asset_status) = '1'
			
			print('@SMALL_IMAGE_URL')
			print(@SMALL_IMAGE_URL)
		 
		 END
		
		ELSE
		
		BEGIN
		
			/******************************************************/
			SET @RETURN_NO='003'   -- INVALID QR CODE                        
			GOTO Err
		END    
		
			
	   SELECT @MERCHANT_ID = MERCHANT_ID ,@total_scan_limit = ISNULL(scan_limit,0) FROM CAMPAIGN WHERE CAMPAIGN_ID = @CAMPAIGN_ID

			-- Insert into log mdf 5-05-2016
			EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_SINGAPORE_TIME output	
			
			INSERT INTO CUSTOMER_EARNED_POINTS_Log (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at) VALUES
					(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_SINGAPORE_TIME,@qrcode,@CURRENT_SINGAPORE_TIME)		
					
			
			--CHECK LAST SCANNED TIME 
			if ((SELECT count(*) from customer_earned_points where customer_id = @CUSTOMER_ID AND qr_code = @qrcode ) = @scanLimit)
			BEGIN
				
				SET @RETURN_NO='302' -- scan time is too frequent                           
				GOTO Err


			END
			ELSE
			BEGIN

			    -- Scan_Limit (04/04/2017)
				print ('-----------scan limit ----------')
				print(@total_scan_limit)

					if(@total_scan_limit>0 and 
					@total_scan_limit <= (select count(*) from customer_earned_points where campaign_id = @CAMPAIGN_ID)
					)
					BEGIN
					print ('-----------scan limit ----------')
				print(@total_scan_limit)
					update asset_management_booking set booked_status = 'FALSE' where campaign_id = @CAMPAIGN_ID
					SET @CAMPAIGN_ID = 5
					SET @BOOKING_ID =0

					END
		
				
-- Reinstate Point
if ((SELECT count(*) from customer_earned_points where customer_id = @CUSTOMER_ID AND qr_code = @qrcode ) < @scanLimit)
BEGIN

	INSERT INTO CUSTOMER_EARNED_POINTS (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at,ip_address,GPS_location) VALUES
					(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME,@ip_address,@GPS_location)
					

END

	
				IF(@@ROWCOUNT>0)
				BEGIN
					IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
					BEGIN
						UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+@SCAN_VALUE 
							,total_scans = (SELECT total_scans FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+1
							WHERE CUSTOMER_ID =@CUSTOMER_ID
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
			--CHECK LAST SCANNED TIME 
	     
	     
	     
	
	END 
	ELSE -- Customer disable
	BEGIN
		SET @RETURN_NO='006'   -- Customer disable                     
		GOTO Err
	END
	


--Err
	
	Err:                                         
	IF @RETURN_NO='001' 
	                          
	BEGIN                                              
		SELECT '0' as response_code, 'Invalid Scan' as response_message , 3 as timer_interval_second
		--SELECT '0' as response_code, 'Invalid Scan' as response_message 
		RETURN                           
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
	ELSE IF @RETURN_NO='006' 
	BEGIN  
		SELECT '0' as response_code, 'Please login-in again ' as response_message , 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='000' 
	BEGIN  
		SELECT '1' as response_code, 'Thank you for scanning. ' + CONVERT(varchar(12),@SCAN_VALUE) + ' WINK+ points will be credited to your WINK+ account.' as response_message, @SMALL_IMAGE_URL AS small_banner_url, @SCAN_VALUE as scan_value,@SMALL_WEBSITE_URL AS small_website_url
		, 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='302' -- Already participated 
	BEGIN  
		--SET @SMALL_IMAGE_URL = ''
		SELECT '0' as response_code, 'Thank you for scanning. You have already claimed your points.' as response_message , 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='310' -- Invalid User for Lucky Draw Prize
	BEGIN  
		SELECT '0' as response_code, 'Sorry you are not eligible to scan this code.' as response_message , 3 as timer_interval_second
		RETURN 
	END

END
