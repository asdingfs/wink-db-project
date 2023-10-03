CREATE PROCEDURE [dbo].[Confirm_eVoucher_Transaction_ByStaffAccount]
(@staff_tokenid varchar(255),
 @eVoucher_verification_id int)

AS
BEGIN
	DECLARE @STAFF_ID INT
	DECLARE @Default_Value int
	DECLARE @INCREMENT_Value numeric(3,0)
	DECLARE @TRANS_REF_NO INT
	DECLARE @EVOUCHER_ID INT
	DECLARE @EVOUCHER_CODE VARCHAR(50)
	DECLARE @MERCHANT_ID INT
	DECLARE @BRANCH_CODE INT
	DECLARE @EVOUCHER_VALUE DECIMAL(10,2)
	DECLARE @CUSTOMER_ID INT
	DECLARE @VALID_TIME DATETIME
	DECLARE @TIME_INTERVAL INT
	DECLARE @CUSTOMER_EMAIL VARCHAR(100)

	--ADD NEW VARIABLE ZIN
	DECLARE @CUSTOMER_NAME VARCHAR(100)

   --ADD NEW VARIABLE ZIN
	DECLARE @Verification_Code VARCHAR(100)

	-- GET LOCAL TIME
	DECLARE @CURRENT_DATETIME datetimeoffset = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00')
	-- 1) CHECK CUSTOMER  
	-- 2) CHECK eVoucher verification
	-- 3) INSERT TO TRANSACTION 
	-- 4) UPDATE EVOUCHER USED  
	IF EXISTS(SELECT * FROM staff WHERE auth_token = @staff_tokenid)               
	BEGIN 
		SELECT TOP 1 @STAFF_ID = staff.staff_id FROM staff WHERE auth_token = @staff_tokenid;
		--- GET TIME INTERVAL
		SET @VALID_TIME = 
		(SELECT eVoucher_verification.valid_till 
		 FROM eVoucher_verification WHERE eVoucher_verification.eVoucher_verification_id=@eVoucher_verification_id);
		
		SET @TIME_INTERVAL = DATEDIFF(SECOND,CAST(@CURRENT_DATETIME As datetime),CAST(@VALID_TIME As datetime));
		Print( @TIME_INTERVAL)
		print ('Valid Time')
		print (CAST(@VALID_TIME As datetime))
		print ('Current Time')
		print (CAST(@CURRENT_DATETIME As datetime))
	
	
		Print('ok')
		-- GET EVOUCHER ID
		SELECT @EVOUCHER_ID = eVoucher_verification.eVoucher_id ,
		@CUSTOMER_EMAIL = customer.email,
		@CUSTOMER_NAME = customer.first_name + ' ' + customer.last_name,
		@BRANCH_CODE = eVoucher_verification.branch_id,
		@CUSTOMER_ID=eVoucher_verification.customer_id,
		@Verification_Code = eVoucher_verification.verification_code
		FROM eVoucher_verification ,customer
		WHERE eVoucher_verification.eVoucher_verification_id = @eVoucher_verification_id
		AND eVoucher_verification.customer_id = customer.customer_id;
		Print('GET EVOUCHER ID');
		--GET EVOUCHER DATA
		IF EXISTS (SELECT customer_earned_evouchers.earned_evoucher_id FROM customer_earned_evouchers
		WHERE customer_earned_evouchers.earned_evoucher_id=@EVOUCHER_ID AND customer_earned_evouchers.used_status=0
		and CAST(customer_earned_evouchers.expired_date as Date) >= CAST(@CURRENT_DATETIME as Date)
		)
		BEGIN
			
			SELECT @EVOUCHER_CODE=eVoucher_code,
			@EVOUCHER_VALUE=eVoucher_amount
			FROM customer_earned_evouchers 
			WHERE customer_earned_evouchers.earned_evoucher_id=@EVOUCHER_ID;
			
			---CHECK THE CURRENT TRANSACTION ID
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
			SET @MERCHANT_ID = ISNULL((SELECT branch.merchant_id FROM branch WHERE branch.branch_code= @BRANCH_CODE),0);

			IF NOT EXISTS(SELECT 1 FROM eVoucher_transaction WHERE eVoucher_id = @EVOUCHER_ID and transation_status like 'success')
			BEGIN
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
				@Verification_Code
				);
				-- UPDATE EVOUCHER USd
				IF(@@ROWCOUNT>0)
				BEGIN
					UPDATE customer_earned_evouchers SET used_status = 1,
					updated_at = @CURRENT_DATETIME
					WHERE earned_evoucher_id = @EVOUCHER_ID;

					IF (@@ROWCOUNT>0)
					BEGIN
						UPDATE customer_balance SET total_used_evouchers = total_used_evouchers+1 WHERE customer_balance.customer_id= @CUSTOMER_ID;
			
						IF (@@ROWCOUNT>0)
						BEGIN
							DECLARE  @winkFeeRate Decimal(10,2);
							SELECT @winkFeeRate = wink_fee_percent from merchant where merchant_id =  @MERCHANT_ID;

							IF((@winkFeeRate is not null) and (@winkFeeRate != 0))
							BEGIN
								DECLARE @wink_fees_charged Decimal(10,2);
								DECLARE @merchant_voucher_value Decimal (10,2);
								DECLARE @GST Decimal (10,2);
								SET @wink_fees_charged = @EVOUCHER_VALUE*(@winkFeeRate/100);
								/* old code */
								/*SET @GST = @wink_fees_charged * 0.07*/
								/*fix GST  bug */
								if (@wink_fees_charged is not null AND @wink_fees_charged!=0 AND YEAR(@CURRENT_DATETIME)>=2023)		
								SET @GST = @wink_fees_charged * 0.08
								else if (@wink_fees_charged is not null AND @wink_fees_charged!=0 AND YEAR(@CURRENT_DATETIME)<2023 )
								SET @GST = @wink_fees_charged * 0.07
								else
								SET @GST = 0
								SET @merchant_voucher_value = @EVOUCHER_VALUE - @wink_fees_charged - @GST;

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
									('',@customer_id,@eVoucher_id,@merchant_voucher_value,
									@CURRENT_DATETIME,@CURRENT_DATETIME,@CURRENT_DATETIME,
									@wink_fees_charged, 'done'
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
										,(@EVOUCHER_VALUE*2)
										,@EVOUCHER_VALUE
										,(@wink_fees_charged*2)
										,(@merchant_voucher_value*2)
										,@merchant_voucher_value
																
										,@CURRENT_DATETIME
										,@CURRENT_DATETIME
										,@eVoucher_id
										,@customer_id
										,@wink_fees_charged
										,0
										);
									IF(@@ROWCOUNT = 0)
									BEGIN
										SELECT '0' as response_code, 'An error has occured. Please try again later.' as response_message;
										RETURN
									END
								END
								ELSE
								BEGIN
									SELECT '0' as response_code, 'An error has occured. Please try again later.' as response_message;
									RETURN
								END
							END
							SELECT @CUSTOMER_EMAIL =EMAIL FROM customer WHERE customer.customer_id =@CUSTOMER_ID;

							SELECT merchant.merchant_id,merchant.first_name,merchant.last_name,
							branch.branch_name,branch.branch_code,branch.branch_id,eVoucher_transaction.eVoucher_amount,
							'1' AS response_code,
							'eVoucher has been successfully redeemed.' as response_message,
							@CUSTOMER_EMAIL AS EMAIL,
							@EVOUCHER_CODE AS EVOUCHER_CODE
							FROM merchant,branch,eVoucher_transaction
							WHERE eVoucher_transaction.merchant_id = merchant.merchant_id 
							AND eVoucher_transaction.branch_code = branch.branch_code
							AND eVoucher_transaction.transaction_id =@TRANS_REF_NO;
							RETURN
						END
						ELSE
						BEGIN 
							SELECT '0' as response_code, 'An error has occured. Please try again later.' as response_message;
							RETURN
						END
					END
					ELSE
					BEGIN 
						SELECT '0' as response_code, 'An error has occured. Please try again later.' as response_message; 
						RETURN
					END
				
				END
				ELSE
				BEGIN 
					SELECT '0' as response_code, 'An error has occured. Please try again later.' as response_message; 
					RETURN
				END
			END	
			ELSE 
			BEGIN
				SELECT '0' as response_code, 'This eVoucher has already been redeemed' as response_message 
				RETURN
			END		
			
		END
		ELSE 
		BEGIN
			SELECT '0' as response_code, 'Invalid eVoucher' as response_message 
			RETURN
		END		
	END
	ELSE 
	BEGIN
		SELECT '0' as response_code, 'Invalid staff login' as response_message 
		RETURN
	END
	
END


