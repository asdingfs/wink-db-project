CREATE PROCEDURE [dbo].[GetAlLCampaignDetail_Without_PurchasedOnly]
	
AS
BEGIN
DECLARE @CURRENT_DATE DATETIME
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT
SELECT campaign.campaign_id,campaign.merchant_id,campaign.campaign_name,
	                         campaign.campaign_code,
                             campaign.campaign_amount,campaign.sales_code,
                             campaign.sales_commission,campaign.total_winks,
                             campaign.total_winks_amount,
                             campaign.agency,campaign.created_at,
                             campaign.updated_at,
                            campaign.percent_for_wink,
                            campaign.cents_per_wink,
                            campaign.campaign_start_date,
                            campaign.campaign_end_date,
                            campaign.wink_purchase_only,
                            campaign.wink_purchase_status,
                             merchant.first_name,merchant.last_name,
                            (SELECT COUNT(customer_earned_points.campaign_id) FROM customer_earned_points 
                             WHERE 
                            customer_earned_points.campaign_id = campaign.campaign_id) AS TotalScan
                            
                            FROM campaign ,merchant
                            WHERE campaign.merchant_id = merchant.merchant_id
                            AND campaign.wink_purchase_only =0
                            AND campaign.campaign_status='enable'
                            AND CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
                            Order by campaign.campaign_id DESC
END
