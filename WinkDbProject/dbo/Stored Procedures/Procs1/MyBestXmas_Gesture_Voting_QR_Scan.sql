CREATE PROC [dbo].[MyBestXmas_Gesture_Voting_QR_Scan]
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

	DECLARE @CURRENT_DATETIME Datetime
	DECLARE @CURRENT_SINGAPORE_TIME Datetime

	Exec GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_SINGAPORE_TIME output	

	DECLARE @QR_ScanInterval decimal(10,2)

	DECLARE @last_station_code varchar(50)
	DECLARE @current_station_code varchar(50)
	DECLARE @last_station_qrCode varchar(50)
	DECLARE @LAST_SCANNED_TIME_Log  datetime 

	DECLARE @Valid int 
	DECLARE @Last_Active_ScanQR_Code varchar(50)
	DECLARE @Last_Active_Scan_Time_log datetime
	DECLARE @Last_Active_Station_Code varchar(50)

	Declare @default_image_id int
	Declare @total_scan_limit int 

	declare @noOfDays int
	declare @maxWinnerCount int
	declare @luckyNum int
	--declare @pastWinnerCount int
	declare @successMsg varchar(200)
	set @successMsg = 'Success';

	DECLARE @locked_reason varchar(255)
	DECLARE @locked_customer_id int 
	DECLARE @admin_user_email_for_lock_account  varchar(255) 
	SET @admin_user_email_for_lock_account = 'system@winkwink.sg'

	SET @Valid = 1

	print (CAST(@CURRENT_DATETIME as time))
	--- Set Default Pop Up image
	set @default_image_id =66
   
	DECLARE @winkPlayCampaignId int = 174;
	DECLARE @totalPtsInventory int = 168000;
	DECLARE @campaignStart datetime = '2021-11-25 05:30:00.000';
	DECLARE @campaignEnd datetime = '2021-12-31 23:59:59.000';

	IF(CAST(@CURRENT_DATETIME as time) > '00:00:00' 
		AND CAST(@CURRENT_DATETIME as time) <= '05:30:00')
	BEGIN
		print('Time')
		SELECT '0' as response_code, 'Invalid Scan' as response_message , 3 as timer_interval_second
		RETURN 
	END-- END check time between 00:30 and 05:30

	-- 2. Check Account Locked
    IF EXISTS (select 1 from customer where customer.auth_token = @customer_tokenid and status ='disable')
    BEGIN
		SELECT '3' as response_code, 'Your account may be locked. No scanning allowed.' as response_message , 3 as timer_interval_second
		RETURN 
	END-- END

    Select @CUSTOMER_ID =customer_id from customer where customer.auth_token = @customer_tokenid and status ='enable'

	-- 3. Check Multiple Login

	IF NOT Exists (SELECT 1 FROM CUSTOMER WHERE auth_token = @customer_tokenid)
	BEGIN
		SELECT '2' as response_code, 'Multiple logins not allowed' as response_message , 3 as timer_interval_second
		RETURN 
	END  
 
	Update customer set customer.ip_scanned = @ip_address ,customer.ip_address = @ip_address where customer_id=@CUSTOMER_ID;
	
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
	))
	--- Global Asset
	BEGIN
		print('Global Asset')
		SET @CAMPAIGN_ID =1 --- Set Default Global Campagin ID Testing
		--SET @CAMPAIGN_ID =5 --- Set Default Global Campagin ID Live
		
		SET @BOOKING_ID = 0 --- Set Default Booking ID
		
		SELECT @SMALL_IMAGE_URL = small_image_name ,@SMALL_WEBSITE_URL = small_image_url FROM campaign_small_image WHERE CAMPAIGN_ID = @CAMPAIGN_ID
		and id= @default_image_id
		
		SELECT @SCAN_INTERVAL=SCAN_INTERVAL, @SCAN_VALUE = SCAN_VALUE,@Valid = 1 FROM 
		asset_type_management WHERE
		QR_CODE_VALUE = @qrcode
		AND Lower(asset_type_management.asset_status) = '1';

		-- MyBestXmas
		IF(CAST(@CURRENT_DATETIME AS datetime)between @campaignStart AND @campaignEnd)
		BEGIN
			-- check current inventory count (both gesture and wink play records)
			print('check for inventory');
			DECLARE @totalIssuedPts int = 0;

			select @totalIssuedPts= ISNULL(SUM(points),0)
			from (
				SELECT points FROM customer_earned_points 
				WHERE (qr_code like 'MBXMAS%' AND qr_code not like 'MBXMAS_WINK%')

				UNION ALL

				SELECT points FROM winktag_customer_earned_points
				WHERE campaign_id = @winkPlayCampaignId
			) as issuedPts;

			print('total points issued');
			print(@totalIssuedPts);
			IF(@totalPtsInventory > @totalIssuedPts)
			BEGIN
					SELECT @luckyNum = ROUND(((10 - 1 -1) * RAND() + 1), 0)
					print('lucky number: ');
					print(@luckyNum);

					IF(@luckyNum > 2)
					BEGIN
						SET @SCAN_VALUE = 5;
						print('won 5 points');
					END
					ELSE
					BEGIN
						SET @SCAN_VALUE = 20;
						print('won 20 points');
					END
			END
			ELSE
			BEGIN
				SET @RETURN_NO='001'   -- No more inventory left                       
				GOTO Err
			END
		END
		ELSE
		BEGIN
			SET @RETURN_NO='003'   -- INVALID QR CODE                        
			GOTO Err
		END
	END
	ELSE
	BEGIN
		/******************************************************/
		SET @RETURN_NO='003'   -- INVALID QR CODE                        
		GOTO Err
	END    	
	  -- SELECT @MERCHANT_ID = MERCHANT_ID ,@total_scan_limit = ISNULL(scan_limit,0) FROM CAMPAIGN WHERE CAMPAIGN_ID = @CAMPAIGN_ID;


	BEGIN TRANSACTION;
	SAVE TRANSACTION QrScanSavePoint;
	BEGIN TRY
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
				IF (@SCAN_INTERVAL=24) AND (Cast(@CURRENT_SINGAPORE_TIME as date) <= Cast (@LAST_SCANNED_TIME as date))
				BEGIN
					print('already scanned')
					SET @SCAN_VALUE = 0;
					SET @RETURN_NO='007' -- scan time is too frequent                           
					--GOTO Err
				END
				ELSE 
				BEGIN
					-- randomiser for either 5 pts or 20 pts
					INSERT INTO CUSTOMER_EARNED_POINTS (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at,ip_address,GPS_location) VALUES
					(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME,@ip_address,@GPS_location)
					IF(@@ROWCOUNT>0)
					BEGIN
						-- print ('-----------Insert earned points ----------')
						IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
						BEGIN
							UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+@SCAN_VALUE 
							,total_scans = (SELECT total_scans FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+1
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
			INSERT INTO CUSTOMER_EARNED_POINTS (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at,ip_address,GPS_location) VALUES
			(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME,@ip_address,@GPS_location)
				
			IF(@@ROWCOUNT>0)
			BEGIN
				IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
				BEGIN
					UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+@SCAN_VALUE 
					,total_scans = (SELECT total_scans FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+1
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
		--CHECK LAST SCANNED TIME 
	     
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
	IF @RETURN_NO='002' 
	BEGIN  
		--SELECT '0' as response_code, 'Scan interval per code : 24 hours' as response_message , 3 as timer_interval_second
		SELECT '0' as response_code, Concat('Scan interval per code: ',@SCAN_INTERVAL,' hours') as response_message , 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='003' 
	BEGIN  
		SELECT '0' as response_code, 'Invalid QR Code' as response_message , 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='004' 
	BEGIN  
		SELECT '0' as response_code, 'Insert Failed' as response_message , 3 as timer_interval_second
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
	ELSE IF (@RETURN_NO='007' or @RETURN_NO='001')
	BEGIN  
		set @default_image_id = 478;

		IF(@RETURN_NO='007')
		BEGIN
			set @successMsg = 'Don''t be naughty! You''ve voted! Come another day to vote again!';
		END
		ELSE
		BEGIN
			set @successMsg = 'Oh no! We have run out of points. Better luck next time!';
		END

		SELECT @SMALL_IMAGE_URL = small_image_name ,@SMALL_WEBSITE_URL = small_image_url 
		FROM campaign_small_image 
		WHERE CAMPAIGN_ID = @CAMPAIGN_ID
		and id= @default_image_id

	    SELECT '1' as response_code, @successMsg as response_message, @SMALL_IMAGE_URL AS small_banner_url, @SCAN_VALUE as scan_value,@SMALL_WEBSITE_URL AS small_website_url
		, 3 as timer_interval_second,@default_image_id as image_id
		RETURN      
	END
	ELSE IF @RETURN_NO='000' 
	BEGIN 
		IF(@SCAN_VALUE = 5)
		BEGIN
			set @successMsg = 'HO! HO! HO! You''ve won 5 points!';
			set @default_image_id = 475;
		END
		ELSE IF(@SCAN_VALUE = 20)
		BEGIN
			set @successMsg = 'HO! HO! HO! You''ve won 20 points! You are a BIG WINNER!';
			set @default_image_id = 476;
		END

		SELECT @SMALL_IMAGE_URL = small_image_name ,@SMALL_WEBSITE_URL = small_image_url 
		FROM campaign_small_image 
		WHERE CAMPAIGN_ID = @CAMPAIGN_ID
		and id= @default_image_id

		SELECT '1' as response_code,@successMsg as response_message, @SMALL_IMAGE_URL AS small_banner_url, @SCAN_VALUE as scan_value,@SMALL_WEBSITE_URL AS small_website_url
		, 3 as timer_interval_second,@default_image_id as image_id
		RETURN 
	END
END