CREATE PROCEDURE [dbo].[Authenticate_eVoucher_By_iMOBSpecail]
	(@verification_code varchar(100)
	 )
AS
BEGIN
DECLARE @customer_id int
DECLARE @eVoucher_amount decimal(10,2)
DECLARE @eVoucher_id int
DECLARE @branch_code int

DECLARE @current_date datetime

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

SET @branch_code =4439

IF (CAST(@current_date as date) > CAST('2017-06-30' as date))

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
IF EXISTS (Select *

	from eVoucher_verification,customer_earned_evouchers
	where 
	eVoucher_verification.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
	
	and eVoucher_verification.verification_code = @verification_code
	and customer_earned_evouchers.used_status =0
	and eVoucher_verification.branch_id=@branch_code
	and CAST(customer_earned_evouchers.expired_date as Date) > CAST(@current_date as Date)
)

	BEGIN 
	
	Select @eVoucher_amount = customer_earned_evouchers.eVoucher_amount
	from eVoucher_verification,customer_earned_evouchers
	where 
	eVoucher_verification.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
	
	and eVoucher_verification.verification_code = @verification_code
	and customer_earned_evouchers.used_status =0
	and eVoucher_verification.branch_id=@branch_code
	
	print (@eVoucher_amount)
	
	--if (@eVoucher_amount < 5 OR @eVoucher_amount >5)
	--if(@eVoucher_amount<10 OR @eVoucher_amount >10)
	if(@eVoucher_amount<1 OR @eVoucher_amount >1)
	BEGIN
	
	SELECT '0' AS response_code , 'eVoucher amount must be $1.00 (2 WINK+)' as response_message
	END
	ELSE
	BEGIN
	SELECT '1' AS response_code ,'Success' as response_message,
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
	END
	
	
	
	
	END
	ELSE 
	
	BEGIN
		SELECT '0' AS response_code , 'eVoucher is not valid' as response_message
	
	END
	
	END
ELSE
	BEGIN
	
	 SELECT '0' as response_code, 'Out of Stock' as response_message 
	
	
	END
	
	
	
END

