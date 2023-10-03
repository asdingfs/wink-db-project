CREATE  PROCEDURE [dbo].[Get_Redemption_Merchants_Report]
	(@start_date datetime,
	 @end_date datetime)
AS
BEGIN
IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')
BEGIN

   Select eVoucher_transaction.transaction_id,eVoucher_transaction.merchant_id,
eVoucher_transaction.customer_id,eVoucher_transaction.customer_name,eVoucher_transaction.customer_email,
eVoucher_transaction.branch_code,eVoucher_transaction.created_at,eVoucher_transaction.eVoucher_id,
merchant.mas_code,branch.branch_name,eVoucher_transaction.verification_code,

--(Select top 1 eVoucher_verification.verification_code from eVoucher_verification
--where eVoucher_verification.eVoucher_id =eVoucher_transaction.eVoucher_id)as verification_code ,
customer_earned_evouchers.eVoucher_code,
eVoucher_transaction.eVoucher_amount,merchant.first_name,merchant.last_name,eVoucher_transaction.order_no
From eVoucher_transaction,merchant,branch,customer_earned_evouchers
Where 
--eVoucher_verification.eVoucher_id = eVoucher_transaction.eVoucher_id 
 eVoucher_transaction.merchant_id = merchant.merchant_id
AND eVoucher_transaction.branch_code = branch.branch_code
AND customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
AND CAST(eVoucher_transaction.created_at as Date) BETWEEN @start_date AND @end_date
order by eVoucher_transaction.ID desc
     
	

END

	ELSE 
		BEGIN
			 Select eVoucher_transaction.transaction_id,eVoucher_transaction.merchant_id,
			 eVoucher_transaction.customer_id,eVoucher_transaction.customer_name,eVoucher_transaction.customer_email,
			 eVoucher_transaction.branch_code,eVoucher_transaction.created_at,
			 eVoucher_transaction.eVoucher_id,
			 merchant.mas_code,branch.branch_name,
			 eVoucher_transaction.verification_code,
			 --(Select top 1 eVoucher_verification.verification_code from eVoucher_verification
			 --where eVoucher_verification.eVoucher_id =eVoucher_transaction.eVoucher_id)as verification_code ,
			 customer_earned_evouchers.eVoucher_code,
			 eVoucher_transaction.eVoucher_amount,merchant.first_name,merchant.last_name,
			 eVoucher_transaction.order_no
			 From eVoucher_transaction,merchant,branch,customer_earned_evouchers
			 Where 
			 --eVoucher_verification.eVoucher_id = eVoucher_transaction.eVoucher_id 
			 eVoucher_transaction.merchant_id = merchant.merchant_id
			 AND eVoucher_transaction.branch_code = branch.branch_code
			 AND customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
			 order by eVoucher_transaction.ID desc
			 --AND CAST(eVoucher_transaction.created_at as Date) BETWEEN @start_date AND @end_date
		
		END
END

--select * from eVoucher_transaction order by eVoucher_transaction.ID desc
