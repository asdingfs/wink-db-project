CREATE  PROCEDURE [dbo].[Get_ALL_Merchants_ByRedemption_With_Filter_backup]

@start_date varchar(50),
@end_date varchar(50),
@merchant_name varchar(100),
@mas_code varchar (50)

As

BEGIN

DECLARE @current_date datetime

exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

if(@start_date is null or @start_date ='')
 set @start_date =Null

if(@end_date is null or @end_date ='')
set @end_date = Null

if(@merchant_name is null or @merchant_name ='')
set @merchant_name = Null

if(@mas_code is null or @mas_code = '')
set @mas_code = Null

     Select * from 

	 (Select(merchant.first_name + ' '+  merchant.last_name) as merchant_name,merchant.mas_code, 

	 count (merchant.merchant_id)as no_of_redemptions,merchant.merchant_id

	 From eVoucher_transaction,merchant,branch,customer_earned_evouchers

	 Where 

	 eVoucher_transaction.merchant_id = merchant.merchant_id

	 AND eVoucher_transaction.branch_code = branch.branch_code

	 AND customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id

	 AND (@start_date is null or @end_date is null or ((cast(eVoucher_transaction.created_at as date) >= cast(@start_date as date)) and (cast(eVoucher_transaction.created_at as date) <= cast(@end_date as date))))

	 AND (@merchant_name is null or Concat(merchant.first_name,' ',merchant.last_name) like '%'+@merchant_name+'%')

	 AND (@mas_code is null or merchant.mas_code like '%'+@mas_code+'%')

	 AND customer_earned_evouchers.customer_id != 15

	 group by merchant.merchant_id,merchant.first_name + ' '+ 

	 merchant.last_name, merchant.mas_code,merchant.merchant_id

	 ) as T1

	 Left Join 

	(select COUNT(*) as today_redemption , a.merchant_id from eVoucher_transaction as a

	   Where CAST (@current_date As Date) =CAST (a.created_at as date)

	   and customer_id != 15

	  group by a.merchant_id,CAST (a.created_at as date)

	 ) as T2

	  ON T1.merchant_id =T2.merchant_id
	  order by t1.no_of_redemptions desc
END