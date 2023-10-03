CREATE PROC [dbo].[Internal_Survey_QR_Scan]          
@customer_tokenid VARCHAR(255),                                       
@qrcode VARCHAR(50),
@ip_address varchar(30),
@GPS_location varchar(250),
@winktagId int                                                                                                                   

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


DECLARE @locked_reason varchar(255)
DECLARE @locked_customer_id int 
DECLARE @admin_user_email_for_lock_account  varchar(255) 
DECLARE @row_count int = 0


SET @admin_user_email_for_lock_account = 'admin@winkwink.sg'

SET @Valid = 1


-- this small logo image is for WINK Refresher Training Quiz and Viral Leaders Game
IF(@winktagId = 183)
BEGIN
	set @default_image_id =481
END
ELSE IF(@winktagId = 187)
BEGIN
	set @default_image_id =481
END
ELSE IF(@winktagId = 144)
BEGIN
	set @default_image_id =311
END
ELSE IF(@winktagId = 158)
BEGIN
	set @default_image_id =405
END
ELSE IF(@winktagId = 176 OR @winktagId = 193)
BEGIN
	set @default_image_id =479
END
ELSE IF(@winktagId = 189)
BEGIN
	set @default_image_id = 497
END
--SMRT35thAnniversaryPhase2,3,4,5,6 --
ELSE IF(@winktagId = 191 OR @winktagId=194 OR @winktagId=198 OR @winktagId=199 OR @winktagId=200 OR @winktagId = 201)
BEGIN
	set @default_image_id = 501 --same QR pop-up image--
END
--TownHallHiveSurvey2023 --
ELSE IF(@winktagId = 208)
BEGIN
	set @default_image_id = 544 
END
-- Town Hall 2023 Marsiling Staytion Survey
ELSE IF(@winktagId = 210)
BEGIN
	set @default_image_id = 547
END
-- TownHall2023Engineering --
ELSE IF(@winktagId = 213)
BEGIN
	set @default_image_id = 552
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
			DECLARE @survey_start as datetime;
			DECLARE @survey_end as datetime;

			IF(@winktagId = 183)
			BEGIN
				set @survey_start = '2022-04-12 14:50:00.000';
				set @survey_end = '2022-04-28 23:59:00.000';
			END
			IF(@winktagId = 187)
			BEGIN
				set @survey_start = '2022-07-20 11:42:12.523';
				set @survey_end = '2022-07-27 11:47:17.110';
			END
			IF(@winktagId = 189)
			BEGIN
				set @survey_start = '2022-09-13 09:00:00.000';
				set @survey_end = '2023-09-26 23:59:59.000';
			END
			IF(@winktagId = 191)
			BEGIN
				set @survey_start = '2022-10-20 09:00:00.000';
				set @survey_end =   '2023-11-03 23:59:59.000';
			END
			--SMRT35thAnniversaryPhase3 --
			IF(@winktagId = 194)
			BEGIN
				set @survey_start = '2022-11-10 09:00:00.000';
				set @survey_end =   '2023-11-10 23:59:59.000';
			END
			--SMRT35thAnniversaryPhase4 --
			IF(@winktagId = 198)
			BEGIN
				set @survey_start = '2022-11-29 09:00:00.000';
				set @survey_end =   '2023-12-18 23:59:59.000';
			END
			--SMRT35thAnniversaryPhase5 --
			IF(@winktagId = 199)
			BEGIN
				set @survey_start = '2022-12-09 09:00:00.000';
				set @survey_end =   '2024-01-02 23:59:59.000';
			END
			--SMRT35thAnniversaryPhase6 --
			IF(@winktagId = 200)
			BEGIN
				set @survey_start = '2022-12-28 09:00:00.000';
				set @survey_end =   '2024-01-15 23:59:59.000';
			END
			--SMRT35thAnniversaryPhase7 --
			IF(@winktagId = 201)
			BEGIN
				set @survey_start = '2022-01-04 09:00:00.000';
				set @survey_end =   '2024-01-04 23:59:59.000';
			END
			ELSE IF(@winktagId = 176)
			BEGIN
				set @survey_start = '2022-01-01 09:00:00.000';
				set @survey_end = '2022-01-18 23:59:59.000';
			END
			ELSE IF(@winktagId = 158)
			BEGIN
				set @survey_start = '2021-01-28 09:00:00.000';
				set @survey_end = '2021-03-31 23:59:59.000';
			END
			ELSE IF(@winktagId = 144)
			BEGIN
				set @survey_start = '2020-03-11 14:00:00.000';
				set @survey_end = '2020-03-31 23:59:59.000';
			END
			ELSE IF(@winktagId = 193)
			BEGIN
				set @survey_start = '2022-11-07 09:00:00.000';
				set @survey_end = '2023-11-07 23:59:59.000';
			END
            --TownHallHiveSurvey2023 --
			ELSE IF(@winktagId = 208)
			BEGIN
				set @survey_start = '2023-06-20 09:00:00.000';
				set @survey_end =   '2023-07-20 23:59:59.000';
			END
            --Town Hall 2023 Marsiling Staytion--
            ELSE IF(@winktagId = 210)
			BEGIN
				set @survey_start = '2023-06-21 17:10:00.000';
				set @survey_end =  '2023-06-23 18:00:00.000';
			END
            --TownHall2023Engineering--
            ELSE IF(@winktagId = 213)
			BEGIN
				set @survey_start =  (SELECT from_date FROM winktag_campaign where campaign_id = @winktagId);
				set @survey_end =  (SELECT to_date FROM winktag_campaign where campaign_id = @winktagId);
                
			END



			IF(Cast(@CURRENT_DATETIME as datetime) between @survey_start AND @survey_end)
			BEGIN
			 
				Update customer set customer.ip_scanned = @ip_address ,customer.ip_address = @ip_address where customer_id=@CUSTOMER_ID

				--CHECK LAST SCANNED TIME 
			
				IF EXISTS (SELECT 1 from winktag_campaign where campaign_id = @winktagId and winktag_status = '1')
				BEGIN
					---------------- Start To Check Scan Interval------------------
				
				DECLARE @validScan int = 0;
				
				-- for campaigns that require daily scanning
				IF (@winktagId = 187 OR @winktagId = 189 OR @winktagId = 191 OR @winktagId = 194  OR @winktagId = 198 OR @winktagId = 199 OR @winktagId = 200 OR @winktagId = 201)
				BEGIN
				  IF NOT EXISTS (SELECT
					  1
					FROM CUSTOMER_EARNED_POINTS
					WHERE CUSTOMER_ID = @CUSTOMER_ID
					AND QR_CODE = @qrcode
					AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date))
				  BEGIN
                    
					SET @validScan = 1;					
				  END
				END
                -- check the maximun invetory count
                ELSE IF (@winktagId = 213)
                BEGIN
                    DECLARE @CampaignNumberOfUsed int = (SELECT COUNT(*) from customer_earned_points where qr_code = @qrcode);
                    DECLARE @CampaignMaxLimit int = (SELECT size from winktag_campaign where campaign_id = @winktagId);

                    IF NOT EXISTS (SELECT 1
                        FROM CUSTOMER_EARNED_POINTS
                        WHERE CUSTOMER_ID = @CUSTOMER_ID
                        AND QR_CODE = @qrcode)             
                    BEGIN             
                        IF (@CampaignNumberOfUsed < @CampaignMaxLimit )
                        BEGIN
                            SET @validScan = 1;		
                        END
                        ELSE
                        BEGIN
                            SET @RETURN_NO='008' -- hit the max invetory count                 
                            GOTO Err
                        END			
                    END
                END
				ELSE --for all other campaigns
				BEGIN
				  IF NOT EXISTS (SELECT
					  1
					FROM CUSTOMER_EARNED_POINTS
					WHERE CUSTOMER_ID = @CUSTOMER_ID
					AND QR_CODE = @qrcode)
				  BEGIN
					SET @validScan = 1;
				  END
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
									SET @RETURN_NO='000' -- survey                           
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

						SET @RETURN_NO='007' -- Scan too frequently                     
						GOTO Err
				
					END
				END
				ELSE
				BEGIN
					SET @RETURN_NO='005' -- Survey is concluded                     
					GOTO Err
				END
				
			END
			ELSE IF(Cast(@CURRENT_DATETIME as datetime) < @survey_start)
			BEGIN 
				SET @RETURN_NO='006'   -- INVALID QR CODE (before)                        
				GOTO Err
			END
			ELSE
			BEGIN 
			
				SET @RETURN_NO='005'   -- INVALID QR CODE (after),Survey is concluded                  
				GOTO Err
				
			END
		END
		
		ELSE
		BEGIN
			SET @RETURN_NO='003'   -- INVALID QR CODE                        
			GOTO Err
		END
		
	--END 
	--ELSE -- Customer disable
	--BEGIN
	--	SET @RETURN_NO='001'   -- Customer disable                     
	--	GOTO Err
	--END
	
	
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
	ELSE IF @RETURN_NO='005'	
	BEGIN  
		DECLARE @endedMsg varchar(150);

		IF(@winktagId = 183)
		BEGIN
			SET @endedMsg = 'The Town Hall survey is now over. Thank you for your interest.';
		END
		ELSE IF(@winktagId = 189 OR @winktagId = 191 OR @winktagId = 194 OR @winktagId = 198 OR @winktagId = 199 OR @winktagId = 200 OR @winktagId = 201 )
		BEGIN
			SET @endedMsg = 'You missed it! Check our socials to see when you can play!';
		END
		ELSE IF(@winktagId = 208 OR @winktagId = 210 )
		BEGIN
			SET @endedMsg = 'Check our social media pages to see when you can play again!';
		END
        ELSE IF(@winktagId = 213)
		BEGIN
			SET @endedMsg = 'This campaign has ended!';
		END
		ELSE
		BEGIN
			SET @endedMsg = 'This survey has ended.';
		END

		SELECT '0' as response_code, @endedMsg as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
		RETURN 
	END
	ELSE IF @RETURN_NO='006' 
	BEGIN  
		DECLARE @befMsg varchar(150);

		IF(@winktagId = 183)
		BEGIN
			SET @befMsg = 'The survey will be available after Town Hall begins, please check back again soon!';
		END
          --TownHall2023Engineering--
        ELSE IF(@winktagId = 213)
        BEGIN
            SET @befMsg = 'This campaign has not started! Try again later!';
        END
		ELSE
		BEGIN
			SET @befMsg = 'This survey has not started yet.';
		END

		SELECT '0' as response_code, @befMsg as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
		RETURN 
	END
	ELSE IF @RETURN_NO='007' -- Already scanned QR Code once
	BEGIN  
		IF(@winktagId = 189 OR @winktagId = 191 OR @winktagId = 194 OR @winktagId = 198 OR @winktagId = 199 OR @winktagId = 200 OR @winktagId = 201)
		BEGIN
			SELECT '0' as response_code, 'You''ve scanned this! Go to WINK+ play to do the quiz now!' as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
			RETURN
		END
		ELSE IF(@winktagId = 208 OR @winktagId = 210)
		BEGIN
			SELECT '0' as response_code, 'You''ve scanned this! Head to WINK+ Play to do the quiz now!' as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
			RETURN
		END
		ELSE IF(@winktagId = 213)
		BEGIN
			SELECT '0' as response_code, 'Scan limit reached! Go to WINK Treats to get your eVoucher!' as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
			RETURN
		END
		ELSE
		BEGIN
			SELECT '0' as response_code, 'Oops! You can only scan this QR Code once.' as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
			RETURN 
		END
	END
    ELSE IF @RETURN_NO='008' -- Hit the max invetory count
	BEGIN  
        IF(@winktagId = 213)
		BEGIN
			SELECT '0' as response_code, 'All WINK points have been fully redeemed!' as response_message , 3 as timer_interval_second,@SMALL_IMAGE_URL AS small_banner_url,@SMALL_WEBSITE_URL AS small_website_url
			RETURN
		END
    END
	ELSE IF @RETURN_NO='000' -- Survey
	BEGIN
		DECLARE @successMsg varchar(150);

		IF(@winktagId = 183)
		BEGIN
			SET @successMsg = 'Head to WINK+ Play to complete the Town Hall 2022 survey!';
		END
		ELSE IF(@winktagId = 158)
		BEGIN
			SET @successMsg = 'Head over to WINK+ Play to participate in SMRT Media''s Advertisers Satisfaction Survey';
		END 
		ELSE IF(@winktagId = 144)
		BEGIN
			SET @successMsg = 'Head over to WINK+ Play to participate in XCO''s Advertisers Satisfaction Survey';
		END
		ELSE IF(@winktagId = 189 OR @winktagId = 191 OR @winktagId = 194 OR @winktagId = 198 OR @winktagId = 199 OR @winktagId = 200 OR @winktagId = 201)
		BEGIN
			SET @successMsg = 'YAY! Head to WINK+ play to complete the quiz now!';
		END
        ELSE IF(@winktagId = 208  OR @winktagId = 210)
		BEGIN
			SET @successMsg = 'Head to WINK+ Play to do the quiz now!';
		END 
        ELSE IF(@winktagId = 213)
		BEGIN
			SET @successMsg = '600 points earned! Go to WINK+ Treats now!';
		END 
		ELSE
		BEGIN
			SET @successMsg = 'Head over to WINK+ Play to complete the survey';
		END


		SELECT '1' as response_code,@successMsg as response_message, @SMALL_IMAGE_URL AS small_banner_url, @SCAN_VALUE as scan_value,@SMALL_WEBSITE_URL AS small_website_url
		, 3 as timer_interval_second,@default_image_id as image_id
		RETURN 
	END
	
END
