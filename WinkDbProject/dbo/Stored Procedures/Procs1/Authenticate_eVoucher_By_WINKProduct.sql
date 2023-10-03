CREATE PROCEDURE [dbo].[Authenticate_eVoucher_By_WINKProduct]
	(
	 @verification_code varchar(100)
	 )
AS
BEGIN
DECLARE @customer_id int
DECLARE @eVoucher_amount decimal(10,2)
DECLARE @eVoucher_id int
DECLARE @branch_code int

DECLARE @current_date datetime

DECLARE @return_code varchar(10)

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

select @branch_code = branch_id from eVoucher_verification as e where e.verification_code = @verification_code

Set @customer_id = (select customer_id from eVoucher_verification where  eVoucher_verification.verification_code = @verification_code)

Set @eVoucher_id = (select eVoucher_id from eVoucher_verification where  eVoucher_verification.verification_code = @verification_code)
-- check wink products
Print ('@branch_code')

Print (@branch_code)
IF EXISTS (select 1 from wink_products where branch_id = @branch_code and product_status =1)
BEGIN

-- Check customer is locked?

  IF Exists (select 1 from customer where customer_id = @customer_id and status='enable')
	BEGIN
		-- check evoucher is used?
		print (@branch_code)
		print (@verification_code)
		print (@current_date)
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
				print ('dkfjsdkjfskdf')
				-- Get eVoucher 
				
				select @eVoucher_amount=e.eVoucher_amount from customer_earned_evouchers as e where e.earned_evoucher_id = @eVoucher_id and e.used_status = 0 

				-- Check eVoucher value 

				IF NOT EXISTs (select 1  from wink_products as p where
				 p.branch_id=@branch_code and price = @eVoucher_amount )
				 BEGIN
				 	set @return_code = '003'
					Goto Err

				 END
				
				IF EXISTS (select 1 from wink_products as p where p.branch_id=@branch_code and price = @eVoucher_amount and product_status =1)
					BEGIN
					   
					   IF EXISTS (select 1 from wink_products as p where p.branch_id=@branch_code and price = @eVoucher_amount  and qty=redeemed_qty and product_status =1)
					    BEGIN
						set @return_code = '004'
					    Goto Err
					

					    END
					ELSE 
					BEGIN
					   
						SELECT '1' AS success ,'Success' as response_message,
						customer_earned_evouchers.eVoucher_code,
						eVoucher_amount,
						expired_date,
						used_status
						from 
						customer_earned_evouchers,eVoucher_verification
						where 
						eVoucher_verification.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
						
						and eVoucher_verification.verification_code = @verification_code
						and customer_earned_evouchers.used_status =0
						and CAST(customer_earned_evouchers.expired_date as date) > CAST (@current_date as date)
						and eVoucher_verification.branch_id=@branch_code
						
						Return
					END
										
					END
				ELSE
					BEGIN
					
					set @return_code = '005'
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
		Select 0 as success , 'Invalid code' as response_message
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

ELSE IF (@return_code = '004')
BEGIN
	Select 0 as success , 'Out of Stock' as response_message
	Return 

END

ELSE IF (@return_code = '005')
BEGIN
	Select 0 as success , 'Invalid to redeem' as response_message
	Return 

END
	
	
END


