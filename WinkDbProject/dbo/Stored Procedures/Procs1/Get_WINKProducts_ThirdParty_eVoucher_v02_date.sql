CREATE procedure [dbo].[Get_WINKProducts_ThirdParty_eVoucher_v02_date]
(
	@merchant_name varchar(150),
	@eVoucher_code varchar(150),
	@branch_code varchar(150),
	@used_status varchar(10),
	@customer_name varchar(50),
	@email varchar(50),
	@customer_id varchar(50),
	@start_date datetime,
	@end_date datetime
)

AS
BEGIN

IF (@start_date is null or @start_date = '')
	BEGIN
	SET @start_date = NULL;
	END

IF (@end_date is null or @end_date = '')
	BEGIN
	SET @end_date = NULL;
	END

IF (@merchant_name is null or @merchant_name = '')
	BEGIN
	SET @merchant_name = NULL;
	END
 


IF (@eVoucher_code is null or @eVoucher_code = '')
	BEGIN
	SET @eVoucher_code = NULL;
	END
 
IF (@branch_code is null or @branch_code = '')
	BEGIN
	SET @branch_code = NULL;
	END
 
IF (@used_status is null or @used_status = '')
	BEGIN
	SET @used_status = NULL;
	END
 
IF (@customer_name is null or @customer_name = '')
	BEGIN
	SET @customer_name = NULL;
	END
 
IF (@email is null or @email = '')
	BEGIN
	SET @email = NULL;
	END
 
IF (@customer_id is null or @customer_id = '')
	BEGIN
	SET @customer_id = NULL;
	END
 
if( @start_date is null or @end_date is null)
	BEGIN

		select cus_e.eVoucher_code as wink_eVoucher_code,m.merchant_id,e.branch_id,e.eVoucher_code,e.used_status,e.price,Concat(m.first_name,' ',m.last_name) as merchant_name,e.created_at 
		,(c.first_name+' '+c.last_name)as name,c.email,r.created_at as redeemed_on,c.customer_id
		from wink_products_thirdparty_evoucher as e
		join
		merchant as m
		on m.merchant_id =e.merchant_id
		left join wink_products_redemption as r
		on e.id = r.thirdparty_eVoucher_id
		left join customer_earned_evouchers as cus_e
		on r.eVoucher_id =cus_e.earned_evoucher_id
		left join customer as c
		on cus_e.customer_id = c.customer_id
 
		where (@used_status is null or e.used_status = @used_status)
		and (@branch_code is null or e.branch_id =@branch_code)
		and (@eVoucher_code is null or e.eVoucher_code like '%'+@eVoucher_code+'%')
		and (@merchant_name is null or Concat(m.first_name,' ',m.last_name) like '%'+@merchant_name+'%')
		and (@customer_name is null or Concat(c.first_name,' ',c.last_name) like '%'+@customer_name+'%')
		and (@email is null or c.email like '%'+@email+'%')
		and (@customer_id  is null or c.customer_id = @customer_id)
		--and (@start_date IS NULL OR CAST(r.created_at as Date) BETWEEN @start_date AND @end_date)

		order by e.updated_at desc

	END
	ELSE

	BEGIN
		select cus_e.eVoucher_code as wink_eVoucher_code,m.merchant_id,e.branch_id,e.eVoucher_code,e.used_status,e.price,Concat(m.first_name,' ',m.last_name) as merchant_name,e.created_at 
		,(c.first_name+' '+c.last_name)as name,c.email,r.created_at as redeemed_on,c.customer_id
		from wink_products_thirdparty_evoucher as e
		join
		merchant as m
		on m.merchant_id =e.merchant_id
		left join wink_products_redemption as r
		on e.id = r.thirdparty_eVoucher_id
		left join customer_earned_evouchers as cus_e
		on r.eVoucher_id =cus_e.earned_evoucher_id
		left join customer as c
		on cus_e.customer_id = c.customer_id
 
		where 
		(@used_status is null or e.used_status = @used_status)
		and (@branch_code is null or e.branch_id =@branch_code)
		and (@eVoucher_code is null or e.eVoucher_code like '%'+@eVoucher_code+'%')
		and (@merchant_name is null or Concat(m.first_name,' ',m.last_name) like '%'+@merchant_name+'%')
		and (@customer_name is null or Concat(c.first_name,' ',c.last_name) like '%'+@customer_name+'%')
		and (@email is null or c.email like '%'+@email+'%')
		and (@customer_id  is null or c.customer_id = @customer_id)
		and (@start_date is null OR (CAST(e.updated_at as Date) BETWEEN @start_date AND @end_date))

		order by e.updated_at desc

	END

END
