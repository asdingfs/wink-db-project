
CREATE Procedure [dbo].[GET_MerchantPartnerList_With_Industry]
(@merchantName varchar(250))
AS
BEGIN

Declare @name varchar(250)
SET @name = ''

IF (@merchantName IS NOT NULL)
	 BEGIN
	 SET @name = @merchantName;
	 END


SELECT  a.*, ISNULL(d.address_id,0) as address_id,d.outlet_address,d.outlet_email,d.outlet_name, d.postal_code,d.phone, (select industry.industry_name from industry where a.industry_id = industry.industry_id ) as industry_name


FROM merchant_partners a 

    Left JOIN 
	(
     Select c.address_id,c.outlet_address,c.merchant_id,c.outlet_email,c.outlet_name,c.postal_code,c.phone from merchant_partners_address as c  
	INNER JOIN
    (
        SELECT merchant_id,MIN(address_id)as address_id
        FROM merchant_partners_address
        Group By merchant_id
       
    ) b ON c.address_id = b.address_id
	
	) d
    on a.merchant_id = d.merchant_id
	
	where a.name Like '%'+ @name +'%'
	order by a.created_at desc


END



          











