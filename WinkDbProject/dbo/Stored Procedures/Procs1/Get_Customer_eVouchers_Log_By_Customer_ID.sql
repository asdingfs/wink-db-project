
CREATE PROCEDURE [dbo].[Get_Customer_eVouchers_Log_By_Customer_ID]
	(@customer_id int)
AS
BEGIN
/*SELECT customer_earned_evouchers.customer_id,customer_earned_evouchers.eVoucher_code,
customer_earned_evouchers.redeemed_winks,customer_earned_evouchers.created_at,customer_earned_evouchers.redeemed_date,

eVoucher_verification.verification_code,
eVoucher_verification.branch_id,branch.branch_name,
merchant.first_name as m_first_name , merchant.last_name as m_last_name,
merchant.merchant_id
from customer_earned_evouchers,eVoucher_verification,branch,merchant
WHERE 
customer_earned_evouchers.earned_evoucher_id = eVoucher_verification.eVoucher_id
AND eVoucher_verification.branch_id = branch.branch_code
AND branch.merchant_id = merchant.merchant_id
AND customer_earned_evouchers.customer_id =@customer_id*/


SELECT customer_earned_evouchers.customer_id,customer_earned_evouchers.eVoucher_code,customer_earned_evouchers.expired_date,
customer_earned_evouchers.eVoucher_amount,
customer.first_name as c_first_name,customer.last_name as c_last_name,customer.WID as wid,
customer_earned_evouchers.redeemed_winks,
customer_earned_evouchers.created_at,
customer_earned_evouchers.used_status,
eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
(SELECT Top 1 eVoucher_verification .verification_code from eVoucher_verification
 where eVoucher_verification.eVoucher_id = customer_earned_evouchers .earned_evoucher_id
 Order by eVoucher_verification.created_at DESC) AS verification_code,merchant.merchant_id,
 eVoucher_transaction.transaction_id,
  merchant.first_name as m_first_name , merchant.last_name as m_last_name,
 branch.branch_name
from customer_earned_evouchers JOIN customer ON
customer_earned_evouchers.customer_id = customer.customer_id
LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
LEFT JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code

WHERE customer_earned_evouchers.customer_id = @customer_id

Order by customer_earned_evouchers.created_at DESC

END
