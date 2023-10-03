CREATE PROC [dbo].[CONVERT_WINKS_TO_eVOUCHERS_Bak27032016]
@customer_tokenid VARCHAR(50),
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

BEGIN

	IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @customer_tokenid)                            
	BEGIN 
		SELECT @CUSTOMER_ID = CUSTOMER_ID, @EMAIL = email FROM CUSTOMER WHERE auth_token = @customer_tokenid 
		--print(@EMAIL)
		IF EXISTS(SELECT * FROM customer_balance WHERE customer_id = @CUSTOMER_ID AND @winks_to_redeem <= (total_winks-used_winks))
		BEGIN
			SELECT @EVOUCHER_AMOUNT = @winks_to_redeem*RATE_VALUE,@RATE_VALUE =rate_value FROM RATE_CONVERSION WHERE RATE_CODE = 'cents_per_wink'
			--- Convert eVoucher Cent To Dollar------------------------
			SET @EVOUCHER_AMOUNT = @EVOUCHER_AMOUNT/100
			SET @CURRENT_DATETIME = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');
			SELECT @EVOUCHER_EXPIRED_DATE = DATEADD(day, system_value , @CURRENT_DATETIME) FROM system_key_value WHERE system_key = 'evoucher_expire_after_days'
			
			EXEC GET_RANDOM_NO @EVOUCHER_CODE OUTPUT
			
			WHILE EXISTS(SELECT * FROM customer_earned_evouchers WHERE eVoucher_code = @EVOUCHER_CODE)
			BEGIN
				EXEC GET_RANDOM_NO @EVOUCHER_CODE OUTPUT
			END
			
			INSERT INTO customer_earned_evouchers
			([customer_id],[redeemed_winks],[eVoucher_code],[eVoucher_amount],[expired_date],[created_at],[used_status],[updated_at]) VALUES
			(@CUSTOMER_ID,@winks_to_redeem,@EVOUCHER_CODE,@EVOUCHER_AMOUNT,@EVOUCHER_EXPIRED_DATE,@CURRENT_DATETIME,0,@CURRENT_DATETIME)
			SET @EVOUCHER_ID = SCOPE_IDENTITY()
			
			IF(@@ROWCOUNT>0)
			BEGIN
				UPDATE CUSTOMER_BALANCE SET USED_WINKS = USED_WINKS+@winks_to_redeem, TOTAL_EVOUCHERS = TOTAL_EVOUCHERS+1 WHERE CUSTOMER_ID = @CUSTOMER_ID
				SELECT @CUSTOMER_BALANCED_WINKS = (TOTAL_WINKS - USED_WINKS), 
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
			SELECT '0' as response_code, 'Invalid! The total winks you want to redeem is greater than your balanced winks' as response_message 
			RETURN
		END
	END
	BEGIN
		SELECT '0' as response_code, 'Customer does not exist' as response_message 
		RETURN
	END
	
END
