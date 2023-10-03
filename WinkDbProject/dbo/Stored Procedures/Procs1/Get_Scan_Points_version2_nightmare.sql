
CREATE PROC [dbo].[Get_Scan_Points_version2_nightmare]          
@customer_tokenid VARCHAR(255),                                       
@qrcode VARCHAR(50)                                                                                                                              

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
DECLARE @CURRENT_DATETIME datetimeoffset = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');

DECLARE @QR_ScanInterval decimal(10,2)

DECLARE @last_station_code varchar(50)
DECLARE @current_station_code varchar(50)
DECLARE @last_station_qrCode varchar(50)
DECLARE  @LAST_SCANNED_TIME_Log  datetime 
DECLARE @CURRENT_SINGAPORE_TIME DATETIME
DECLARE @Valid int 


If ( SUBSTRING ( @qrcode, 1 , 3) ='GSS')
   
   BEGIN
   Print('1')
   IF EXISTS (Select * from GSS_event,customer where GSS_event. qr_code_value = @qrcode and 
   GSS_event.email = customer.email and customer.auth_token = @customer_tokenid )
     
   BEGIN
   Print('2')
   IF ((select COUNT(*) from customer_earned_points where customer_earned_points.qr_code = @qrcode)> 0)
   BEGIN
    Print('3')
    SET @RETURN_NO='001' -- scan time is too frequent                           
	GOTO Err
   
   END
   END
   Else
   
   BEGIN
    Print('4')
    SET @RETURN_NO='001' -- scan time is too frequent                           
	GOTO Err
   END
 
   
   
   END
   
   
   -- Check and Blocking Running By Script
   
   IF (
(select COUNT(*) from customer_earned_points 
where customer_earned_points.customer_id =
   (Select customer.customer_id from customer where customer.auth_token = @customer_tokenid)
  and CAST (created_at as DATE) = CAST (@CURRENT_DATETIME as Date)
  Group by CAST (created_at as DATE)
  --Having DATEDIFF(second,MIN(created_at),MAX(created_at))<=3
  --
  )>10)
  BEGIN
  Print ('Begin Script')
 IF ( (select DATEDIFF(second,MIN(created_at),MAX(created_at))
from (select top 10 * from customer_earned_points 
where customer_earned_points.customer_id =
   (Select customer.customer_id from customer where customer.auth_token = @customer_tokenid)
  and CAST (created_at as DATE) = CAST (@CURRENT_DATETIME as Date)
  
  order by earned_points_id desc

)a )<=30)


BEGIN
 Print ('Begin Script 2')

Update customer set customer.status = 'disable',
customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid

IF (@@ROWCOUNT>0)
BEGIN
	Insert into System_Log (customer_id, action_status,created_at,reason)
	Select customer.customer_id,
	'disable',@CURRENT_DATETIME,'Script Scanning'
	 from customer where customer.auth_token = @customer_tokenid
END
 SET @RETURN_NO='001' -- scan time is too frequent                           
	GOTO Err
END

END

-- Check and Blocking Same Train Scan Count <= 15
IF( (select SUBSTRING ( @qrcode, 1 , 5)) = 'Train') 
 
 BEGIN
   
   IF (
(select COUNT(*)+1 from customer_earned_points 
where 
customer_earned_points.customer_id =   (Select customer.customer_id from customer where customer.auth_token = @customer_tokenid)
AND  (select SUBSTRING ( @qrcode, 1 , 8) ) = SUBSTRING ( qr_code, 1, 8 )
  and CAST (created_at as DATE) = CAST (@CURRENT_DATETIME as Date)) >= 15
  )

		 BEGIN
		 Print ('Begin Train 2')

		Update customer set customer.status = 'disable',
		customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid

		IF (@@ROWCOUNT>0)
		BEGIN
			Insert into System_Log (customer_id, action_status,created_at,reason)
			Select customer.customer_id,
			'disable',@CURRENT_DATETIME,'Same Train Scan Count <= 15'
			 from customer where customer.auth_token = @customer_tokenid
		END
		 SET @RETURN_NO='001' -- scan time is too frequent                           
			GOTO Err
		END


END
--END Train



IF Exists (SELECT * FROM CUSTOMER WHERE auth_token = @customer_tokenid )
BEGIN
	If CAST(@CURRENT_DATETIME as time) < '00:00:00' 
   OR CAST(@CURRENT_DATETIME as time) >= '05:30:00'
   
  BEGIN --- Begin check time between 00:30 and 05:30
		-- Begin Limit Checking
    	IF (Select COUNT(*) from customer_earned_points where customer_earned_points.customer_id = 
    	(select customer.customer_id from customer where customer.auth_token =@customer_tokenid)
    	 and CAST(customer_earned_points.created_at as Date) = CAST(@CURRENT_DATETIME as Date)
    	 )<350
    	
		BEGIN -- Begin Limit Checking
		
	IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @customer_tokenid and customer.status='enable')                                                     
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
				
			-- Insert into log mdf 5-05-2016
			EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_SINGAPORE_TIME output	
			
			INSERT INTO CUSTOMER_EARNED_POINTS_Log (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at) VALUES
					(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_SINGAPORE_TIME,@qrcode,@CURRENT_SINGAPORE_TIME)		
			
			
			--INSERT INTO CUSTOMER_EARNED_POINTS_Log (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at) VALUES
			--		(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME)
		
		
			SET @Valid = 1	
			IF (@last_station_code != @current_station_code)
			BEGIN
				
				Print ('Not Same Station')
			    EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_SINGAPORE_TIME output
			    
			    Print('@LAST_SCANNED_TIME_Log')
			     Print(@LAST_SCANNED_TIME_Log)
			     
			     Print('@CURRENT_SINGAPORE_TIME')
			     Print(@CURRENT_SINGAPORE_TIME)
			   
				-- mdf 05052016 for 1 minute
                EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_SINGAPORE_TIME output	
                SELECT @DATE_DIFF = DATEDIFF(Second,@LAST_SCANNED_TIME_Log,@CURRENT_SINGAPORE_TIME)
                
				--SELECT @DATE_DIFF = DATEDIFF(MINUTE,@LAST_SCANNED_TIME_Log,@CURRENT_SINGAPORE_TIME)
						
				
				Print ('@DATE_DIFF')
			    
			    Print (@DATE_DIFF )
				--IF @DATE_DIFF<5
				-- MDF 05052016 By Second
				IF @DATE_DIFF<60
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
			    
			    DECLARE @Last_Active_ScanQR_Code varchar(50)
			    DECLARE @Last_Active_Scan_Time_log datetime
			    DECLARE @Last_Active_Station_Code varchar(50)
			    
			   
			    
	    
			    SET @Last_Active_ScanQR_Code = (SELECT Top 1 customer_earned_points.qr_code from customer_earned_points where customer_earned_points.customer_id =@CUSTOMER_ID order by customer_earned_points.earned_points_id desc)
			    SET @Last_Active_Station_Code = (SELECT asset_type_management.station_code from  asset_type_management where asset_type_management.qr_code_value =@Last_Active_ScanQR_Code)	
			    
			    
			    IF @Last_Active_Station_Code != @current_station_code
			    BEGIN
			     
			    --SET @Last_Active_Scan_Time_log = (Select Top 1 customer_earned_points_log.created_at from customer_earned_points_log where customer_earned_points_log.qr_code = @Last_Active_ScanQR_Code order by customer_earned_points_log.earned_points_id desc)
			    --MDF 05052016
			    /*SET @Last_Active_Scan_Time_log = (Select Top 1 customer_earned_points_log.created_at from customer_earned_points_log where customer_earned_points_log.qr_code = @Last_Active_ScanQR_Code
			    and  customer_earned_points_log.customer_id= @CUSTOMER_ID order by customer_earned_points_log.earned_points_id desc)*/
			     SET @Last_Active_Scan_Time_log = 
			    (Select Top 1 customer_earned_points_log.created_at 
			    from customer_earned_points_log where 
			    customer_earned_points_log.customer_id= @CUSTOMER_ID
			    and customer_earned_points_log.earned_points_id != 
			    (Select MAX(customer_earned_points_log.earned_points_id) from customer_earned_points_log
			    where customer_earned_points_log.customer_id = @CUSTOMER_ID)    
			   	order by customer_earned_points_log.earned_points_id desc)
			   				   	
			   	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_SINGAPORE_TIME output
			   	--MDF 05052016
			   	SELECT @DATE_DIFF = DATEDIFF(SECOND,@Last_Active_Scan_Time_log,@CURRENT_SINGAPORE_TIME)
			   
			    --SELECT @DATE_DIFF = DATEDIFF(MINUTE,@Last_Active_Scan_Time_log,@CURRENT_SINGAPORE_TIME)
			   
			    Print('@LAST_SCANNED_TIME_Log')
			     Print(@Last_Active_Scan_Time_log)
			     
			      Print('@CURRENT_SINGAPORE_TIME')
			     Print(@CURRENT_SINGAPORE_TIME)
			   
			     Print('@DATE_DIFF')
			     Print(@DATE_DIFF)
			  --  IF @DATE_DIFF<5
			  --MDF 05052016
				IF @DATE_DIFF<60
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
	ELSE -- AUTH_TOKEN DOES NOT EXIST
	BEGIN
		SET @RETURN_NO='001'   -- customer does not exist                        
		GOTO Err
	END
	
	
	Err:                                         
	IF @RETURN_NO='001' 
	                          
	BEGIN                                              
		SELECT '0' as response_code, 'Invalid Scan' as response_message , 3 as timer_interval_second
		--SELECT '0' as response_code, 'Invalid Scan' as response_message 
		RETURN                           
	END 
	ELSE IF @RETURN_NO='002' 
	BEGIN  
		SELECT '0' as response_code, 'Scan interval per panel : 24 hours' as response_message , 3 as timer_interval_second
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
	ELSE IF @RETURN_NO='005' 
	BEGIN  
		SELECT '0' as response_code, 'Invalid Scan' as response_message , 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='000' 
	BEGIN  
		SELECT '1' as response_code,'Success' as response_message, @SMALL_IMAGE_URL AS small_banner_url, @SCAN_VALUE as scan_value,@SMALL_WEBSITE_URL AS small_website_url
		, 3 as timer_interval_second
		RETURN 
	END
	
		END
		ELSE
		BEGIN
			SELECT '0' as response_code, 'Daily limit reached' as response_message , 3 as timer_interval_second
		RETURN 
		END -- END Limit Checking

 END -- END check time between 00:30 and 05:30
 
 ELSE 
	BEGIN
	SELECT '0' as response_code, 'Invalid Scan' as response_message , 3 as timer_interval_second
		RETURN 
	END
 
END
ELSE
BEGIN
	SELECT '2' as response_code, 'Multiple logins not allowed' as response_message , 3 as timer_interval_second

END



END

