CREATE procedure [dbo].[Get_WINKProducts_ThirdParty_eVoucher]
(
  @merchant_name varchar(150),
  @eVoucher_code varchar(150),
  @branch_code varchar(150),
  @used_status varchar(10)
    )

AS
BEGIN

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
 
 select e.merchant_id,e.branch_id,e.eVoucher_code,e.used_status,e.price,Concat(m.first_name,' ',m.last_name) as merchant_name,e.created_at from wink_products_thirdparty_evoucher as e,
 merchant as m 
 where m.merchant_id =e.merchant_id
 and (@used_status is null or e.used_status = @used_status)
 and (@branch_code is null or e.branch_id =@branch_code)
 and (@eVoucher_code is null or e.eVoucher_code = @eVoucher_code)
 and (@merchant_name is null or Concat(m.first_name,' ',m.last_name) like '%'+@merchant_name+'%')
 order by e.created_at desc
END


