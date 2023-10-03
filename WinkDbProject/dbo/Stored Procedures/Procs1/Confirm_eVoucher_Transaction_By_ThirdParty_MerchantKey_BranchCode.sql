CREATE PROCEDURE [dbo].[Confirm_eVoucher_Transaction_By_ThirdParty_MerchantKey_BranchCode]
(@secret_key varchar(255),
 @eVoucher_verification_code varchar(50),
 @branch_code varchar(50)
 
  )

AS
BEGIN
	DECLARE @STAFF_ID INT
	DECLARE @Default_Value int
	DECLARE @INCREMENT_Value numeric(3,0)
	DECLARE @TRANS_REF_NO INT
	DECLARE @EVOUCHER_ID INT
	DECLARE @EVOUCHER_CODE VARCHAR(50)
	DECLARE @MERCHANT_ID INT
	--DECLARE @BRANCH_CODE INT
	DECLARE @EVOUCHER_VALUE DECIMAL(10,2)
	DECLARE @CUSTOMER_ID INT
	DECLARE @eVoucher_verification_id int
	DECLARE @VALID_TIME DATETIME
	DECLARE @TIME_INTERVAL INT
	DECLARE @CUSTOMER_EMAIL VARCHAR(100)

	--ADD NEW VARIABLE ZIN
	DECLARE @CUSTOMER_NAME VARCHAR(100)

	-- GET LOCAL TIME
	DECLARE @CURRENT_DATETIME datetimeoffset = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');
-- 1) CHECK Merchant / Third Party Key
-- 2) CHECK BRANCH CODE / VERIFICATION CODE
-- 2) CHECK eVoucher verification / Authentication Branch 
-- 3) INSERT TO TRANSACTION 
-- 4) UPDATE EVOUCHER USED  
	--IF EXISTS(SELECT * FROM staff WHERE auth_token = @staff_tokenid) 
                      

	     --  1) CHECK Merchant / Third Party Key  
		SET @MERCHANT_ID = (Select thirdparty_authentication.merchant_id from thirdparty_authentication where thirdparty_authentication.secret_key =@secret_key and thirdparty_authentication.status_auth =1)
		
		--SELECT TOP 1 @STAFF_ID = staff.staff_id FROM staff WHERE auth_token = @staff_tokenid 
		
		IF @MERCHANT_ID IS NOT NULL AND @MERCHANT_ID !='' AND @MERCHANT_ID !=0
			BEGIN
			 
			
				--Check Redeemed Branch
				
				IF EXISTS (SELECT * from eVoucher_verification where eVoucher_verification.verification_code =@eVoucher_verification_code
					 AND eVoucher_verification.branch_id IN (select branch_code from branch where branch.merchant_id =@merchant_id) AND eVoucher_verification.branch_id =@branch_code)
						
						BEGIN
						
					-- Remove Valid Time Verification	
					/*	SET @VALID_TIME = 
					(SELECT eVoucher_verification.valid_till 
					 FROM eVoucher_verification WHERE eVoucher_verification.verification_code=@eVoucher_verification_code)
		
						SET @TIME_INTERVAL = DATEDIFF(SECOND,CAST(@CURRENT_DATETIME As datetime),CAST(@VALID_TIME As datetime))
							Print( @TIME_INTERVAL)
							print ('Valid Time')
							print (CAST(@VALID_TIME As datetime))
							print ('Current Time')
							print (CAST(@CURRENT_DATETIME As datetime))*/
			
			-- Set Default Time Interval
		SET @TIME_INTERVAL = 1
		
		-- Check Valid Time 
		IF (@TIME_INTERVAL >0)
		
		--IF EXISTS (SELECT eVoucher_verification.eVoucher_verification_id 
		--FROM eVoucher_verification WHERE eVoucher_verification.verification_code=@eVoucher_verification_code
		--AND eVoucher_verification.valid_till>=@CURRENT_DATETIME
		
		--)
			BEGIN
			     print(@eVoucher_verification_code)
						
				-- GET EVOUCHER ID
				SELECT @EVOUCHER_ID = eVoucher_verification.eVoucher_id ,
				@BRANCH_CODE = eVoucher_verification.branch_id,
				@CUSTOMER_ID=eVoucher_verification.customer_id,
				@CUSTOMER_EMAIL = customer.email,
				@CUSTOMER_NAME = customer.first_name + ' ' + customer.last_name,
				@eVoucher_verification_id = eVoucher_verification.eVoucher_verification_id
				FROM eVoucher_verification ,customer
				WHERE eVoucher_verification.verification_code = @eVoucher_verification_code
				AND eVoucher_verification.customer_id = customer.customer_id
				--GET EVOUCHER DATA
				IF EXISTS (SELECT customer_earned_evouchers.earned_evoucher_id FROM customer_earned_evouchers
				WHERE customer_earned_evouchers.earned_evoucher_id=@EVOUCHER_ID AND customer_earned_evouchers.used_status=0
				AND CAST(customer_earned_evouchers.expired_date as Date) >= CAST(@CURRENT_DATETIME as Date)
				)
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
				

					--SET @MERCHANT_ID = ISNULL((SELECT branch.merchant_id FROM branch WHERE branch.branch_code= @BRANCH_CODE),0)
					
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
					@CUSTOMER_EMAIL,
					@CURRENT_DATETIME,
					@CURRENT_DATETIME,
					@eVoucher_verification_id,
					@eVoucher_verification_code
					)
				-- UPDATE EVOUCHER USd
					IF(@@ROWCOUNT>0)
					BEGIN
					UPDATE customer_earned_evouchers SET used_status = 1,
					updated_at = @CURRENT_DATETIME
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
						SELECT @CUSTOMER_EMAIL =EMAIL FROM customer WHERE customer.customer_id =@CUSTOMER_ID

						SELECT merchant.merchant_id,merchant.first_name,merchant.last_name,
						branch.branch_name,branch.branch_code,branch.branch_id,eVoucher_transaction.eVoucher_amount,
						'1' AS response_code,
						@CUSTOMER_EMAIL AS EMAIL,
						@EVOUCHER_CODE AS EVOUCHER_CODE
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
			SELECT '0' as response_code, 'eVoucher is not valid' as response_message 
			RETURN
			
			END
			END	
		ELSE 
		BEGIN
		SELECT '0' as response_code, 'eVoucher verification is not valid' as response_message 
		RETURN
		END
	END
ELSE
	BEGIN
		SELECT '0' as response_code, 'Verification Code or Branch Code is not valid' as response_message 
		RETURN
	END
	
			
			
			END
						
			
		ELSE
			BEGIN
			SELECT '0' as response_code, 'Merchant Key is not valid' as response_message 
			END
			
			
			
	

	
END
