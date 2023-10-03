CREATE PROC [dbo].[CONVERT_WINKS_TO_eVOUCHERS]
@customer_tokenid VARCHAR(255),
@winks_to_redeem int

AS

DECLARE @CUSTOMER_ID INT
DECLARE @CUSTOMER_BALANCED_WINKS INT
DECLARE @EVOUCHER_AMOUNT DECIMAL (10,2)
DECLARE @EVOUCHER_EXPIRED_DATE DateTime
DECLARE @EVOUCHER_CODE varchar(10)
DECLARE @EVOUCHER_ID INT
--DECLARE @EVOUCHER_STATUS BIT
DECLARE @USED_WINKS INT
DECLARE @RATE_VALUE INT
DECLARE @CURRENT_DATETIME DATETIME
DECLARE @EMAIL VARCHAR(100)
DECLARE @RETURN_NO varchar(10)

BEGIN

  EXEC dbo.GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME output
  
    --WINK Expired
  /*  If CAST(@CURRENT_DATETIME as datetime) >= Cast('2020-12-29 00:00:00' as datetime)
   AND CAST(@CURRENT_DATETIME as datetime) <= Cast('2020-12-29 05:30:00' as datetime)
   BEGIN
    
   SELECT '0' as response_code, 'From 00:00 hrs 01 Jan 2021 to 05:30 hrs 01 Jan 2021, no wink redemption and/or evoucher conversion allowed' as response_message
   RETURN 
   END*/

   /*
   BEGIN
    
   SELECT '0' as response_code, 'From 00:00 hrs 01 Jan 2018 to 05:30 hrs 01 Jan 2018,no wink redemption and/or evoucher conversion allowed ' as response_message
   RETURN 
   END
   */
	-- END WINK Expired 00:30 and 05:30
  If CAST(@CURRENT_DATETIME as datetime) >= Cast('2022-12-12 00:00:00' as datetime)
   AND CAST(@CURRENT_DATETIME as datetime) <= Cast('2022-12-12 23:59:59' as datetime)
   BEGIN
    
   SELECT '0' as response_code, 'From 00:00 hrs 12 Dec 2022 to 23:59 hrs 12 Dec 2022, no wink redemption and/or evoucher conversion allowed' as response_message
   RETURN 
   END
  

  /*IF ((Select COUNT(*) from customer_earned_points 
      where CAST (customer_earned_points.created_at as date)
      = CAST (@CURRENT_DATETIME as DATE)
      and customer_earned_points.customer_id = (select customer.customer_id from 
      customer where customer.auth_token = @customer_tokenid))=>250)*/
      
	/*IF EXISTS( select customer_id from customer_earned_points as c 
	where CAST(last_scanned_time as date) = @CURRENT_DATETIME
	and customer_id = (select customer.customer_id from 
	customer where customer.auth_token = @customer_tokenid)
	group by customer_id,CAST(last_scanned_time as date)
	Having (
	DATEDIFF(Hour,MIN(last_scanned_time),MAX(last_scanned_time))<=6
	and 
	COUNT(*)>=250))
	 BEGIN
	 Declare @balanced_Winks int
	 Declare @today_earned_WINKs int
	 SET @balanced_Winks =(Select (total_winks-used_winks-confiscated_winks)
	 from CUSTOMER_BALANCE WHERE CUSTOMER_ID = @CUSTOMER_ID)
	 SET @today_earned_WINKs = (ISNULL((select sum(w.total_winks) from customer_earned_winks as w),0))

	 IF(@winks_to_redeem > (@balanced_Winks-@today_earned_WINKs))
	 BEGIN
	 Update customer set customer.status = 'disable',
	 customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid

		IF (@@ROWCOUNT>0)
		BEGIN
		Insert into System_Log (customer_id, action_status,created_at,reason)
		Select customer.customer_id,
		'disable',@CURRENT_DATETIME,'convert to evoucher'
		 from customer where customer.auth_token = @customer_tokenid
		END
		
		SET @RETURN_NO='001' -- scan time is too frequent                           
		GOTO Err
	 END
	 END*/


    IF (@winks_to_redeem >0)
    BEGIN
    
    IF EXISTS (SELECT 1 FROM CUSTOMER WHERE auth_token = @customer_tokenid) 
    BEGIN
	IF EXISTS(SELECT 1 FROM CUSTOMER WHERE auth_token = @customer_tokenid and customer.status ='enable')                            
	BEGIN 
		SELECT @CUSTOMER_ID = CUSTOMER_ID, @EMAIL = email FROM CUSTOMER WHERE auth_token = @customer_tokenid 
		--print(@EMAIL)
		IF EXISTS(SELECT * FROM customer_balance WHERE customer_id = @CUSTOMER_ID AND @winks_to_redeem <= (total_winks-used_winks-confiscated_winks))
		BEGIN
			SELECT @EVOUCHER_AMOUNT = @winks_to_redeem*RATE_VALUE,@RATE_VALUE =rate_value FROM RATE_CONVERSION WHERE RATE_CODE = 'cents_per_wink'
			--- Convert eVoucher Cent To Dollar------------------------
			SET @EVOUCHER_AMOUNT = @EVOUCHER_AMOUNT/100
			SET @CURRENT_DATETIME = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');
			SELECT @EVOUCHER_EXPIRED_DATE = DATEADD(day, system_value , @CURRENT_DATETIME) FROM system_key_value WHERE system_key = 'evoucher_expire_after_days'
			
			EXEC GET_RANDOM_NO @EVOUCHER_CODE OUTPUT
			
			WHILE EXISTS(SELECT 1 FROM customer_earned_evouchers WHERE eVoucher_code = @EVOUCHER_CODE)
			BEGIN
				EXEC GET_RANDOM_NO @EVOUCHER_CODE OUTPUT
			END
			UPDATE CUSTOMER_BALANCE SET USED_WINKS = USED_WINKS+@winks_to_redeem, TOTAL_EVOUCHERS = TOTAL_EVOUCHERS+1 
			, total_redeemed_amt = total_redeemed_amt+@EVOUCHER_AMOUNT
				WHERE CUSTOMER_ID = @CUSTOMER_ID
				AND 
				(@winks_to_redeem)
				<=
			    (Select (total_winks-used_winks-confiscated_winks) from CUSTOMER_BALANCE WHERE CUSTOMER_ID = @CUSTOMER_ID)
					
			IF(@@ROWCOUNT>0)
			BEGIN
				
				INSERT INTO customer_earned_evouchers
				([customer_id],[redeemed_winks],[eVoucher_code],[eVoucher_amount],[expired_date],[created_at],[used_status],[updated_at]) VALUES
				(@CUSTOMER_ID,@winks_to_redeem,@EVOUCHER_CODE,@EVOUCHER_AMOUNT,@EVOUCHER_EXPIRED_DATE,@CURRENT_DATETIME,0,@CURRENT_DATETIME)
				
				SET @EVOUCHER_ID = SCOPE_IDENTITY()
				
			   -- IF (Select USED_WINKS = USED_WINKS+@winks_to_redeem from CUSTOMER_BALANCE WHERE CUSTOMER_ID = @CUSTOMER_ID)<=
			   -- (Select total_winks from CUSTOMER_BALANCE WHERE CUSTOMER_ID = @CUSTOMER_ID)
			
				SELECT @CUSTOMER_BALANCED_WINKS = (TOTAL_WINKS - USED_WINKS - confiscated_winks), 
				@USED_WINKS = USED_WINKS
				FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID = @CUSTOMER_ID
				
				SELECT '1' as response_code, 'Success' as response_message, 
				@EVOUCHER_ID as EVOUCHER_ID,
				@EVOUCHER_CODE AS EVOUCHER_CODE,
				@EVOUCHER_AMOUNT AS EVOUCHER_AMOUNT,
				@EVOUCHER_EXPIRED_DATE AS EXPIRED_DATE,
				@RATE_VALUE AS RATE_VALUE,
				@USED_WINKS AS USED_WINKS,
				@winks_to_redeem AS CUSTOMER_REDEEMED_WINKS,
				@CUSTOMER_BALANCED_WINKS AS CUSTOMER_BALANCED_WINKS,
				@EMAIL AS EMAIL
				 
				RETURN
			END
			ELSE
			BEGIN
				SELECT '0' as response_code, 'Insert Fails' as response_message 
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' as response_code, 'Redeemed WINKs are greater than your balanced winks' as response_message 
			RETURN
		END
	END
	BEGIN
		SELECT '0' as response_code, 'Please login-in again' as response_message 
		RETURN
	END
	
	END
	ELSE 
	
	BEGIN
	SELECT '2' as response_code, 'Multiple logins not allowed' as response_message 
	
	END
	
	END
	ELSE
	BEGIN
	SELECT '0' as response_code, 'Invalid WINKs to redeem' as response_message 
		RETURN
	END
	
	
	Err:                                         
	IF @RETURN_NO='001' 
	                          
	BEGIN                                              
		SELECT '0' as response_code, 'Please login-in again' as response_message 
		--SELECT '0' as response_code, 'Invalid Scan' as response_message 
		RETURN                           
	END 
	
END


