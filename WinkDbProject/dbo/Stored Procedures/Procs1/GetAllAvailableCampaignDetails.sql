CREATE PROCEDURE [dbo].[GetAllAvailableCampaignDetails]
	
AS
BEGIN
	DECLARE @CURRENT_DATE DATETIME
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT

	SELECT campaign.campaign_id, campaign.campaign_name,
	campaign.campaign_amount, campaign.total_winks, campaign.total_winks_amount,
    campaign.campaign_start_date, campaign.campaign_end_date,
    merchant.first_name, merchant.last_name,
	campaign.created_at
	FROM campaign, merchant
    WHERE campaign.merchant_id = merchant.merchant_id
    AND campaign.wink_purchase_only =0
    AND campaign.campaign_status='enable'
    AND CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
	AND campaign_id not in 
		(SELECT campaign_id FROM wink_gate_campaign)
    Order by campaign.campaign_id DESC
END
