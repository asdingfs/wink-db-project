CREATE PROCEDURE [dbo].[Confirm_eVoucher_Transaction_By_iMOBSpecail]
(
 
 @verification_code varchar(100)
 

 
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
DECLARE @eVoucher_code varchar (100)
DECLARE @merchant_id int
DECLARE @branch_code int

 

SET @merchant_id = 1
SET @branch_code =4439
DECLARE @current_date datetime

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

IF (CAST(@current_date as date) > CAST('2016-12-31' as date))

BEGIN

SELECT '0' AS response_code , 'Campaign is over' as response_message
Return
END

Set @customer_id = (select customer_id from eVoucher_verification where  eVoucher_verification.verification_code = @verification_code)

IF EXISTS (select 1 from  iMOBSpecial where event_name= 'Transformers20170601' and customer_id = @customer_id)
 BEGIN

SELECT '0' AS response_code , 'Limited one redemption per customer' as response_message
Return
END
--If ((select COUNT(*) from eVoucher_transaction where eVoucher_transaction.branch_code = @branch_code)<20)
If ((select COUNT(*)  from iMOBSpecial where event_name= 'Transformers20170601')<50)

BEGIN
-- Get Customer ID
	Select @customer_id = eVoucher_verification.customer_id ,
	@EVOUCHER_ID=customer_earned_evouchers.earned_evoucher_id,
	 @eVoucher_code = customer_earned_evouchers.eVoucher_code,
	 @EVOUCHER_VALUE=eVoucher_amount
	from eVoucher_verification,customer_earned_evouchers
	where 
	eVoucher_verification.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
	and eVoucher_verification.branch_id= @branch_code
	and eVoucher_verification.verification_code = @verification_code
	and customer_earned_evouchers.used_status =0
	and CAST(customer_earned_evouchers.expired_date as Date) > CAST(@current_date as Date)

    -- Check eVoucher Value
    --if (@EVOUCHER_VALUE > 5 OR @EVOUCHER_VALUE <5)
   -- if (@EVOUCHER_VALUE > 10 OR @EVOUCHER_VALUE <10)
   if (@EVOUCHER_VALUE > 1 OR @EVOUCHER_VALUE <1)
    BEGIN
	SELECT '0' as response_code, 'eVoucher amount must be $1.00 (2 WINK+)' as response_message 
	
	END	
  
	
	ELSE
	  BEGIN
	-- Check Customer 
		print(@EVOUCHER_ID)
	IF (@EVOUCHER_ID !=0 AND @EVOUCHER_ID IS NOT NULL AND @EVOUCHER_ID !='')
		BEGIN
		    SELECT @CUSTOMER_NAME = customer.first_name + ' ' + customer.last_name, @CUSTOMER_EMAIL = customer.email  FROM customer WHERE customer.customer_id = @customer_id
			print(@customer_id)
			print (@eVoucher_code)
			print (@EVOUCHER_ID)
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
					,[updated_at]
					
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
					@CURRENT_DATETIME
				
					)
					
					-- UPDATE EVOUCHER USd
					IF(@@ROWCOUNT>0)
					BEGIN
					UPDATE customer_earned_evouchers SET used_status = 1,
					updated_at = @CURRENT_DATETIME
					WHERE earned_evoucher_id = @EVOUCHER_ID
					UPDATE customer_balance SET total_used_evouchers = total_used_evouchers+1 WHERE customer_balance.customer_id= @CUSTOMER_ID
					
					-- Insert special record
					
					insert into iMOBSpecial (customer_id,eVoucher_id,event_name,created_at)
                     values (@customer_id,@EVOUCHER_ID,'Transformers20170601',@current_date)
					-- IF NOT UPDATE
					IF (@@ROWCOUNT=0)
					BEGIN
					DELETE eVoucher_transaction WHERE eVoucher_transaction.transaction_id = @TRANS_REF_NO
					END
					ELSE
					-- IF (@@ROWCOUNT>0)
					BEGIN
						SELECT '1' AS	response_code , 'eVoucher is successfully redeemed.We will be contacting you soon for collection.' as response_message,
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
					
					SELECT '0' as response_code, 'eVoucher code is not valid' as response_message 
					END
		
		
		END
		
	ELSE
	
		BEGIN
		 SELECT '0' as response_code, 'eVoucher code is not valid' as response_message 
		
		END
	
	END
	
	
END
ELSE
BEGIN
	 SELECT '0' as response_code, 'Out of Stock' as response_message 
	 
END	
	
END

