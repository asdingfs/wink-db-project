

CREATE PROCEDURE [dbo].[GET_Merchant_Partner_Name_Industry]
	(@merchant_id varchar(50))
AS
BEGIN

	Select merchant_partners.*, (select industry.industry_name from industry where merchant_partners.industry_id = industry.industry_id ) as industry_name
	
	From merchant_partners Where [merchant_id] = @merchant_id 
	
	
	

	
	
END


