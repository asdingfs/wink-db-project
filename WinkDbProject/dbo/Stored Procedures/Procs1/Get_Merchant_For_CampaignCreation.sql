CREATE PROCEDURE [dbo].[Get_Merchant_For_CampaignCreation]
AS
BEGIN
	Select * from merchant , merchant_industry
	where merchant.merchant_id = merchant_industry.merchant_id
	order by merchant.first_name
END
