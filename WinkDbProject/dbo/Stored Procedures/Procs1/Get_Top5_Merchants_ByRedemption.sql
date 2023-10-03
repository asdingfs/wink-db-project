CREATE  PROCEDURE [dbo].[Get_Top5_Merchants_ByRedemption]

As
BEGIN
	 Select Top 5 (merchant.first_name + ' '+  merchant.last_name) as merchant_name,merchant.mas_code, count (merchant.merchant_id)as no_of_redemptions
	 From eVoucher_transaction,merchant,branch,customer_earned_evouchers
	 Where 
	 eVoucher_transaction.merchant_id = merchant.merchant_id
	 AND eVoucher_transaction.branch_code = branch.branch_code
	 AND customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
	 group by merchant.merchant_id,merchant.first_name + ' '+  merchant.last_name, merchant.mas_code order by no_of_redemptions desc
END
