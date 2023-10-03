CREATE PROCEDURE [dbo].[Confirm_eVoucher_Transaction_By_WINKProduct]
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
DECLARE @MERCHANT_ID int
DECLARE @branch_code int
DECLARE @current_date datetime
Declare @product_id int

DECLARE @return_code varchar(10)
Declare @success_message varchar(250)

Declare @thirparty_evoucher_id int

Declare @thirparty_evoucher_code varchar(50)

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

--SET @branch_code =4439

/*IF (CAST(@current_date as date) > CAST('2016-12-31' as date))

BEGIN

SELECT '0' AS success , 'Campaign is over' as response_message
Return
END*/

 

select @branch_code = branch_id,@customer_id = customer_id ,@eVoucher_id = evoucher_id from eVoucher_verification as e where e.verification_code = @verification_code
select @MERCHANT_ID = merchant_id from branch where branch.branch_code = @branch_code
SELECT @CUSTOMER_NAME = customer.first_name + ' ' + customer.last_name, @CUSTOMER_EMAIL = customer.email  FROM customer WHERE customer.customer_id = @customer_id
print ('@MERCHANT_ID')

print (@MERCHANT_ID)

IF EXISTS (select 1 from wink_products where branch_id = @branch_code)
BEGIN


-- Check customer is locked?

  
  IF Exists (select 1 from customer where customer_id = @customer_id and status='enable')
	BEGIN
		-- check evoucher is used?
		
		--IF EXISTS (select 1 from customer_earned_evouchers as c where c.earned_evoucher_id = @eVoucher_id and c.used_status = 0)
	IF EXISTS (Select 1

	from eVoucher_verification,customer_earned_evouchers
	where 
	eVoucher_verification.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
	
	and eVoucher_verification.verification_code = @verification_code
	and customer_earned_evouchers.used_status =0
	and eVoucher_verification.branch_id=@branch_code
	and CAST(customer_earned_evouchers.expired_date as Date) > CAST(@current_date as Date)
	)
	
			BEGIN
				
				-- Get eVoucher 
				
				print ('dkfjsdkjfskdf')
				
				select @EVOUCHER_VALUE=e.eVoucher_amount from customer_earned_evouchers as e where e.earned_evoucher_id = @eVoucher_id and e.used_status = 0 
				
				select @product_id = isnull(id,0) from wink_products as p where p.branch_id=@branch_code and price = @EVOUCHER_VALUE 
				
				IF (@product_id is not null and @product_id !=0)
					BEGIN
					
					if ( (select COUNT(*) from wink_products_redemption where product_id = @product_id and thirdparty_eVoucher_id !=0) =
                        (select COUNT(*) from wink_products_thirdparty_evoucher where product_id =@product_id)
                        and ((select COUNT(*) from wink_products where qty>redeemed_qty)>1)                                             
                        )
                        BEGIN
								 SELECT '0' as success, 'Out of Stock' as response_message 
							Return	
					    END
					
					
							-- Check Customer 
								print(@EVOUCHER_ID)
							IF (@EVOUCHER_ID !=0 AND @EVOUCHER_ID IS NOT NULL AND @EVOUCHER_ID !='')
								BEGIN
									
									print(@customer_id)
									print (@eVoucher_code)
									print (@EVOUCHER_ID)
									--CHECK eVOUCHER IS VALID
										
										BEGIN
										
												--Update eVoucher used status 
												UPDATE customer_earned_evouchers SET used_status = 1,
												updated_at = @current_date
												WHERE earned_evoucher_id = @EVOUCHER_ID
												and used_status =0
												
												IF (@@ROWCOUNT>0)
												BEGIN
												-- Customer Balanced
												UPDATE customer_balance SET total_used_evouchers = total_used_evouchers+1 WHERE customer_balance.customer_id= @CUSTOMER_ID
												and total_used_evouchers+1 <= total_evouchers
												
												IF(@@ROWCOUNT>0)
												BEGIN
												
												-- Update WINK Product Qty
												Update wink_products set redeemed_qty = ISNULL(redeemed_qty,0)+1 where
												id = @product_id
												
												-- Select Third Party evoucher code
											    			
												
												
												--- Insert WINK Product Redemption
												insert into wink_products_redemption 
													(
													customer_id,eVoucher_id,product_id,created_at,updated_at,branch_id,thirdparty_eVoucher_id

													)
												values (@customer_id,@evoucher_id,@product_id,@current_date,@current_date,@branch_code,
												(select top 1 id from wink_products_thirdparty_evoucher where product_id = @product_id
												 and id not in (select thirdparty_eVoucher_id from wink_products_redemption where thirdparty_eVoucher_id !=0 ))
																								
												)
												
												select @eVoucher_code = eVoucher_code from wink_products_thirdparty_evoucher where 
												id = (select thirdparty_eVoucher_id from wink_products_redemption where eVoucher_id = @evoucher_id)
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
											@current_date,
											@current_date
										
											)
												IF(@@ROWCOUNT>0)
												BEGIN
												select @success_message = success_message from wink_products where id =@product_id

												SELECT '1' AS	success , @success_message as response_message,@eVoucher_code as thirdparty_code,
						                         @TRANS_REF_NO AS transaction_id
												
												END
												------------------------------------------
												
												END
												
												END
												
												
										
								
										
										END
									
										
									
								
								END
								
							ELSE
							
								BEGIN
								 SELECT '0' as success, 'eVoucher code is not valid' as response_message 
								
								END
	
	
										
					END
				ELSE
					BEGIN
					
					set @return_code = '003'
					Goto Err
					
					END
				
			END
		ELSE
			BEGIN
				set @return_code = '002'
				Goto Err
			
			END
	
	
	END
	ELSE
	BEGIN
	set @return_code = '001'
	Goto Err
	
	END

	


END
ELSE 
BEGIN
		Select 0 as success , 'Invalid branch code' as response_message
		Return 
	
END


ERR:
IF(@return_code = '001')
BEGIN
	Select 0 as success , 'Customer account is locked.Please contact to customer service' as response_message
	Return 

END
ELSE IF (@return_code = '002')
BEGIN
	Select 0 as success , 'eVoucher is not valid' as response_message
	Return 

END
ELSE IF (@return_code = '003')
BEGIN
	Select 0 as success , 'eVoucher amount is not valid to redeem' as response_message
	Return 

END
	
	
END

