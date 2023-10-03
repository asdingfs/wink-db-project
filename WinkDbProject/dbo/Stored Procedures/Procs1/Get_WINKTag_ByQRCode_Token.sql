CREATE PROCEDURE [dbo].[Get_WINKTag_ByQRCode_Token]
(
@customer_tokenid VARCHAR(255),                                       
@qrcode VARCHAR(50)
 )                                                                                                                         

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

IF (@customer_tokenid is null or @customer_tokenid ='')
BEGIN
	SELECT '0' as response_code, 'Token cannot empty' as response_message , 3 as timer_interval_second
		RETURN 


END
			    
-- Start Safeguard
--1. Begin check time between 00:30 and 05:30
   
If CAST(@CURRENT_DATETIME as time) > '02:00:00' 
   AND CAST(@CURRENT_DATETIME as time) <= '05:30:00'
   BEGIN
   print('Time')
   
	SELECT '0' as response_code, 'Invalid' as response_message , 3 as timer_interval_second
		RETURN 
	END-- END check time between 00:30 and 05:30
	
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

-- End Safeguard----------------------------------------------------------------------------


	IF EXISTS(SELECT 1 FROM CUSTOMER WHERE auth_token = @customer_tokenid and customer.status='enable')                                                     
	
	BEGIN  -- 4.. Check customer is enable
	     
	     
	     Set @CUSTOMER_ID = (select customer.customer_id from customer where customer.auth_token = @customer_tokenid) 
	     
	     -----------Update Customer Scanned IP 

	
	     -- Asset is Booked ?
	     IF EXISTS (SELECT ASSET_MANAGEMENT_BOOKING.booking_id FROM ASSET_MANAGEMENT_BOOKING WHERE CONVERT(CHAR(10),@CURRENT_DATETIME,111) >= CONVERT(CHAR(10),START_DATE,111) and CONVERT(CHAR(10),@CURRENT_DATETIME,111) <= CONVERT(CHAR(10),END_DATE,111) AND QR_CODE_VALUE = @qrcode
		AND Lower(asset_management_booking.booked_status) = 'true'
		and winktag_id !=0
		)
		
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
			AND asmb.winktag_id !=0
			/*Print('Have booked') 
			Print('@SMALL_IMAGE_URL') 
			Print(@SMALL_IMAGE_URL) */	
				
		
		END
			
			
	     SELECT @MERCHANT_ID = MERCHANT_ID FROM CAMPAIGN WHERE CAMPAIGN_ID = @CAMPAIGN_ID
				
	  
						
			--CHECK LAST SCANNED TIME 
		IF EXISTS(SELECT 1 FROM customer_earned_points_by_winktag WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE = @qrcode)  
			BEGIN
				SELECT TOP 1 @LAST_SCANNED_TIME = LAST_SCANNED_TIME FROM customer_earned_points_by_winktag WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE = @qrcode ORDER BY LAST_SCANNED_TIME DESC

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
				
				SET @RETURN_NO='000'                         
				GOTO Err
				
						
				END
			END
			ELSE -- Don't have the record scan
			BEGIN
			SET @RETURN_NO='000'                      
				GOTO Err
			END
			--CHECK LAST SCANNED TIME 
	     
	     
	     
	
	END 
	ELSE -- Customer disable
	BEGIN
		SET @RETURN_NO='006'   -- Customer disable                     
		GOTO Err
	END
	
	
	Err:    
	IF @RETURN_NO ='000'
	BEGIN
		select '1' as response_code,c.campaign_name,c.campaign_id,b.asset_type_management_id,b.booking_id,b.scan_value,w.video_name,w.survey_url,w.winktag_type,w.wink_content,
					s.small_image_name,s.small_image_url,l.large_image_name,l.large_image_url,'Please watch the video completely and earn the points' as response_message
					 from campaign as c,asset_management_booking as b,campaign_small_image as s ,campaign_large_image as l,
					 campaign_winktag as w
					where c.campaign_id =b.campaign_id 
					and b.image_id= s.id
					and l.campaign_id = c.campaign_id
					and b.winktag_id !=0
					and w.id = b.winktag_id
					and b.qr_code_value = @qrcode
					and CAST (@CURRENT_DATETIME as date) between Cast(b.start_date as date) and Cast(b.end_date as date)

	
	END                                     
	ELSE IF @RETURN_NO='001' 
	                          
	BEGIN                                              
		SELECT '0' as response_code, 'Invalid Code' as response_message , 3 as timer_interval_second
		--SELECT '0' as response_code, 'Invalid Scan' as response_message 
		RETURN                           
	END 
	ELSE IF @RETURN_NO='002' 
	BEGIN  
		SELECT '0' as response_code, 'Limited to one view per day' as response_message , 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='003' 
	BEGIN  
		SELECT '0' as response_code, 'Invalid Code' as response_message , 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='004' 
	BEGIN  
		SELECT '0' as response_code, 'Insert Fail' as response_message , 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='005' 
	BEGIN  
		SELECT '0' as response_code, 'Invalid Code' as response_message , 3 as timer_interval_second
		RETURN 
	END
	ELSE IF @RETURN_NO='006' 
	BEGIN  
		SELECT '0' as response_code, 'Please login-in again ' as response_message , 3 as timer_interval_second
		RETURN 
	END
	
	 
END

