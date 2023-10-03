CREATE PROCEDURE [dbo].[Confirm_eVoucher_Transaction_By_Thirdparty]
(@email varchar(255),
 @used_status int,
 @eVoucher_code varchar(100),
 @merchant_id int,
 @branch_code int
 
 )

AS
BEGIN
DECLARE @customer_id int
DECLARE @Default_Value int
DECLARE @INCREMENT_Value numeric(3,0)
DECLARE @TRANS_REF_NO INT
DECLARE @EVOUCHER_ID INT
DECLARE @EVOUCHER_VALUE DECIMAL(10,2)

--ADD NEW VARIABLE ZIN
DECLARE @CUSTOMER_NAME VARCHAR(100)
DECLARE @CUSTOMER_EMAIL VARCHAR(100)


    SELECT @customer_id=customer.customer_id, @CUSTOMER_NAME = customer.first_name + ' ' + customer.last_name, @CUSTOMER_EMAIL = customer.email  FROM customer WHERE Lower(LTRIM(RTRIM(customer.email)))= Lower(LTRIM(RTRIM(@email)))
	-- Check Customer 
		print(@customer_id)
	IF (@customer_id !=0 AND @customer_id IS NOT NULL AND @customer_id !='')
		BEGIN
			print(@customer_id)
			print (@eVoucher_code)
		SELECT @EVOUCHER_VALUE=eVoucher_amount,@EVOUCHER_ID = earned_evoucher_id
				FROM customer_earned_evouchers 
				WHERE Lower(LTRIM(RTRIM(customer_earned_evouchers.eVoucher_code)))=Lower(LTRIM(RTRIM(@eVoucher_code)))
				AND customer_earned_evouchers.customer_id = @customer_id
				AND customer_earned_evouchers.used_status =0
			--CHECK eVOUCHER IS VALID
				IF (@EVOUCHER_ID IS NOT NULL AND @EVOUCHER_ID !=0 AND @EVOUCHER_ID !='')
				BEGIN
					---CHECK THE CURRENT TRANSACTION ID
					SET @INCREMENT_Value= CONVERT(numeric(3,0),rand() * 999)
					---GET TRANSACTION REF NO
					IF EXISTS (SELECT TRANSACTION_ID FROM eVoucher_transaction)
						BEGIN
							SET @TRANS_REF_NO =(SELECT TOP 1 TRANSACTION_ID  FROM eVoucher_transaction ORDER BY TRANSACTION_ID DESC)
						END
						ELSE
						BEGIN 
							SET @TRANS_REF_NO = 1000000000
					
						END
					
						SET @TRANS_REF_NO = @TRANS_REF_NO+@INCREMENT_Value
				

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
					,[updated_at])
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
					@CURRENT_DATETIME
					)
					
					-- UPDATE EVOUCHER USd
					IF(@@ROWCOUNT>0)
					BEGIN
					UPDATE customer_earned_evouchers SET used_status = 1,
					updated_at = @CURRENT_DATETIME
					WHERE earned_evoucher_id = @EVOUCHER_ID
					UPDATE customer_balance SET total_used_evouchers = total_used_evouchers+1 WHERE customer_balance.customer_id= @CUSTOMER_ID
					-- IF NOT UPDATE
					IF (@@ROWCOUNT=0)
					BEGIN
					DELETE eVoucher_transaction WHERE eVoucher_transaction.transaction_id = @TRANS_REF_NO
					END
					ELSE
					-- IF (@@ROWCOUNT>0)
					BEGIN
						SELECT '1' AS	response_code , 'eVoucher is successfully redeemed' as response_message,
						@TRANS_REF_NO AS transaction_id
						/*SELECT merchant.merchant_id,merchant.first_name,merchant.last_name,
						branch.branch_name,branch.branch_code,branch.branch_id,eVoucher_transaction.eVoucher_amount,
						'1' AS response_code
						FROM merchant,branch,eVoucher_transaction
						WHERE eVoucher_transaction.merchant_id = merchant.merchant_id AND
						eVoucher_transaction.branch_code = branch.branch_code
						AND eVoucher_transaction.transaction_id =@TRANS_REF_NO*/
						RETURN
					END
					
					
					END
						ELSE
							BEGIN 
							SELECT '0' as response_code, 'INSERT FAIL' as response_message
							 
							RETURN
			
							END
				/*SELECT *
				FROM customer_earned_evouchers 
				WHERE Lower(LTRIM(RTRIM(customer_earned_evouchers.eVoucher_code)))=Lower(LTRIM(RTRIM(@eVoucher_code)))
				AND customer_earned_evouchers.customer_id = @customer_id
				AND customer_earned_evouchers.used_status =0*/
				
				
				END
			
				
				ELSE
					BEGIN
					
					SELECT '0' as response_code, 'eVoucher code is not valide' as response_message 
					END
		
		
		END
		
	ELSE
	
		BEGIN
		 SELECT '0' as response_code, 'User is not authenticate' as response_message 
		
		END
	
END
