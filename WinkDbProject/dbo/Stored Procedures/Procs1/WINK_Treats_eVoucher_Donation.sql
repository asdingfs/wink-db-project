CREATE PROC [dbo].[WINK_Treats_eVoucher_Donation]
@eVoucher_code VARCHAR(50),
@branch_code int,
@CUSTOMER_ID INT
AS

DECLARE @eVoucher_id int
DECLARE @VERIFICATION_CODE VARCHAR(12)
DECLARE @VERIFICATION_VALID_TILL DATETIME
DECLARE @VERIFICATION_ID INT
DECLARE @CURRENT_DATETIME DATETIME
DECLARE @EVOUCHER_VALUE DECIMAL(10,2)
Declare @product_id int
DECLARE @donation_voucher_value DECIMAL(10,2)
DECLARE @return_code varchar(10)
DECLARE @INCREMENT_Value numeric(3,0)
DECLARE @TRANS_REF_NO INT

declare @msg varchar(200);
BEGIN
	
	--1) CHECK TOKEN_ID EXISTS OR NOT. IF EXISTS, GET CUTOMER_ID--
	--2) CHECK BRANCH ID EXISTS OR NOT. 
	--3) IF EXISTS BRANCH ID, CHECK EVOUCHER CODE EXISTS OR NOT
	--4) IF EXISTS EVOUCHER CODE, GENERATE VERIFICATION CODE 
	--5) INSERT INTO eVoucher_verification

    --0) get current datetime
    EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 
		--- Check Account Locked
   IF EXISTS(SELECT * FROM CUSTOMER WHERE customer_id = @CUSTOMER_ID and customer.[status]='disable') --CUSTOMER EXISTS                           
   BEGIN
		set @return_code = '1';
		Goto Err
	END-- END

	IF EXISTS(SELECT customer_id from customer_earned_evouchers where eVoucher_code like @eVoucher_code AND used_status = 0 AND ((SELECT DATEDIFF(DAY,@CURRENT_DATETIME,expired_date))>=0))
	BEGIN
		SELECT @CUSTOMER_ID = customer_id, @eVoucher_id = earned_evoucher_id, @EVOUCHER_VALUE=eVoucher_amount from customer_earned_evouchers where eVoucher_code like @eVoucher_code
	END
	ELSE
	BEGIN
		set @return_code = '0';
		Goto Err
		
	END
	--1) CHECK BRANCH ID EXISTS OR NOT
	IF EXISTS(SELECT * FROM BRANCH WHERE branch_code = @branch_code AND branch_status = '1') --BRANCH ID EXISTS
	BEGIN
		
		SELECT @product_id = isnull(id,0), @donation_voucher_value = price FROM wink_products WHERE branch_id = @branch_code and product_status = 1;
		print(@product_id);
		IF (@product_id is not null and @product_id !=0)
		BEGIN	
			DECLARE @redemption_count int
			SELECT @redemption_count = COUNT(*)
			FROM wink_products_redemption
			WHERE product_id = @product_id
			AND customer_id = @CUSTOMER_ID;

			IF(@redemption_count < 9)
			BEGIN
				print(@redemption_count);
				IF(@EVOUCHER_VALUE = @donation_voucher_value)
				BEGIN
					print('correct donation amount');
					--3) GET VERIFICATION CODE 
					SELECT @VERIFICATION_CODE= CONVERT(numeric(12,0),rand() * 899999999999) + 100000000000;

					WHILE EXISTS(SELECT * FROM eVoucher_verification WHERE eVoucher_verification.verification_code = @VERIFICATION_CODE)
					BEGIN
						SELECT @VERIFICATION_CODE= CONVERT(numeric(12,0),rand() * 899999999999) + 100000000000;
					END
					print (@VERIFICATION_CODE)

					--4) INSERT INTO eVoucher_verification
					SELECT @VERIFICATION_VALID_TILL = DATEADD(second,system_value,@CURRENT_DATETIME)FROM system_key_value WHERE system_key = 'evoucher_lock_seconds';
				
					INSERT INTO eVoucher_verification
					(eVoucher_id,eVoucher_code,verification_code,customer_id,branch_id,created_at,valid_till) VALUES 
					(@eVoucher_id,@eVoucher_id,@VERIFICATION_CODE,@CUSTOMER_ID,@branch_code,@CURRENT_DATETIME,@VERIFICATION_VALID_TILL);

					SET @VERIFICATION_ID = SCOPE_IDENTITY();

					IF(@@ROWCOUNT>0)
					BEGIN	
						IF (@EVOUCHER_ID !=0 AND @EVOUCHER_ID IS NOT NULL AND @EVOUCHER_ID !='')
						BEGIN
							--Update eVoucher used status 
							UPDATE customer_earned_evouchers SET used_status = 1,
							updated_at = @CURRENT_DATETIME
							WHERE earned_evoucher_id = @EVOUCHER_ID
							and used_status =0;

							IF (@@ROWCOUNT>0)
							BEGIN
								-- Customer Balanced
								UPDATE customer_balance SET total_used_evouchers = total_used_evouchers+1 WHERE customer_balance.customer_id= @CUSTOMER_ID
								and total_used_evouchers+1 <= total_evouchers;

								IF(@@ROWCOUNT>0)
								BEGIN
									-- Update WINK Product Qty
									Update wink_products set redeemed_qty = ISNULL(redeemed_qty,0)+1 where id = @product_id;

									--- Insert WINK Product Redemption
									insert into wink_products_redemption 
										(customer_id,eVoucher_id,product_id,created_at,updated_at,branch_id)
									values (@customer_id,@evoucher_id,@product_id,@CURRENT_DATETIME,@CURRENT_DATETIME,@branch_code);

									SET @INCREMENT_Value= CONVERT(numeric(3,0),rand() * 999);

									IF EXISTS (SELECT TRANSACTION_ID FROM eVoucher_transaction)
									BEGIN
										SET @TRANS_REF_NO =(SELECT TOP 1 TRANSACTION_ID  FROM eVoucher_transaction ORDER BY TRANSACTION_ID DESC);
									END
									ELSE
									BEGIN 
										SET @TRANS_REF_NO = 1000000000;
									END
											
									SET @TRANS_REF_NO = @TRANS_REF_NO+@INCREMENT_Value;
										
									DECLARE @MERCHANT_ID int
									DECLARE @CUSTOMER_NAME VARCHAR(100)
									DECLARE @FIRST_NAME varchar(100)
									DECLARE @CUSTOMER_EMAIL VARCHAR(100)

									select @MERCHANT_ID = merchant_id from branch where branch.branch_code = @branch_code;

									SELECT @FIRST_NAME = customer.first_name, @CUSTOMER_NAME = customer.first_name + ' ' + customer.last_name, @CUSTOMER_EMAIL = customer.email  FROM customer WHERE customer.customer_id = @customer_id;

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
									@VERIFICATION_ID,
									@VERIFICATION_CODE);

									IF(@@ROWCOUNT>0)
									BEGIN
										----11...INSERT INTO NETs REDEMPTION RECORDS
										INSERT INTO [dbo].[NETs_CANID_Redemption_Record_Detail]
										([can_id]
										,[customer_id]
										,[evoucher_id]
										,[evoucher_amount]
										,[created_at]
										,[updated_at]
										,redemption_date
										,wink_charges
										,cronjob_status
										)
										VALUES
										('',@customer_id,@eVoucher_id,@donation_voucher_value,
										@CURRENT_DATETIME,@CURRENT_DATETIME,@CURRENT_DATETIME,
										0.00, 'done'
										);

										IF(@@ROWCOUNT>0)
										BEGIN
											INSERT INTO [dbo].[WINK_Redemption_Detail_With_WINK_Fees]
												([merchant_id]
												,[total_redeemed_winks]
												,[total_redeemed_amount]
												,[wink_fee]
												,[balance_redeemed_winks]
												,[balance_redeemed_amount]
												,[created_at]
												,[updated_at]
												,[evoucher_id]
												,[customer_id]
												,[wink_fee_amount]
												,[wink_fees_id])
											VALUES
															
												(@MERCHANT_ID
												,(@donation_voucher_value*2)
												,@donation_voucher_value
												,(0*2)
												,(@donation_voucher_value*2)
												,@donation_voucher_value
																
												,@CURRENT_DATETIME
												,@CURRENT_DATETIME
												,@eVoucher_id
												,@customer_id
												,0
												,6
												)
											IF(@@ERROR=0)
											BEGIN
												SELECT '7' as response_code,  (select success_message from wink_products where id =@product_id) as response_message,
												@CUSTOMER_EMAIL as email,@FIRST_NAME as firstName, @MERCHANT_ID as merchant_id;
												Return 	
											END
										END
										
									END

								END
										
							END
						END
						ELSE
						BEGIN
							set @return_code = '3';
							Goto Err
						END			
					END
					ELSE
					BEGIN
						set @return_code = '3';
						Goto Err
					END
				END
				ELSE
				BEGIN
					set @return_code = '5';
					Goto Err
				END
			END
			ELSE
			BEGIN
				-- Users has donated $18
				SET @return_code = '2';
				Goto Err
			END
		END
		ELSE
		BEGIN
			set @return_code = '2';
			Goto Err
		END
	END
	ELSE
	BEGIN
		set @return_code = '2';
		Goto Err
	END



	ERR:
	IF(@return_code = '0')
	BEGIN
		SELECT '0' as response_code, 'Oops! The code you have entered is invalid.' as response_message 
		Return 
	END
	ELSE IF (@return_code = '1')
	BEGIN
		SELECT '1' as response_code, 'Your account is locked. Please contact customer service.' as response_message 
		RETURN 
	END
	ELSE IF (@return_code = '2')
	BEGIN
		SELECT '2' as response_code, 'The donation is not available.' as response_message
		Return 

	END
	ELSE IF (@return_code = '3')
	BEGIN
		SELECT '3' as response_code, 'Oops! We are unable to verify the code.<br>Please try again later.' as response_message
		Return 
	END
	ELSE IF (@return_code = '5')
	BEGIN
		SELECT '3' as response_code, 'Oops! You can only donate in denominations of $2! Thank you!' as response_message
		RETURN
	END
END

