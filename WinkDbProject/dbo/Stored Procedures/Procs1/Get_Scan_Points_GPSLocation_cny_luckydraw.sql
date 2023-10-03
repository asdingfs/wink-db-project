
CREATE PROC [dbo].[Get_Scan_Points_GPSLocation_cny_luckydraw]          
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

--lucky draw
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_SINGAPORE_TIME output
Declare @prize varchar(100)
Declare @winner varchar(250)
DECLARE @WINNER_COUNT INT
DECLARE @LUCKYDRAW_QR VARCHAR(100)
SET @LUCKYDRAW_QR = 'SingtelTVCNY_SingtelTVCNY_01_49190'
SET @WINNER_COUNT = (SELECT TOP 1 WINNER_COUNT FROM luckydraw_winnercount WHERE CAST(luckydraw_date AS DATE) = CAST(@CURRENT_SINGAPORE_TIME AS DATE))
Set @prize = '$38';
--lucky draw

			    
-- Start Safeguard
--1. Begin check time between 00:30 and 05:30
   
--If CAST(@CURRENT_DATETIME as time) > '00:00:00' 
  -- AND CAST(@CURRENT_DATETIME as time) <= '05:30:00'
   --BEGIN
   --print('Time')
   
	--SELECT '0' as response_code, 'Invalid Scan' as response_message , 3 as timer_interval_second
		--RETURN 
	--END-- END check time between 00:30 and 05:30

--lucky draw
If CAST(@CURRENT_DATETIME as time) < '08:00:00' OR CAST(@CURRENT_DATETIME as time) > '23:59:00'
  
BEGIN    
	SELECT '0' as response_code, 'Invalid Scan' as response_message , 3 as timer_interval_second
	RETURN 
END
--lucky draw

	
-- 2. Check Multiple Login

IF NOT Exists (SELECT 1 FROM CUSTOMER WHERE auth_token = @customer_tokenid )

BEGIN
	     SELECT '2' as response_code, 'Multiple logins not allowed' as response_message , 3 as timer_interval_second
        RETURN 
END  

--3.. Begin Daily Limit Checking	
IF (Select COUNT(*) from customer_earned_points where customer_earned_points.customer_id = 
    	(select customer.customer_id from customer where customer.auth_token =@customer_tokenid)
    	 and CAST(customer_earned_points.created_at as Date) = CAST(@CURRENT_DATETIME as Date)
    	 )>=250
   		BEGIN
		SELECT '0' as response_code, 'Daily limit reached' as response_message , 3 as timer_interval_second
        RETURN 
        END  -- END check time between 00:30 and 05:30

-- 4. GSS
If ( SUBSTRING ( @qrcode, 1 , 3) ='GSS')
   
   BEGIN
   
   IF EXISTS (Select 1 from GSS_event,customer where GSS_event. qr_code_value = @qrcode and 
   GSS_event.email = customer.email and customer.auth_token = @customer_tokenid )
     
   BEGIN
   
   IF ((select COUNT(*) from customer_earned_points where customer_earned_points.qr_code = @qrcode)> 0)
   BEGIN
    
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
   
   
-- 5. Check and Blocking Running By Script 10 panel within 30 second
   
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
END
 SET @RETURN_NO='001' -- Invalid scan                          
	GOTO Err
END

END


--6. Check and Blocking Same Train Scan Count <= 15
IF( (select SUBSTRING ( @qrcode, 1 , 5)) = 'Train') 
 
 BEGIN
   
   IF (
(select COUNT(*)+1 from customer_earned_points 
where 
customer_earned_points.customer_id =   (Select customer.customer_id from customer where customer.auth_token = @customer_tokenid)
AND  (select SUBSTRING ( @qrcode, 1 , 9) ) = SUBSTRING ( qr_code, 1, 9 )
  and CAST (created_at as DATE) = CAST (@CURRENT_DATETIME as Date)) >= 128
  )

		 BEGIN
		 Print ('Begin Train 2')

		Update customer set customer.status = 'disable',
		customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid

		IF (@@ROWCOUNT>0)
		BEGIN
			Insert into System_Log (customer_id, action_status,created_at,reason)
			Select customer.customer_id,
			'disable',@CURRENT_DATETIME,'Same Train Scan Count >= 72'
			 from customer where customer.auth_token = @customer_tokenid
		END
		 SET @RETURN_NO='001' -- scan time is too frequent                           
			GOTO Err
		END


END
--END Train

-- End Safeguard----------------------------------------------------------------------------


	IF EXISTS(SELECT 1 FROM CUSTOMER WHERE auth_token = @customer_tokenid and customer.status='enable')                                                     
	
	BEGIN  -- 4.. Check customer is enable
	     
	     
	     Set @CUSTOMER_ID = (select customer.customer_id from customer where customer.auth_token = @customer_tokenid) 
	     
	     -----------Update Customer Scanned IP 
	     Update customer set customer.ip_scanned = @ip_address where customer_id=@CUSTOMER_ID
	
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
			/*Print('Have booked') 
			Print('@SMALL_IMAGE_URL') 
			Print(@SMALL_IMAGE_URL) */	
				
		
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
		
		SET @CAMPAIGN_ID =5 --- Set Default Global Campagin ID
		
		SET @BOOKING_ID = 0 --- Set Default Booking ID
		SELECT @SMALL_IMAGE_URL = small_image_name ,@SMALL_WEBSITE_URL = small_image_url FROM campaign_small_image WHERE CAMPAIGN_ID = @CAMPAIGN_ID
		and small_image_status = '1'
		
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
		
		SET @CAMPAIGN_ID =5 --- Set Default Global Campagin ID
		
		SET @BOOKING_ID = 0 --- Set Default Booking ID
		SELECT @SMALL_IMAGE_URL = small_image_name ,@SMALL_WEBSITE_URL = small_image_url FROM campaign_small_image WHERE CAMPAIGN_ID = @CAMPAIGN_ID
		and small_image_status = '1'
		
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
		
			
	   SELECT @MERCHANT_ID = MERCHANT_ID FROM CAMPAIGN WHERE CAMPAIGN_ID = @CAMPAIGN_ID
				
	    
	    --- Start to Check Train Interval  
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
					
			SET @Valid = 1	
			--Different Station Code
			--IF (@last_station_code != @current_station_code) 29072016
			IF (@last_station_code != @current_station_code AND (@last_station_code !='Train' 
			And @current_station_code !='Train'))
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
						
			--CHECK LAST SCANNED TIME 
			IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE = @qrcode)  
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
					
					--INSERT INTO customer_earned_points table
					--UPATE CUSTOMER_BALANCE TABLE
					
					INSERT INTO CUSTOMER_EARNED_POINTS (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at,ip_address,GPS_location) VALUES
					(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME,@ip_address,@GPS_location)
					IF(@@ROWCOUNT>0)
					BEGIN
						IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
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
								
				--INSERT INTO customer_earned_points table
				--UPATE CUSTOMER_BALANCE TABLE
				INSERT INTO CUSTOMER_EARNED_POINTS (customer_id,campaign_booking_id,campaign_id,points,last_scanned_time,qr_code,created_at,ip_address,GPS_location) VALUES
					(@CUSTOMER_ID,@BOOKING_ID,@CAMPAIGN_ID,@SCAN_VALUE,@CURRENT_DATETIME,@qrcode,@CURRENT_DATETIME,@ip_address,@GPS_location)
				
				IF(@@ROWCOUNT>0)
				BEGIN
					IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
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
	ELSE -- Customer disable
	BEGIN
		SET @RETURN_NO='006'   -- Customer disable                     
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
		SELECT '0' as response_code, 'Scan interval per code : 24 hours' as response_message , 3 as timer_interval_second
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
	ELSE IF @RETURN_NO='006' 
	BEGIN  
		SELECT '0' as response_code, 'Please login-in again ' as response_message , 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='000' 
	BEGIN  
		

	--select @prize = prize from hof_luckydraw where qr_code = @qrcode and customer_id =0
	 /*    print (@prize)
	 	select @prize = prize from hof_luckydraw where qr_code = @qrcode
	 	 print (@prize)
	 	if(@prize !='')
       -- if((select COUNT(*) from hof_luckydraw where customer_id = @customer_id)=0 and @prize !='')
       if((select COUNT(*) from hof_luckydraw where customer_id = @customer_id and qr_code=@qrcode)=0 and @prize !='')
        Begin
        --update hof_luckydraw set customer_id = @CUSTOMER_ID where qr_code = @qrcode and customer_id =0 
        set @winner = @prize
	    END*/

		

		IF NOT EXISTS(SELECT * FROM hof_luckydraw WHERE qr_code = @LUCKYDRAW_QR AND CAST(created_at AS date) = CAST(@CURRENT_DATETIME as date))
		BEGIN

			If NOT EXISTS(SELECT * FROM hof_luckydraw WHERE qr_code = @LUCKYDRAW_QR AND CUSTOMER_ID = @CUSTOMER_ID)
			BEGIN
				Declare @count int

				IF((SELECT COUNT (*) from customer_earned_points 
				WHERE qr_code = @LUCKYDRAW_QR
				and CAST(customer_earned_points.created_at as DATE) = CAST (@CURRENT_DATETIME as date)) = @WINNER_COUNT)
				BEGIN
					SET @winner = 'Huat ah! You have won ' + @prize + ' ang bao! Winners will be contacted via email. You have earned 2 points.'

					--Huat ah! You have won $38 ang bao! Winners will be contacted via email

					DECLARE @winner_date datetime = (select TOP 1 created_at from customer_earned_points where qr_code = @LUCKYDRAW_QR and customer_id = @CUSTOMER_ID AND cast(customer_earned_points.created_at as DATE) = CAST (@CURRENT_DATETIME as date) ORDER BY CREATED_AT DESC)
					
					INSERT INTO [dbo].[hof_luckydraw]
					   ([qr_code]
					   ,[customer_id]
					   ,[created_at]
					   ,[updated_at]
					   ,[prize]
					   ,[event_name]
					   )
					VALUES
					   (@qrcode
					   ,@CUSTOMER_ID
					   ,@winner_date--@CURRENT_SINGAPORE_TIME
					   ,@winner_date--@CURRENT_SINGAPORE_TIME
					   ,@prize
					   ,'CNY Lucky Draw 2017'
					   )
				END
					
			END
			
				
		END
  
	    If(@@ERROR=0)
	    Begin
		SELECT '1' as response_code,'Success' as response_message, @SMALL_IMAGE_URL AS small_banner_url, @SCAN_VALUE as scan_value,@SMALL_WEBSITE_URL AS small_website_url
		, 3 as timer_interval_second, @winner as prize
		RETURN 
		END
	END
	 
END
