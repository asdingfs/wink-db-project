﻿
CREATE PROC [dbo].[Get_Scan_Points_popo]          
@customer_tokenid VARCHAR(50),                                       
@qrcode VARCHAR(50)                                                                                                                              

AS

DECLARE @auth_token VARCHAR(50)
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
DECLARE @CURRENT_DATETIME datetimeoffset = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');
DECLARE @QR_ScanInterval decimal(10,2)
DECLARE @last_station_code varchar(50)
DECLARE @current_station_code varchar(50)
DECLARE @last_station_qrCode varchar(50)
DECLARE  @LAST_SCANNED_TIME_Log  datetime 
DECLARE @CURRENT_SINGAPORE_TIME DATETIME
DECLARE @Valid int 

DECLARE @Last_Active_ScanQR_Code varchar(50)
DECLARE @Last_Active_Scan_Time_log datetime
DECLARE @Last_Active_Station_Code varchar(50)


--********GAME**************
DECLARE @event_id int 


BEGIN 
	If CAST(@CURRENT_DATETIME as time) < '00:00:00' OR CAST(@CURRENT_DATETIME as time) >= '05:30:00'
	
	BEGIN --- Begin check time between 00:30 and 05:30
   
	IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @customer_tokenid and customer.status='enable')                                                     
	BEGIN  
	
		IF EXISTS (Select * from asset_management_booking where qr_code_value =@qrcode and asset_management_booking.event_status =0)
		BEGIN
			--SELECT * FROM ASSET_MANAGEMENT_BOOKING WHERE CONVERT(CHAR(10),@CURRENT_DATETIME,111)>= CONVERT(CHAR(10),START_DATE,111) and CONVERT(CHAR(10),@CURRENT_DATETIME,111)<= CONVERT(CHAR(10),END_DATE,111) AND QR_CODE_VALUE = @qrcode
		IF EXISTS (SELECT ASSET_MANAGEMENT_BOOKING.booking_id FROM ASSET_MANAGEMENT_BOOKING WHERE CONVERT(CHAR(10),@CURRENT_DATETIME,111) >= CONVERT(CHAR(10),START_DATE,111) and CONVERT(CHAR(10),@CURRENT_DATETIME,111) <= CONVERT(CHAR(10),END_DATE,111) AND QR_CODE_VALUE = @qrcode
		AND Lower(asset_management_booking.booked_status) = 'true')
		
		BEGIN
			SELECT @CAMPAIGN_ID = CAMPAIGN_ID,@BOOKING_ID= BOOKING_ID ,@SCAN_INTERVAL=SCAN_INTERVAL, @SCAN_VALUE = SCAN_VALUE FROM 
			ASSET_MANAGEMENT_BOOKING WHERE CONVERT(CHAR(10),@CURRENT_DATETIME,111) 
			BETWEEN CONVERT(CHAR(10),START_DATE,111) and CONVERT(CHAR(10),END_DATE,111) 
			AND QR_CODE_VALUE = @qrcode
			AND Lower(asset_management_booking.booked_status) = 'true'
			PRINT(@CAMPAIGN_ID)
			
			SELECT TOP 1 @CUSTOMER_ID = CUSTOMER_ID FROM CUSTOMER WHERE auth_token = @customer_tokenid 
			
			-- GET Data To Insert QR Log
			
			SELECT @MERCHANT_ID = MERCHANT_ID FROM CAMPAIGN WHERE CAMPAIGN_ID = @CAMPAIGN_ID
					
			SELECT @SMALL_IMAGE_URL = SMALL_BANNER ,@SMALL_WEBSITE_URL = small_url FROM CAMPAIGN_ADS_BANNER WHERE MERCHANT_ID = @MERCHANT_ID
			print(@SMALL_WEBSITE_URL)
			
			-- Insert Into Log Table 
								
			--Check Station QR Code 
			SET @last_station_qrCode = (Select Top 1 customer_earned_points_log.qr_code from customer_earned_points_log where customer_earned_points_log.customer_id = @CUSTOMER_ID order by customer_earned_points_log.earned_points_id desc)
			SELECT TOP 1 @LAST_SCANNED_TIME_Log = LAST_SCANNED_TIME FROM customer_earned_points_log WHERE CUSTOMER_ID = @CUSTOMER_ID ORDER BY LAST_SCANNED_TIME DESC
			--Select TOP 1 @last_station_qrCode = customer_earned_points_log.qr_code, @LAST_SCANNED_TIME_Log = LAST_SCANNED_TIME from customer_earned_points_log where customer_earned_points_log.customer_id = @CUSTOMER_ID order by customer_earned_points_log.earned_points_id desc
			
			Print ('last station qr')
			print (@last_station_qrCode)
			
			Print ('@LAST_SCANNED_TIME_Log')
			print (@LAST_SCANNED_TIME_Log)
			
			SET @current_station_code = (Select asset_type_management.station_code from asset_type_management where asset_type_management.qr_code_value = @qrcode)
			Print ('@current_station_code')
			print (@current_station_code)
			SET @last_station_code = (Select asset_type_management.station_code from asset_type_management where asset_type_management.qr_code_value = @last_station_qrCode)
			Print ('@@last_station_code')
			print (@last_station_code)
						
			--SELECT TOP 1 @LAST_SCANNED_TIME_Log = LAST_SCANNED_TIME FROM customer_earned_points_log WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE = @qrcode ORDER BY LAST_SCANNED_TIME DESC
						
			INSERT INTO CUSTOMER_EARNED_POINTS_Log (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at) VALUES
					(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME)
		
		
			SET @Valid = 1	
			IF (@last_station_code != @current_station_code)
			BEGIN
				
				Print ('Not Same Station')
			    EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_SINGAPORE_TIME output
			    
			    Print('@LAST_SCANNED_TIME_Log')
			     Print(@LAST_SCANNED_TIME_Log)
			     
			     Print('@CURRENT_SINGAPORE_TIME')
			     Print(@CURRENT_SINGAPORE_TIME)
			   
				

                
				SELECT @DATE_DIFF = DATEDIFF(MINUTE,@LAST_SCANNED_TIME_Log,@CURRENT_SINGAPORE_TIME)
						
				
				Print ('@DATE_DIFF')
			    
			    Print (@DATE_DIFF )
				IF @DATE_DIFF<5
				
				BEGIN
					SET @Valid = 0
					--SET @RETURN_NO='005' -- scan time is too frequent                           
					--GOTO Err
				END
				
				
			END
			--- Same Station Code
			ELSE IF (@last_station_code = @current_station_code)
			BEGIN
			    Print ('Same Station')
			    
			    /*DECLARE @Last_Active_ScanQR_Code varchar(50)
			    DECLARE @Last_Active_Scan_Time_log datetime
			    DECLARE @Last_Active_Station_Code varchar(50)*/
			    
			    EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_SINGAPORE_TIME output
			    
	    
			    SET @Last_Active_ScanQR_Code = (SELECT Top 1 customer_earned_points.qr_code from customer_earned_points where customer_earned_points.customer_id =@CUSTOMER_ID order by customer_earned_points.earned_points_id desc)
			    SET @Last_Active_Station_Code = (SELECT asset_type_management.station_code from  asset_type_management where asset_type_management.qr_code_value =@Last_Active_ScanQR_Code)	
			    
			    
			    IF @Last_Active_Station_Code != @current_station_code
			    BEGIN
			     
			    SET @Last_Active_Scan_Time_log = (Select Top 1 customer_earned_points_log.created_at from customer_earned_points_log where customer_earned_points_log.qr_code = @Last_Active_ScanQR_Code order by customer_earned_points_log.earned_points_id desc)
			    
			    SELECT @DATE_DIFF = DATEDIFF(MINUTE,@Last_Active_Scan_Time_log,@CURRENT_SINGAPORE_TIME)
			   
			    Print('@LAST_SCANNED_TIME_Log')
			     Print(@Last_Active_Scan_Time_log)
			     
			      Print('@CURRENT_SINGAPORE_TIME')
			     Print(@CURRENT_SINGAPORE_TIME)
			   
			     Print('@DATE_DIFF')
			     Print(@DATE_DIFF)
			    IF @DATE_DIFF<5
				
				BEGIN
					SET @Valid = 0
					--SET @RETURN_NO='005' -- scan time is too frequent                           
					--GOTO Err
				END
				
			    END
			    
			     
			END
			
			
			
			IF @Valid= 0
				
				BEGIN
					SET @Valid = 0
					SET @RETURN_NO='005' -- scan time is too frequent                           
					GOTO Err
				END
			
			
			
			
			--SELECT Top 2 CUSTOMER_EARNED_POINTS_Log.created_at from CUSTOMER_EARNED_POINTS_Log WHERE 
			
			
			--CHECK LAST SCANNED TIME 
			IF EXISTS(SELECT * FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE = @qrcode)  
			BEGIN
				SELECT TOP 1 @LAST_SCANNED_TIME = LAST_SCANNED_TIME FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE = @qrcode ORDER BY LAST_SCANNED_TIME DESC

				SELECT @DATE_DIFF = DATEDIFF(HOUR,@LAST_SCANNED_TIME,@CURRENT_DATETIME)+8
				print(@DATE_DIFF);
				print (@SCAN_INTERVAL);

				IF @DATE_DIFF < @SCAN_INTERVAL
				BEGIN
					SET @RETURN_NO='002' -- scan time is too frequent                           
					GOTO Err
				END
				ELSE
				BEGIN
					SELECT @MERCHANT_ID = MERCHANT_ID FROM CAMPAIGN WHERE CAMPAIGN_ID = @CAMPAIGN_ID
					
					SELECT @SMALL_IMAGE_URL = SMALL_BANNER ,@SMALL_WEBSITE_URL = small_url FROM CAMPAIGN_ADS_BANNER WHERE MERCHANT_ID = @MERCHANT_ID
					print(@SMALL_WEBSITE_URL)
					--INSERT INTO customer_earned_points table
					--UPATE CUSTOMER_BALANCE TABLE
					
					INSERT INTO CUSTOMER_EARNED_POINTS (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at) VALUES
					(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME)
					IF(@@ROWCOUNT>0)
					BEGIN
						IF EXISTS (SELECT * FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
						BEGIN
							UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+@SCAN_VALUE WHERE CUSTOMER_ID =@CUSTOMER_ID
							SET @RETURN_NO='000' -- SUCCESS                           
							GOTO Err
						END
						ELSE
						BEGIN
							INSERT INTO customer_balance 
							(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers)VALUES
							(@CUSTOMER_ID,@SCAN_VALUE,0,0,0,0,0) 
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
				SELECT @MERCHANT_ID = MERCHANT_ID FROM CAMPAIGN WHERE CAMPAIGN_ID = @CAMPAIGN_ID
					
				SELECT @SMALL_IMAGE_URL = SMALL_BANNER ,@SMALL_WEBSITE_URL = small_url FROM CAMPAIGN_ADS_BANNER WHERE MERCHANT_ID = @MERCHANT_ID
				
				--INSERT INTO customer_earned_points table
				--UPATE CUSTOMER_BALANCE TABLE
				INSERT INTO CUSTOMER_EARNED_POINTS (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at) VALUES
					(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME)
				
				IF(@@ROWCOUNT>0)
				BEGIN
					IF EXISTS (SELECT * FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
					BEGIN
						UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+@SCAN_VALUE WHERE CUSTOMER_ID =@CUSTOMER_ID
						SET @RETURN_NO='000' -- SUCCESS                           
						GOTO Err
					END
					ELSE
					BEGIN
						INSERT INTO customer_balance 
						(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers)VALUES
						(@CUSTOMER_ID,@SCAN_VALUE,0,0,0,0,0) 
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
		ELSE
		BEGIN
			SET @RETURN_NO='003'   -- INVALID QR CODE                        
			GOTO Err
		END    
		END  
		
		ELSE IF EXISTS (Select * from asset_management_booking where qr_code_value =@qrcode and asset_management_booking.event_status =1)
		BEGIN
			--SELECT * FROM ASSET_MANAGEMENT_BOOKING WHERE CONVERT(CHAR(10),@CURRENT_DATETIME,111)>= CONVERT(CHAR(10),START_DATE,111) and CONVERT(CHAR(10),@CURRENT_DATETIME,111)<= CONVERT(CHAR(10),END_DATE,111) AND QR_CODE_VALUE = @qrcode
		IF EXISTS (SELECT ASSET_MANAGEMENT_BOOKING.booking_id FROM ASSET_MANAGEMENT_BOOKING WHERE CONVERT(CHAR(10),@CURRENT_DATETIME,111) >= CONVERT(CHAR(10),START_DATE,111) and CONVERT(CHAR(10),@CURRENT_DATETIME,111) <= CONVERT(CHAR(10),END_DATE,111) AND QR_CODE_VALUE = @qrcode
		AND Lower(asset_management_booking.booked_status) = 'true')
		
		BEGIN

		--*******************START GAME***********************************************************
		SELECT TOP 1 @CUSTOMER_ID = CUSTOMER_ID FROM CUSTOMER WHERE auth_token = @customer_tokenid
		
		-- Check Valid Check Point / QR Code  *****************************
		
		-- 1. Get  Game Team ID 
		DECLARE @teamId int 
		
		SELECT @teamId = game_team_players_details.team_id,
		@event_id = game_team_players_details.event_date_id  
		FROM game_team_players_details,game_event_date 
	    WHERE game_event_date.event_date_id = game_team_players_details.event_date_id and 
	    CAST(game_event_date.event_date as date) =  CAST (@CURRENT_DATETIME as date)
	    and game_team_players_details.customer_id = @CUSTOMER_ID
	    -- 1. Get  Game Team ID 
	    
		-- 2. Check GAME Last Check POINT ************************************
		IF EXISTS (Select * from game_player_checkpoints_summary where team_id = @teamId)
		BEGIN
			DECLARE @last_team_qrscan varchar(100)
			DECLARE @to_qrcode varchar(100)
			
			SET @last_team_qrscan = (Select top 1 game_player_checkpoints_summary.qr_code from game_player_checkpoints_summary where team_id = @teamId
			order by game_player_checkpoints_summary.id desc
			)
			-- 3. Check Valid Next QR Scan 
			IF (@qrcode != (select game_checkpoint_mapping.to_checkpoint_qr from game_checkpoint_mapping where game_checkpoint_mapping.from_checkpoint_qr =@last_team_qrscan))
			BEGIN
				SET @RETURN_NO='006' -- Invalid Scan Check Point Location                      
				GOTO Err
			END
		END
		--*******************START GAME***********************************************************
		
		
			SELECT @CAMPAIGN_ID = CAMPAIGN_ID,@BOOKING_ID= BOOKING_ID ,@SCAN_INTERVAL=SCAN_INTERVAL, @SCAN_VALUE = SCAN_VALUE FROM 
			ASSET_MANAGEMENT_BOOKING WHERE CONVERT(CHAR(10),@CURRENT_DATETIME,111) 
			BETWEEN CONVERT(CHAR(10),START_DATE,111) and CONVERT(CHAR(10),END_DATE,111) 
			AND QR_CODE_VALUE = @qrcode
			AND Lower(asset_management_booking.booked_status) = 'true'
			PRINT(@CAMPAIGN_ID)
			
			SELECT TOP 1 @CUSTOMER_ID = CUSTOMER_ID FROM CUSTOMER WHERE auth_token = @customer_tokenid 
			
			-- GET Data To Insert QR Log
			
			SELECT @MERCHANT_ID = MERCHANT_ID FROM CAMPAIGN WHERE CAMPAIGN_ID = @CAMPAIGN_ID
			
			/*-------------------Game Image and URL Hint-------------------*/
					
			SELECT @SMALL_IMAGE_URL = SMALL_BANNER ,@SMALL_WEBSITE_URL = small_url FROM CAMPAIGN_ADS_BANNER WHERE MERCHANT_ID = @MERCHANT_ID
			print(@SMALL_WEBSITE_URL)
			
			Select @SMALL_WEBSITE_URL = game_checkpoint_detail.id from game_checkpoint_detail
			where qr_code = (select game_checkpoint_mapping.to_checkpoint_qr from game_checkpoint_mapping
			where game_checkpoint_mapping.from_checkpoint_qr = @qrcode)
			/*-------------------Game Image and URL Hint-------------------*/
			
			-- Insert Into Log Table 
								
			--Check Station QR Code 
			SET @last_station_qrCode = (Select Top 1 customer_earned_points_log.qr_code from customer_earned_points_log where customer_earned_points_log.customer_id = @CUSTOMER_ID order by customer_earned_points_log.earned_points_id desc)
			SELECT TOP 1 @LAST_SCANNED_TIME_Log = LAST_SCANNED_TIME FROM customer_earned_points_log WHERE CUSTOMER_ID = @CUSTOMER_ID ORDER BY LAST_SCANNED_TIME DESC
			--Select TOP 1 @last_station_qrCode = customer_earned_points_log.qr_code, @LAST_SCANNED_TIME_Log = LAST_SCANNED_TIME from customer_earned_points_log where customer_earned_points_log.customer_id = @CUSTOMER_ID order by customer_earned_points_log.earned_points_id desc
			
			Print ('last station qr')
			print (@last_station_qrCode)
			
			Print ('@LAST_SCANNED_TIME_Log')
			print (@LAST_SCANNED_TIME_Log)
			
			SET @current_station_code = (Select asset_type_management.station_code from asset_type_management where asset_type_management.qr_code_value = @qrcode)
			Print ('@current_station_code')
			print (@current_station_code)
			SET @last_station_code = (Select asset_type_management.station_code from asset_type_management where asset_type_management.qr_code_value = @last_station_qrCode)
			Print ('@@last_station_code')
			print (@last_station_code)
						
			--SELECT TOP 1 @LAST_SCANNED_TIME_Log = LAST_SCANNED_TIME FROM customer_earned_points_log WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE = @qrcode ORDER BY LAST_SCANNED_TIME DESC
						
			INSERT INTO CUSTOMER_EARNED_POINTS_Log (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at) VALUES
					(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME)
		
		
			SET @Valid = 1	
			IF (@last_station_code != @current_station_code)
			BEGIN
				
				Print ('Not Same Station')
			    EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_SINGAPORE_TIME output
			    
			    Print('@LAST_SCANNED_TIME_Log')
			     Print(@LAST_SCANNED_TIME_Log)
			     
			     Print('@CURRENT_SINGAPORE_TIME')
			     Print(@CURRENT_SINGAPORE_TIME)
			   
				

                
				SELECT @DATE_DIFF = DATEDIFF(MINUTE,@LAST_SCANNED_TIME_Log,@CURRENT_SINGAPORE_TIME)
						
				
				Print ('@DATE_DIFF')
			    
			    Print (@DATE_DIFF )
				IF @DATE_DIFF<5
				
				BEGIN
					SET @Valid = 0
					--SET @RETURN_NO='005' -- scan time is too frequent                           
					--GOTO Err
				END
				
				
			END
			--- Same Station Code
			ELSE IF (@last_station_code = @current_station_code)
			BEGIN
			    Print ('Same Station')

			    EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_SINGAPORE_TIME output
			    
	    
			    SET @Last_Active_ScanQR_Code = (SELECT Top 1 customer_earned_points.qr_code from customer_earned_points where customer_earned_points.customer_id =@CUSTOMER_ID order by customer_earned_points.earned_points_id desc)
			    SET @Last_Active_Station_Code = (SELECT asset_type_management.station_code from  asset_type_management where asset_type_management.qr_code_value =@Last_Active_ScanQR_Code)	
			    
			    
			    IF @Last_Active_Station_Code != @current_station_code
			    BEGIN
			     
			    SET @Last_Active_Scan_Time_log = (Select Top 1 customer_earned_points_log.created_at from customer_earned_points_log where customer_earned_points_log.qr_code = @Last_Active_ScanQR_Code order by customer_earned_points_log.earned_points_id desc)
			    
			    SELECT @DATE_DIFF = DATEDIFF(MINUTE,@Last_Active_Scan_Time_log,@CURRENT_SINGAPORE_TIME)
			   
			    Print('@LAST_SCANNED_TIME_Log')
			     Print(@Last_Active_Scan_Time_log)
			     
			      Print('@CURRENT_SINGAPORE_TIME')
			     Print(@CURRENT_SINGAPORE_TIME)
			   
			     Print('@DATE_DIFF')
			     Print(@DATE_DIFF)
			    IF @DATE_DIFF<5
				
				BEGIN
					SET @Valid = 0
					--SET @RETURN_NO='005' -- scan time is too frequent                           
					--GOTO Err
				END
				
			    END
			    
			     
			END
			
			
			
			IF @Valid= 0
				
				BEGIN
					SET @Valid = 0
					SET @RETURN_NO='005' -- scan time is too frequent                           
					GOTO Err
				END
			
			
			
			
			--SELECT Top 2 CUSTOMER_EARNED_POINTS_Log.created_at from CUSTOMER_EARNED_POINTS_Log WHERE 
			
			
			--CHECK LAST SCANNED TIME 
			IF EXISTS(SELECT * FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE = @qrcode)  
			BEGIN
				SELECT TOP 1 @LAST_SCANNED_TIME = LAST_SCANNED_TIME FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE = @qrcode ORDER BY LAST_SCANNED_TIME DESC

				SELECT @DATE_DIFF = DATEDIFF(HOUR,@LAST_SCANNED_TIME,@CURRENT_DATETIME)+8
				print(@DATE_DIFF);
				print (@SCAN_INTERVAL);

				IF @DATE_DIFF < @SCAN_INTERVAL
				BEGIN
					SET @RETURN_NO='002' -- scan time is too frequent                           
					GOTO Err
				END
				ELSE
				BEGIN
					SELECT @MERCHANT_ID = MERCHANT_ID FROM CAMPAIGN WHERE CAMPAIGN_ID = @CAMPAIGN_ID
					
					SELECT @SMALL_IMAGE_URL = SMALL_BANNER ,@SMALL_WEBSITE_URL = small_url FROM CAMPAIGN_ADS_BANNER WHERE MERCHANT_ID = @MERCHANT_ID
					print(@SMALL_WEBSITE_URL)
					--INSERT INTO customer_earned_points table
					--UPATE CUSTOMER_BALANCE TABLE
					
					INSERT INTO CUSTOMER_EARNED_POINTS (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at) VALUES
					(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME)
					IF(@@ROWCOUNT>0)
					BEGIN
						IF EXISTS (SELECT * FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
						BEGIN
							UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+@SCAN_VALUE WHERE CUSTOMER_ID =@CUSTOMER_ID
							SET @RETURN_NO='000' -- SUCCESS                           
							GOTO Err
						END
						ELSE
						BEGIN
							INSERT INTO customer_balance 
							(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers)VALUES
							(@CUSTOMER_ID,@SCAN_VALUE,0,0,0,0,0) 
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
				SELECT @MERCHANT_ID = MERCHANT_ID FROM CAMPAIGN WHERE CAMPAIGN_ID = @CAMPAIGN_ID
					
				SELECT @SMALL_IMAGE_URL = SMALL_BANNER ,@SMALL_WEBSITE_URL = small_url FROM CAMPAIGN_ADS_BANNER WHERE MERCHANT_ID = @MERCHANT_ID
				
				--INSERT INTO customer_earned_points table
				--UPATE CUSTOMER_BALANCE TABLE
				INSERT INTO CUSTOMER_EARNED_POINTS (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at) VALUES
					(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME)
				
				IF(@@ROWCOUNT>0)
				BEGIN
					IF EXISTS (SELECT * FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
					BEGIN
						UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+@SCAN_VALUE WHERE CUSTOMER_ID =@CUSTOMER_ID
						SET @RETURN_NO='000' -- SUCCESS                           
						GOTO Err
					END
					ELSE
					BEGIN
						INSERT INTO customer_balance 
						(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers)VALUES
						(@CUSTOMER_ID,@SCAN_VALUE,0,0,0,0,0) 
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
		ELSE
		BEGIN
			SET @RETURN_NO='003'   -- INVALID QR CODE                        
			GOTO Err
		END    
		END    
	END 
	ELSE -- AUTH_TOKEN DOES NOT EXIST
	BEGIN
		SET @RETURN_NO='001'   -- customer does not exist                        
		GOTO Err
	END

	------------------------------------------------------------------------------------------------------------
	Err:                                         
	IF @RETURN_NO='001' 
	                          
	BEGIN                                              
		SELECT '0' as response_code, 'Invalid Scan' as response_message 
		--SELECT '0' as response_code, 'Invalid Scan' as response_message 
		RETURN                           
	END 
	ELSE IF @RETURN_NO='002' 
	BEGIN  
		SELECT '0' as response_code, 'Invalid Scan' as response_message 
		RETURN 
	END
	ELSE IF @RETURN_NO='003' 
	BEGIN  
		SELECT '0' as response_code, 'Invalid QR Code' as response_message 
		RETURN 
	END
	ELSE IF @RETURN_NO='004' 
	BEGIN  
		SELECT '0' as response_code, 'Insert Fail' as response_message 
		RETURN 
	END
	ELSE IF @RETURN_NO='005' 
	BEGIN  
		SELECT '0' as response_code, 'Invalid Scan' as response_message 
		RETURN 
	END
	ELSE IF @RETURN_NO='006' 
	BEGIN  
		SELECT '0' as response_code, 'Invalid Scan Check Point Location' as response_message 
		RETURN 
	END
	ELSE IF @RETURN_NO='000' 
	BEGIN  
		IF EXISTS (Select * from asset_management_booking where qr_code_value =@qrcode and asset_management_booking.event_status =1)
		BEGIN
			-- Game Player QR code summary ***************************************************************************************************************
			/* Insert Game Player Detail ***********************/
			Insert into game_player_checkpoints_detail (customer_id,qr_code,created_at,event_id,event_date,team_id,campaign_booking_id,points,last_scanned_time)
			values (@CUSTOMER_ID,@qrcode,@CURRENT_DATETIME,@event_id,@CURRENT_DATETIME,@teamId,@BOOKING_ID,0,@CURRENT_DATETIME)
			
			/* Insert Game Player Summary **** ***********************/
			IF( 
			(Select COUNT(*) from game_player_checkpoints_detail where game_player_checkpoints_detail.team_id = @teamId
			and game_player_checkpoints_detail.qr_code = @qrcode) =
			(Select COUNT(*) from game_team_players_details where game_team_players_details.team_id = @teamId))
			BEGIN
				INSERT INTO game_player_checkpoints_summary (team_id,qr_code,created_at,event_id)
				values (@teamId,@qrcode,@CURRENT_DATETIME,@event_id)
			END 
			/***Insert Milestone *********************************/
			--USE WINKWINK
			--SELECT * FROM game_player_checkpoints_summary
			--SELECT * FROM game_player_milestone_complete
			--SELECT * FROM game_checkpoint_detail
			DECLARE @no_of_location INT
			SET @no_of_location = (SELECT COUNT(*) FROM game_location)
			
			IF((SELECT COUNT(*) FROM game_player_checkpoints_summary WHERE TEAM_ID = @teamId AND EVENT_ID = @event_id)
			<= (SELECT COUNT(*) FROM game_checkpoint_detail WHERE EVENT_ID = @event_id)+1)
			BEGIN
				IF((SELECT COUNT(*) FROM game_player_checkpoints_summary WHERE TEAM_ID = @teamId AND EVENT_ID = @event_id)
				=(((SELECT COUNT(*) FROM game_player_milestone_complete WHERE TEAM_ID = @teamId AND EVENT_ID = @event_id)*@no_of_location)+(@no_of_location+1)))
				BEGIN
					INSERT INTO game_player_milestone_complete (team_id,milestone_number,created_at,event_id)
					values(@teamId,(SELECT COUNT(*) FROM game_player_milestone_complete WHERE TEAM_ID = @teamId AND EVENT_ID = @event_id)+1,GETDATE(),@event_id)
				END
			END	
		END

		
		SELECT '1' as response_code,'Success' as response_message, @SMALL_IMAGE_URL AS small_banner_url, @SCAN_VALUE as scan_value,@SMALL_WEBSITE_URL AS small_website_url
		RETURN 
	END

 END -- END check time between 00:30 and 05:30
 
	ELSE 
	BEGIN
	SELECT '0' as response_code, 'Invalid Scan' as response_message 
		RETURN 
	END
END








