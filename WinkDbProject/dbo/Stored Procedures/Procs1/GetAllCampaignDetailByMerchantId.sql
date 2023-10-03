Create PROCEDURE [dbo].[GetAllCampaignDetailByMerchantId]
(@merchant_id int)
AS
BEGIN
	SELECT campaign.campaign_id,campaign.merchant_id,campaign.campaign_name,campaign.campaign_code,
                             campaign.campaign_amount,campaign.sales_code,campaign.sales_commission,campaign.total_winks,
                             campaign.total_winks_amount,campaign.agency,campaign.created_at,campaign.updated_at,
                            campaign.percent_for_wink,campaign.cents_per_wink,campaign.campaign_start_date,
                            campaign.campaign_end_date,
                             merchant.first_name,merchant.last_name
                             FROM campaign ,merchant
                            WHERE campaign.merchant_id = merchant.merchant_id
                            AND campaign.merchant_id = @merchant_id
                            Order by campaign.campaign_id DESC
END
