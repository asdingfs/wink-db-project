CREATE PROCEDURE [dbo].[GetAllMerchantDetailByIndustryId]
	(@industry_id int)
AS
BEGIN
	SELECT merchant.merchant_id,merchant.first_name,
                                 merchant.last_name,merchant.email,merchant.password,merchant.mas_code,
                                 merchant.created_at,merchant.updated_at,industry.industry_name,
                                 campaign_ads_banner.small_banner,campaign_ads_banner.large_banner
                                 FROM merchant_industry JOIN 
                                 industry ON merchant_industry.industry_id = industry.industry_id
                                 JOIN merchant
                                 ON merchant.merchant_id = merchant_industry.merchant_id
                                 LEFT JOIN
                                 campaign_ads_banner
                                 ON merchant.merchant_id = campaign_ads_banner.merchant_id
                                 WHERE merchant_industry.industry_id = @industry_id
	
END
