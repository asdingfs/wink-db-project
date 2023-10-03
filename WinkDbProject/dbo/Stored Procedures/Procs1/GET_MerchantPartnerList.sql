CREATE Procedure [dbo].[GET_MerchantPartnerList]
/*(@merchant_name varchar(150)
)*/
AS 
BEGIN
SELECT  a.*, c.*
FROM merchant_partners a 
    INNER JOIN merchant_partners_address c
        ON a.merchant_id = c.merchant_id
    INNER JOIN
    (
        SELECT merchant_id,MIN(address_id)as address_id
        FROM merchant_partners_address
        Group By merchant_id
       
    ) b ON c.address_id = b.address_id
   -- Where Lower(a.name) Like ('%'+@merchant_name+'%')
END
