CREATE PROCEDURE [dbo].[GetTopMerchantBySponsorWinks]
AS
BEGIN
DECLARE @CURRENT_DATE DATETIME
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUT
SELECT TOP 5 campaign.merchant_id,
     ( Select SUM(ISNULL(customer_earned_winks.total_winks,0))
       From customer_earned_winks 
       Where customer_earned_winks.merchant_id = campaign.merchant_id
       
     )As redeemed_winks,
        
    (
	 SUM(campaign.total_winks)
	 ) As all_time_total_winks, 
	campaign_ads_banner.small_banner,campaign_ads_banner.large_banner,campaign_ads_banner.large_url,
	
	merchant.first_name,merchant.last_name
	
	From campaign
	JOIN merchant
	ON campaign.merchant_id  = merchant.merchant_id
	LEFT JOIN campaign_ads_banner
	ON 
	campaign_ads_banner.merchant_id=campaign.merchant_id
	
	WHERE
	((CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111)
	AND
	CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111))
    OR (Lower(campaign.wink_purchase_status)='activate')
	)
	GROUP By campaign.merchant_id,merchant.first_name,merchant.last_name,campaign_ads_banner.small_banner,
	campaign_ads_banner.large_banner,campaign_ads_banner.large_url
	/*Order By DESC*/
	
END
