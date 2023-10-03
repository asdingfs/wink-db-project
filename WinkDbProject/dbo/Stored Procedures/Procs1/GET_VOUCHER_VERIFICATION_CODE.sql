CREATE PROC [dbo].[GET_VOUCHER_VERIFICATION_CODE]
@customer_tokenid VARCHAR(255),
@eVoucher_id VARCHAR(50),
@branch_code int
AS

DECLARE @CUSTOMER_ID INT
DECLARE @VERIFICATION_CODE VARCHAR(12)
DECLARE @VERIFICATION_VALID_TILL DATETIME
DECLARE @VERIFICATION_ID INT
DECLARE @CURRENT_DATETIME DATETIME
DECLARE @IS_LOCKED INT
DECLARE @VALID_IN_MINUTE INT

BEGIN
	
	--1) CHECK TOKEN_ID EXISTS OR NOT. IF EXISTS, GET CUTOMER_ID--
	--2) CHECK BRANCH ID EXISTS OR NOT. 
	--3) IF EXISTS BRANCH ID, CHECK EVOUCHER CODE EXISTS OR NOT
	--4) IF EXISTS EVOUCHER CODE, GENERATE VERIFICATION CODE 
	--5) INSERT INTO eVoucher_verification

    --0) CHECK ALREADY EXISTS AND LOCK TIME IS GREATER THAN CURRENT TIME 
    SET @CURRENT_DATETIME = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');
    SET @IS_LOCKED = 0
    
   /* IF EXISTS (SELECT * FROM eVoucher_verification WHERE eVoucher_verification.eVoucher_id = @eVoucher_id)
    BEGIN 
		SELECT @VERIFICATION_VALID_TILL = eVoucher_verification.valid_till FROM eVoucher_verification
		WHERE eVoucher_verification.eVoucher_id =@eVoucher_id
		-- CHECK VERIFICATION IS GRETER THAN CURRENT TIME 
		
			--IF ( CONVERT(DATETIME,@VERIFICATION_VALID_TILL  ,110)
			--		  > CONVERT(DATETIME,@CURRENT_DATETIME,110))
			
	END
			
	-- CHECK IS IT LOCKED ?*/

	--- Check Account Locked
   IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @customer_tokenid and customer.status='disable') --CUSTOMER EXISTS                           
    BEGIN
   SELECT '4' as response_code, 'Your account is locked. Please contact customer service.' as response_message 
	
		RETURN 
	END-- END

	--- End Check Account Locked
	
	-- Check Customer Token 
	IF Exists ( select * from customer where customer.auth_token =@customer_tokenid)
	BEGIN
	BEGIN		
		    
	--1) CHECK TOKEN_ID EXISTS OR NOT. IF EXISTS, GET CUTOMER_ID--
	
	IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @customer_tokenid and customer.status='enable') --CUSTOMER EXISTS                           
	BEGIN
		SELECT TOP 1 @CUSTOMER_ID = CUSTOMER_ID FROM CUSTOMER WHERE auth_token = @customer_tokenid 
		
		--2) CHECK BRANCH ID EXISTS OR NOT
		--IF EXISTS(SELECT * FROM BRANCH WHERE branch_code = @branch_code) --BRANCH ID EXISTS
		IF EXISTS(SELECT * FROM BRANCH WHERE branch_code = @branch_code AND branch_status = '1') --BRANCH ID EXISTS
		BEGIN
		      	
			--3) CHECK EVOUCHER CODE EXISTS OR NOT
			IF EXISTS(SELECT * FROM CUSTOMER_EARNED_EVOUCHERS WHERE earned_evoucher_id = @eVoucher_id AND CUSTOMER_ID = @CUSTOMER_ID AND used_status = 0 AND ((SELECT DATEDIFF(DAY,@CURRENT_DATETIME,expired_date))>=0))
			BEGIN
				--4) GET VERIFICATION CODE 
				SELECT @VERIFICATION_CODE= CONVERT(numeric(12,0),rand() * 899999999999) + 100000000000
				WHILE EXISTS(SELECT * FROM eVoucher_verification WHERE eVoucher_verification.verification_code = @VERIFICATION_CODE)
			BEGIN
				--SELECT @VERIFICATION_CODE= CONVERT(numeric(8,0),rand() * 89999999) + 10000000
				SELECT @VERIFICATION_CODE= CONVERT(numeric(12,0),rand() * 899999999999) + 100000000000
			END
				print (@VERIFICATION_CODE)

				--5) INSERT INTO eVoucher_verification
				
			
				SELECT @VERIFICATION_VALID_TILL = DATEADD(second,system_value,@CURRENT_DATETIME)FROM system_key_value WHERE system_key = 'evoucher_lock_seconds'
				
				INSERT INTO eVoucher_verification
				(eVoucher_id,eVoucher_code,verification_code,customer_id,branch_id,created_at,valid_till) VALUES 
				(@eVoucher_id,@eVoucher_id,@VERIFICATION_CODE,@CUSTOMER_ID,@branch_code,@CURRENT_DATETIME,@VERIFICATION_VALID_TILL)
				SET @VERIFICATION_ID = SCOPE_IDENTITY();
				IF(@@ROWCOUNT>0)
				BEGIN
				   
				   
				   SET @VALID_IN_MINUTE = DATEDIFF(MINUTE,CAST(@CURRENT_DATETIME As datetime),CAST(@VERIFICATION_VALID_TILL As datetime))

					--SELECT '1' as response_code, 'Success' as response_message, @VERIFICATION_VALID_TILL AS VERIFICATION_VALID_TILL, @VERIFICATION_CODE AS VERIFICATION_CODE
					SELECT eVoucher_verification.eVoucher_verification_id,
					 verification_code,valid_till,
					 @VALID_IN_MINUTE AS valid_in_minute,
					'1' as response_code
					 FROM eVoucher_verification WHERE eVoucher_verification.eVoucher_verification_id =@VERIFICATION_ID
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
				SELECT '0' as response_code, 'eVoucher Code is not valid' as response_message 
				RETURN
			END
			
		END
		ELSE
		BEGIN
			SELECT '0' as response_code, 'Invalid branch code' as response_message 
			RETURN
		END
		
	END
	ELSE-- CUSTOMER DOES NOT EXISTS
	BEGIN
		SELECT '0' as response_code, 'Customer is not authorized' as response_message 
		RETURN
	END
	
	END
	END
	ELSE-- Token Does not exists
	BEGIN
		SELECT '3' as response_code, 'Multiple logins not allowed' as response_message 
		RETURN
	END
	
END



/*Select * from eVoucher_verification

Alter table eVoucher_verification add eVoucher_id int Not Null Default 0

Select * from customer_earned_evouchers

Select * from customer*/

