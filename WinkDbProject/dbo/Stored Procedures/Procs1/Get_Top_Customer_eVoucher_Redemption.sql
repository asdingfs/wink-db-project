CREATE PROCEDURE [dbo].[Get_Top_Customer_eVoucher_Redemption]
AS
BEGIN
Select Top 5 eVoucher_transaction.ID,eVoucher_transaction.transaction_id,eVoucher_transaction.eVoucher_amount,eVoucher_transaction.eVoucher_id,
customer_earned_evouchers.eVoucher_code,
eVoucher_transaction.created_at,eVoucher_transaction.branch_code,merchant.first_name as m_first_name,
merchant.last_name as m_last_name, customer.first_name as c_first_name, customer.last_name as c_last_name
from eVoucher_transaction ,customer_earned_evouchers, merchant,customer , branch
where  eVoucher_transaction.customer_id = customer.customer_id
AND eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
And eVoucher_transaction.branch_code = branch.branch_code
AND branch.merchant_id = merchant.merchant_id
ORDER BY eVoucher_transaction.ID DESC

END
