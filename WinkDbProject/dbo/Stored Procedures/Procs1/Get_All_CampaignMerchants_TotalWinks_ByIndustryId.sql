CREATE PROCEDURE [dbo].[Get_All_CampaignMerchants_TotalWinks_ByIndustryId]
(
@industryId int
)
AS
BEGIN
DECLARE @CURRENT_DATE DATETIME

EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT

IF OBJECT_ID('tempdb..#CAMPAIGN_REDEEMEDWINKS_TABLE') IS NOT NULL DROP TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE

CREATE TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE
(
 merchant_id int,
 redeemed_winks int,
 campaigin_id int
)

IF OBJECT_ID('tempdb..#CAMPAIGN_REDEEMEDWINKS_TABLE2') IS NOT NULL DROP TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE2

CREATE TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE2
(
 merchant_id int,
 redeemed_winks int,
 campaigin_id int
)

INSERT INTO #CAMPAIGN_REDEEMEDWINKS_TABLE2 (merchant_id,campaigin_id,redeemed_winks)
SELECT customer_earned_winks.merchant_id,customer_earned_winks.campaign_id,
customer_earned_winks.total_winks
From customer_earned_winks
	JOIN campaign
	ON campaign.campaign_id  = customer_earned_winks.campaign_id
	WHERE
	(
	CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
		AND 
	CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
     )
		OR 
	(campaign.wink_purchase_only =1  AND	
	 Lower(campaign.wink_purchase_status) ='activate')

INSERT INTO #CAMPAIGN_REDEEMEDWINKS_TABLE (merchant_id,campaigin_id,redeemed_winks)
SELECT campaign.merchant_id,campaign.campaign_id,
ISNULL(#CAMPAIGN_REDEEMEDWINKS_TABLE2.redeemed_winks,0) 
From campaign
	JOIN #CAMPAIGN_REDEEMEDWINKS_TABLE2
	ON campaign.campaign_id  = #CAMPAIGN_REDEEMEDWINKS_TABLE2.campaigin_id
	WHERE
	(
	CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
		AND 
	CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
     )
		OR 
	(
	 campaign.wink_purchase_only = 1  AND	
	 Lower(campaign.wink_purchase_status) ='activate'
	 AND 
	 
	 (campaign.total_winks - ISNULL(#CAMPAIGN_REDEEMEDWINKS_TABLE2.redeemed_winks,0))>0
	 
           
	 )
	 


SELECT campaign.merchant_id,
     ( Select SUM(ISNULL(#CAMPAIGN_REDEEMEDWINKS_TABLE.redeemed_winks,0))
       From #CAMPAIGN_REDEEMEDWINKS_TABLE
       Where #CAMPAIGN_REDEEMEDWINKS_TABLE.merchant_id = campaign.merchant_id       
     )As redeemed_winks,
        
    (
	 SUM(campaign.total_winks) 
	 ) As all_time_total_winks, 
	campaign_ads_banner.small_banner,campaign_ads_banner.large_banner,campaign_ads_banner.large_url,
	
	merchant.first_name,merchant.last_name
	
	From campaign
	JOIN merchant
	ON campaign.merchant_id  = merchant.merchant_id
	JOIN merchant_industry
	ON
	campaign.merchant_id = merchant_industry.merchant_id
	AND merchant_industry.industry_id =@industryId
	LEFT JOIN campaign_ads_banner
	ON 
	campaign_ads_banner.merchant_id=campaign.merchant_id
	
	WHERE
	(
	CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
		AND 
	CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
     )
		OR 
	(
	 campaign.wink_purchase_only = 1  AND	
	 Lower(campaign.wink_purchase_status) ='activate'
	 AND (
	 campaign.total_winks - 
	 ISNULL((( Select SUM(ISNULL(#CAMPAIGN_REDEEMEDWINKS_TABLE.redeemed_winks,0))
       From #CAMPAIGN_REDEEMEDWINKS_TABLE
       Where #CAMPAIGN_REDEEMEDWINKS_TABLE.merchant_id = campaign.merchant_id
       
      )),0)) > 0
	 )
	
	GROUP By campaign.merchant_id,merchant.first_name,merchant.last_name,campaign_ads_banner.small_banner,
	campaign_ads_banner.large_banner,campaign_ads_banner.large_url
	Order By all_time_total_winks DESC
	
END

/*BEGIN
DECLARE @CURRENT_DATE DATETIME
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT
SELECT campaign.merchant_id,merchant.first_name,merchant.last_name,campaign.campaign_id,
	SUM(campaign.total_winks)AS all_time_total_winks,
	
	
     ( Select SUM(ISNULL(customer_earned_winks.total_winks,0))
     From customer_earned_winks Where customer_earned_winks.merchant_id = campaign.merchant_id
     AND customer_earned_winks.campaign_id = campaign.campaign_id
     )
     
    As redeemed_winks,
	
	campaign_ads_banner.small_banner,campaign_ads_banner.large_banner,campaign_ads_banner.large_url
	
	From campaign
	JOIN merchant
	ON campaign.merchant_id  = merchant.merchant_id
	JOIN merchant_industry
	ON
	campaign.merchant_id = merchant_industry.merchant_id
	LEFT JOIN campaign_ads_banner
	ON 
	campaign_ads_banner.merchant_id=campaign.merchant_id
	WHERE
	((CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111)
	AND CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111))
	OR (Lower(campaign.wink_purchase_status) = 'activate'))
	AND merchant_industry.industry_id =@industryId
	GROUP By campaign.merchant_id,merchant.first_name,merchant.last_name,campaign_ads_banner.small_banner,
	campaign_ads_banner.large_banner,campaign_ads_banner.large_url,campaign.campaign_id

	
END*/
