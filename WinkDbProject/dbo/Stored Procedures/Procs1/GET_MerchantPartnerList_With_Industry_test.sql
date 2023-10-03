
CREATE Procedure [dbo].[GET_MerchantPartnerList_With_Industry_test]

AS 
BEGIN

SELECT  a.*, c.*, (select industry.industry_name from industry where a.industry_id = industry.industry_id ) as industry_name
--,e.industry_name

FROM merchant_partners a 

    INNER JOIN merchant_partners_address c
        ON a.merchant_id = c.merchant_id
    
	INNER JOIN
    (
        SELECT merchant_id,MIN(address_id)as address_id
        FROM merchant_partners_address
        Group By merchant_id
       
    ) b ON c.address_id = b.address_id
	
	
	--INNER JOIN industry e
	--ON a.industry_id = e.industry_id
	--order by a.name asc

END



          





