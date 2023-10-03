CREATE procedure [dbo].[gst_testing1]

	@start_date datetime,
	@end_date datetime,
	@merchant_name varchar(100),
	@branch_name varchar(100),
	@branch_id int

AS


BEGIN
print(@branch_id);
	IF (@branch_id = 0)
	BEGIN
		SET @branch_id = NULL;
	END
	
Declare @gst8Percent  float;
set @gst8Percent=0.08;
Declare @gst7Percent float;
set @gst7Percent=0.07;

IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')
	
	BEGIN
			print @gst8Percent
			Select eVoucher_transaction.transaction_id,eVoucher_transaction.merchant_id,
			eVoucher_transaction.customer_id,eVoucher_transaction.customer_name,eVoucher_transaction.customer_email,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at,eVoucher_transaction.eVoucher_id,
			merchant.mas_code,branch.branch_name,eVoucher_transaction.verification_code,
			customer_earned_evouchers.eVoucher_code,
			eVoucher_transaction.eVoucher_amount,merchant.first_name,merchant.last_name,eVoucher_transaction.order_no,
			fee.balance_redeemed_amount as merchant_payable, 
			CASE 
			WHEN(merchant.wink_fee_percent is not null AND merchant.wink_fee_percent != 0 AND  YEAR(eVoucher_transaction.created_at) >='2021')
			THEN (ISNULL(fee.wink_fee_amount*@gst8Percent,0))
			WHEN(merchant.wink_fee_percent is not null AND merchant.wink_fee_percent != 0 AND  YEAR(eVoucher_transaction.created_at) <'2021')
			THEN (ISNULL(fee.wink_fee_amount*@gst7Percent,0))
			ELSE 0 END
			AS gst,fee.wink_fee_amount
			From eVoucher_transaction,merchant,branch,customer_earned_evouchers
		LEFT join WINK_Redemption_Detail_With_WINK_Fees as fee 
		on fee.evoucher_id = customer_earned_evouchers.earned_evoucher_id
		WHERE eVoucher_transaction.merchant_id = merchant.merchant_id
		AND eVoucher_transaction.branch_code = branch.branch_code
		AND customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
		AND CAST(eVoucher_transaction.created_at as Date) BETWEEN @start_date AND @end_date
		AND (@merchant_name IS NULL OR merchant.first_name + ' ' + merchant.last_name LIKE  '%'+@merchant_name + '%')
		AND (@branch_name IS NULL OR branch.branch_name LIKE '%'+@branch_name + '%')
		AND (@branch_id IS NULL OR eVoucher_transaction.branch_code = @branch_id)
		AND customer_earned_evouchers.customer_id !=15 -- Testing Account
		order by eVoucher_transaction.ID desc
		END
ELSE
		BEGIN
			print @gst8Percent
			Select eVoucher_transaction.transaction_id,eVoucher_transaction.merchant_id,
			eVoucher_transaction.customer_id,eVoucher_transaction.customer_name,eVoucher_transaction.customer_email,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at,eVoucher_transaction.eVoucher_id,
			merchant.mas_code,branch.branch_name,eVoucher_transaction.verification_code,
			customer_earned_evouchers.eVoucher_code,
			eVoucher_transaction.eVoucher_amount,merchant.first_name,merchant.last_name,eVoucher_transaction.order_no,
			fee.balance_redeemed_amount as merchant_payable, 
			CASE 
			WHEN(merchant.wink_fee_percent is not null AND merchant.wink_fee_percent != 0 AND  YEAR(eVoucher_transaction.created_at) >='2021')
			THEN (ISNULL(fee.wink_fee_amount*@gst8Percent,0))
			WHEN(merchant.wink_fee_percent is not null AND merchant.wink_fee_percent != 0 AND  YEAR(eVoucher_transaction.created_at) <'2021')
			THEN (ISNULL(fee.wink_fee_amount*@gst7Percent,0))
			
			ELSE 0 END
			AS gst,fee.wink_fee_amount
			From eVoucher_transaction,merchant,branch,customer_earned_evouchers
		LEFT join WINK_Redemption_Detail_With_WINK_Fees as fee 
		on fee.evoucher_id = customer_earned_evouchers.earned_evoucher_id
		WHERE eVoucher_transaction.merchant_id = merchant.merchant_id
		AND eVoucher_transaction.branch_code = branch.branch_code
		AND customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
		AND (@merchant_name IS NULL OR merchant.first_name + ' ' + merchant.last_name LIKE  '%'+@merchant_name + '%')
		AND (@branch_name IS NULL OR branch.branch_name LIKE '%'+@branch_name + '%')
		AND (@branch_id IS NULL OR eVoucher_transaction.branch_code = @branch_id)
		AND customer_earned_evouchers.customer_id !=15 -- Testing Account
		order by eVoucher_transaction.ID desc
		END
END

