CREATE PROCEDURE [dbo].[Get_CampaignMerchants_TotalWinks_ByIndustryId_New]
(
@industryId int
)
AS
BEGIN
-- Update on 27/03/2016 - Confiscate WINK

-- Update on 27/03/2016 - ALL wink except 0 
DECLARE @CURRENT_DATE DATETIME

EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT
	
-- Campaign Normal WINK-----------------------------
IF OBJECT_ID('tempdb..#CAMPAIGN_REDEEMEDWINKS_TABLE_2') IS NOT NULL DROP TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE_2

	CREATE TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE_2
	(
	 merchant_id int,
	 redeemed_winks int,
	 campaign_id int
	)
	INSERT INTO #CAMPAIGN_REDEEMEDWINKS_TABLE_2 (merchant_id,campaign_id,redeemed_winks)
	SELECT customer_earned_winks.merchant_id,customer_earned_winks.campaign_id,
	customer_earned_winks.total_winks
	From customer_earned_winks
	JOIN campaign
	ON campaign.campaign_id  = customer_earned_winks.campaign_id
	WHERE
	campaign.campaign_status ='enable' AND -- Filter Only Enable
	--CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
	CAST (@CURRENT_DATE as datetime)>= DATEADD(day, DATEDIFF(day, 0, CAMPAIGN_START_DATE), '19:00:00')
	AND (
		    (campaign.wink_purchase_only = 1 and campaign.wink_purchase_status ='activate')
			OR (campaign.wink_purchase_only =0 )
		)
	
	
	/*(
	CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
		AND 
	CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
     )*/
	 --new add filter
	-- AND (campaign.wink_purchase_only != 1) --Filter Normal Campaign
      AND customer_earned_winks.merchant_id IN (Select merchant_industry.merchant_id
	 from merchant_industry where merchant_industry.industry_id =@industryId)
	 
IF OBJECT_ID('tempdb..#CAMPAIGN_2') IS NOT NULL DROP TABLE #CAMPAIGN_2

	CREATE TABLE #CAMPAIGN_2
	(
	 merchant_id int,
	 redeemed_winks int,
	 campaign_id int,
	 all_time_total_winks int
	)

	INSERT INTO #CAMPAIGN_2 (merchant_id,redeemed_winks,campaign_id,all_time_total_winks)
	SELECT campaign.merchant_id,
     ( Select SUM(ISNULL(#CAMPAIGN_REDEEMEDWINKS_TABLE_2.redeemed_winks,0))
       From #CAMPAIGN_REDEEMEDWINKS_TABLE_2
       --Where #CAMPAIGN_REDEEMEDWINKS_TABLE_2.merchant_id = campaign.merchant_id
       Where #CAMPAIGN_REDEEMEDWINKS_TABLE_2.campaign_id = campaign.campaign_id
       
     )As redeemed_winks,
        campaign_id,
    (
	 SUM(campaign.total_winks) + SUM(campaign.total_wink_confiscated)
	 ) As all_time_total_winks
	
	
	From campaign
		
	WHERE
	campaign.campaign_status ='enable' AND -- Filter Only Enable
	
	--CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
	CAST (@CURRENT_DATE as datetime)>= DATEADD(day, DATEDIFF(day, 0, CAMPAIGN_START_DATE), '19:00:00')	
	AND (
		    (campaign.wink_purchase_only = 1 and campaign.wink_purchase_status ='activate')
			OR (campaign.wink_purchase_only =0 )
		)
	
	
	/*(
	CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
		AND 
	CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
     )*/
	 --new add filter
	-- AND (campaign.wink_purchase_only != 1) --Filter Normal Campaign

     AND campaign.merchant_id IN (Select merchant_industry.merchant_id
	 from merchant_industry where merchant_industry.industry_id =@industryId)
	 GROUP By campaign.merchant_id,campaign.campaign_id
	 
	IF (@industryId != 12) 
	 BEGIN
	/*------------Display By Campaign --------------------*/
	SELECT #CAMPAIGN_2.merchant_id,SUM(#CAMPAIGN_2.redeemed_winks)as redeemed_winks,
	SUM(#CAMPAIGN_2.all_time_total_winks) as all_time_total_winks,
     
	campaign_ads_banner.small_banner,campaign_ads_banner.large_banner,campaign_ads_banner.large_url,
	
	merchant.first_name,merchant.last_name,campaign.campaign_name,#CAMPAIGN_2.campaign_id
	
	From #CAMPAIGN_2
	
	JOIN campaign
	
	ON campaign.campaign_id = #CAMPAIGN_2.campaign_id
	
	JOIN merchant
	ON #CAMPAIGN_2.merchant_id  = merchant.merchant_id
	JOIN merchant_industry
	ON
	#CAMPAIGN_2.merchant_id = merchant_industry.merchant_id
	AND merchant_industry.industry_id =@industryId
	LEFT JOIN campaign_ads_banner
	ON 
	campaign_ads_banner.merchant_id=#CAMPAIGN_2.merchant_id
	
	WHERE
	ISNULL(#CAMPAIGN_2.all_time_total_winks,0) - ISNULL(#CAMPAIGN_2.redeemed_winks,0)>0
	
	OR (#CAMPAIGN_2.campaign_id IN (Select campaign.campaign_id from campaign
			 where
			  CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
			
	))
	GROUP BY #CAMPAIGN_2.merchant_id,
	campaign_ads_banner.small_banner,campaign_ads_banner.large_banner,campaign_ads_banner.large_url,
	
	merchant.first_name,merchant.last_name,campaign.campaign_name,#CAMPAIGN_2.campaign_id
	--Update on 20062016 To remove 0 WINK+
	Having SUM(ISNULL(#CAMPAIGN_2.all_time_total_winks,0)) - SUM(ISNULL(#CAMPAIGN_2.redeemed_winks,0)) >0
	Order By all_time_total_winks DESC
	
	END
	ELSE IF (@industryId =12)
	
     BEGIN
	/*------------Display By Campaign --------------------*/
	SELECT #CAMPAIGN_2.merchant_id,SUM(#CAMPAIGN_2.redeemed_winks)as redeemed_winks,
	SUM(#CAMPAIGN_2.all_time_total_winks) as all_time_total_winks,
     
	campaign_ads_banner.small_banner,campaign_ads_banner.large_banner,campaign_ads_banner.large_url,
	
	merchant.first_name,merchant.last_name,campaign.campaign_name,#CAMPAIGN_2.campaign_id
	
	From #CAMPAIGN_2
	
	JOIN campaign
	
	ON campaign.campaign_id = #CAMPAIGN_2.campaign_id
	
	JOIN merchant
	ON #CAMPAIGN_2.merchant_id  = merchant.merchant_id
	JOIN merchant_industry
	ON
	#CAMPAIGN_2.merchant_id = merchant_industry.merchant_id
	AND merchant_industry.industry_id =@industryId
	LEFT JOIN campaign_ads_banner
	ON 
	campaign_ads_banner.merchant_id=#CAMPAIGN_2.merchant_id
	
	WHERE
	ISNULL(#CAMPAIGN_2.all_time_total_winks,0) - ISNULL(#CAMPAIGN_2.redeemed_winks,0)>0
	
	OR (#CAMPAIGN_2.campaign_id IN (Select campaign.campaign_id from campaign
			 where
			  CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
			
	))
	GROUP BY #CAMPAIGN_2.merchant_id,
	campaign_ads_banner.small_banner,campaign_ads_banner.large_banner,campaign_ads_banner.large_url,
	
	merchant.first_name,merchant.last_name,campaign.campaign_name,#CAMPAIGN_2.campaign_id
	
	Order By all_time_total_winks DESC
	
	END
	
     
	
	 
	
	/* -- Display By Merchant	
	SELECT #CAMPAIGN_2.merchant_id,SUM(#CAMPAIGN_2.redeemed_winks)as redeemed_winks,
	SUM(#CAMPAIGN_2.all_time_total_winks) as all_time_total_winks,
     
	campaign_ads_banner.small_banner,campaign_ads_banner.large_banner,campaign_ads_banner.large_url,
	
	merchant.first_name,merchant.last_name
	
	From #CAMPAIGN_2
	
	JOIN merchant
	ON #CAMPAIGN_2.merchant_id  = merchant.merchant_id
	JOIN merchant_industry
	ON
	#CAMPAIGN_2.merchant_id = merchant_industry.merchant_id
	AND merchant_industry.industry_id =@industryId
	LEFT JOIN campaign_ads_banner
	ON 
	campaign_ads_banner.merchant_id=#CAMPAIGN_2.merchant_id
	
	WHERE
	ISNULL(#CAMPAIGN_2.all_time_total_winks,0) - ISNULL(#CAMPAIGN_2.redeemed_winks,0)>0
	
	OR (#CAMPAIGN_2.campaign_id IN (Select campaign.campaign_id from campaign
			 where CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
	))
	

	GROUP BY #CAMPAIGN_2.merchant_id,
     
	campaign_ads_banner.small_banner,campaign_ads_banner.large_banner,campaign_ads_banner.large_url,
	
	merchant.first_name,merchant.last_name
	Order By all_time_total_winks DESC
	
	*/
	
	
END
