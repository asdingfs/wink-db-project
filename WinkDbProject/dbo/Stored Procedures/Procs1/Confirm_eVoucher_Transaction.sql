CREATE PROCEDURE [dbo].[Confirm_eVoucher_Transaction]
(@customer_tokenid varchar(255),
 @eVoucher_verification_id int)

AS
BEGIN
	DECLARE @CURRENT_Date DateTime
	DECLARE @CUSTOMER_ID INT
	DECLARE @Default_Value int
	DECLARE @INCREMENT_Value numeric(3,0)
	DECLARE @TRANS_REF_NO INT
	DECLARE @EVOUCHER_ID INT
	DECLARE @EVOUCHER_CODE VARCHAR(50)
	DECLARE @MERCHANT_ID INT
	DECLARE @BRANCH_CODE INT
	DECLARE @EVOUCHER_VALUE DECIMAL(10,2)
	DECLARE @EMAIL VARCHAR(100)
	--ADD NEW VARIABLE ZIN
	DECLARE @CUSTOMER_NAME VARCHAR(100)
	
	-- ADD Verification Code
	
	DECLARE @Verification_Code VARCHAR(100)

	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT
-- 1) CHECK CUSTOMER  
-- 2) CHECK eVoucher verification
-- 3) INSERT TO TRANSACTION 
-- 4) UPDATE EVOUCHER USED  
	IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @customer_tokenid) 
                      
	BEGIN 
	
		SELECT TOP 1 @CUSTOMER_ID = CUSTOMER_ID, @EMAIL=email, @CUSTOMER_NAME = customer.first_name + ' ' + customer.last_name FROM CUSTOMER WHERE auth_token = @customer_tokenid 
		IF EXISTS (SELECT eVoucher_verification.eVoucher_verification_id 
		FROM eVoucher_verification)
			BEGIN
		
				-- GET EVOUCHER ID
				SELECT @EVOUCHER_ID = eVoucher_verification.eVoucher_id ,
				@BRANCH_CODE = eVoucher_verification.branch_id,
				@Verification_Code = eVoucher_verification.verification_code
				 FROM eVoucher_verification 
				WHERE eVoucher_verification.eVoucher_verification_id = @eVoucher_verification_id
				--GET EVOUCHER DATA
				IF EXISTS (SELECT customer_earned_evouchers.earned_evoucher_id FROM customer_earned_evouchers
				WHERE customer_earned_evouchers.earned_evoucher_id=@EVOUCHER_ID AND customer_earned_evouchers.used_status=0)
					BEGIN
					SELECT @EVOUCHER_CODE=eVoucher_code,
					@EVOUCHER_VALUE=eVoucher_amount
					FROM customer_earned_evouchers 
					WHERE customer_earned_evouchers.earned_evoucher_id=@EVOUCHER_ID
				
					---CHECK THE CURRENT TRANSACTION ID
					SET @INCREMENT_Value= CONVERT(numeric(3,0),rand() * 999)
					IF EXISTS (SELECT TRANSACTION_ID FROM eVoucher_transaction)
					BEGIN
					SET @TRANS_REF_NO =(SELECT TOP 1 TRANSACTION_ID  FROM eVoucher_transaction ORDER BY TRANSACTION_ID DESC)
					END
					ELSE
					BEGIN 
					SET @TRANS_REF_NO = 1000000000
	            	
				END
				
					SET @TRANS_REF_NO = @TRANS_REF_NO+@INCREMENT_Value
				

					SET @MERCHANT_ID = ISNULL((SELECT branch.merchant_id FROM branch WHERE branch.branch_code= @BRANCH_CODE),0)
					-- GET LOCAL TIME
					DECLARE @CURRENT_DATETIME datetimeoffset = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');
					-- INSERT TRANSACTION
        
						INSERT INTO eVoucher_transaction
					([transaction_id]
					,[merchant_id]
					,[branch_code]
					,[eVoucher_id]
					,[eVoucher_amount]
					,[customer_id]
					,[customer_name]
					,[customer_email]
					,[created_at]
					,[updated_at]
					,[verification_id]
					,[verification_code]
					)
					VALUES
					(@TRANS_REF_NO ,
					@MERCHANT_ID,
					@BRANCH_CODE,
					@EVOUCHER_ID,
					@EVOUCHER_VALUE,
					@CUSTOMER_ID,
					@CUSTOMER_NAME,
					@EMAIL,
					@CURRENT_DATETIME,
					@CURRENT_DATETIME,
					@eVoucher_verification_id,
					@Verification_Code
					)
				-- UPDATE EVOUCHER USED
					IF(@@ROWCOUNT>0)
					BEGIN
					UPDATE customer_earned_evouchers SET used_status = 1,
					customer_earned_evouchers.updated_at = @CURRENT_DATE
				    WHERE earned_evoucher_id = @EVOUCHER_ID
					UPDATE customer_balance SET total_used_evouchers = total_used_evouchers+1 WHERE customer_balance.customer_id= @CUSTOMER_ID
					-- IF NOT UPDATE
					/*IF (@@ROWCOUNT=0)
					BEGIN
					DELETE eVoucher_transaction WHERE eVoucher_transaction.transaction_id = @TRANS_REF_NO
					END
					ELSE*/
					 IF (@@ROWCOUNT>0)
						BEGIN
						SELECT merchant.merchant_id,merchant.first_name,merchant.last_name,
						branch.branch_name,branch.branch_code,branch.branch_id,eVoucher_transaction.eVoucher_amount,
						'1' AS response_code,
						@EVOUCHER_CODE AS evoucher_code,
						@EMAIL AS email
						FROM merchant,branch,eVoucher_transaction
						WHERE eVoucher_transaction.merchant_id = merchant.merchant_id AND
						eVoucher_transaction.branch_code = branch.branch_code
						AND eVoucher_transaction.transaction_id =@TRANS_REF_NO
						RETURN
						END
					END
					ELSE
					BEGIN 
					SELECT '0' as response_code, 'INSERT FAIL' as response_message 
					RETURN
			
					END
				END

		ELSE 
			BEGIN
			SELECT '0' as response_code, 'eVoucher not valid' as response_message 
			RETURN
			
			END
		
	END
ELSE
	BEGIN
		SELECT '0' as response_code, 'Customer does not exist' as response_message 
		RETURN
	END
	
	END
	
END
