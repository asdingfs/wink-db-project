CREATE PROCEDURE [dbo].[Get_CampaignMerchants_TotalWinks_ByIndustryId_Test]
(
@industryId int
)
AS
BEGIN
DECLARE @CURRENT_DATE DATETIME

EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT


-- Campaign WINK Purchase Only-----------------


IF OBJECT_ID('tempdb..#CAMPAIGN_REDEEMEDWINKS_TABLE_1') IS NOT NULL DROP TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE_1

	CREATE TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE_1
(
 merchant_id int,
 redeemed_winks int,
 campaign_id int
)
	INSERT INTO #CAMPAIGN_REDEEMEDWINKS_TABLE_1 (merchant_id,campaign_id,redeemed_winks)
	SELECT customer_earned_winks.merchant_id,customer_earned_winks.campaign_id,
	customer_earned_winks.total_winks
	From customer_earned_winks
	JOIN campaign
	ON campaign.campaign_id  = customer_earned_winks.campaign_id
	WHERE
	campaign.campaign_status ='enable' AND -- Filter Only Enable
	
	(campaign.wink_purchase_only = 1  AND	
	 Lower(campaign.wink_purchase_status) ='activate')
	 AND customer_earned_winks.merchant_id IN (Select merchant_industry.merchant_id
	 from merchant_industry where merchant_industry.industry_id =@industryId)
	
	
	--Select * from  #CAMPAIGN_REDEEMEDWINKS_TABLE_1


IF OBJECT_ID('tempdb..#CAMPAIGN_1') IS NOT NULL DROP TABLE #CAMPAIGN_1

	CREATE TABLE #CAMPAIGN_1
(
 merchant_id int,
 redeemed_winks int,
 campaign_id int,
 all_time_total_winks int
)

	INSERT INTO #CAMPAIGN_1(merchant_id,redeemed_winks,campaign_id,all_time_total_winks)
	SELECT campaign.merchant_id,
     ( Select SUM(ISNULL(#CAMPAIGN_REDEEMEDWINKS_TABLE_1.redeemed_winks,0))
       From #CAMPAIGN_REDEEMEDWINKS_TABLE_1
       Where #CAMPAIGN_REDEEMEDWINKS_TABLE_1.campaign_id = campaign.campaign_id
       
     )As redeemed_winks,
      campaign.campaign_id,
    (
	 SUM(campaign.total_winks)
	 
	 ) As all_time_total_winks
	
	From campaign
		
	WHERE
	campaign.merchant_id IN (Select merchant_industry.merchant_id
	 from merchant_industry where merchant_industry.industry_id =@industryId)AND
	campaign.campaign_status ='enable' AND -- Filter Only Enable
	(campaign.wink_purchase_only =1  AND	
	 Lower(campaign.wink_purchase_status) ='activate')
	
	GROUP By campaign.campaign_id,campaign.merchant_id
	
    --select * from #CAMPAIGN_1
	
		
	
-- Campaign Normal -----------------------------

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
	campaign.wink_purchase_only =0 AND --Filter Normal Campaign
	(
	CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
		AND 
	CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
     )
	 --new add filter
	 AND (campaign.wink_purchase_only != 1)
      AND customer_earned_winks.merchant_id IN (Select merchant_industry.merchant_id
	 from merchant_industry where merchant_industry.industry_id =@industryId)
	 
	 Select * from #CAMPAIGN_REDEEMEDWINKS_TABLE_2
	 
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
      -- Where #CAMPAIGN_REDEEMEDWINKS_TABLE_2.merchant_id = campaign.merchant_id
      Where #CAMPAIGN_REDEEMEDWINKS_TABLE_2.campaign_id = campaign.campaign_id
       
     )As redeemed_winks,
        campaign_id,
    (
	 SUM(campaign.total_winks)
	 ) As all_time_total_winks
	
	
	From campaign
		
	WHERE
	campaign.campaign_status ='enable' AND -- Filter Only Enable
	campaign.wink_purchase_only =0 AND --Filter Normal Campaign
	(
	CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
		AND 
	CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
     )
	 --new add filter
	 AND (campaign.wink_purchase_only != 1)

     AND campaign.merchant_id IN (Select merchant_industry.merchant_id
	 from merchant_industry where merchant_industry.industry_id =@industryId)
	 GROUP By campaign.merchant_id,campaign.campaign_id
	 
	Select * from #CAMPAIGN_2
	
	
-- REMOVE 0 Balance from Purchase Only	
   IF OBJECT_ID('tempdb..#CAMPAIGN_3') IS NOT NULL DROP TABLE #CAMPAIGN_3

	CREATE TABLE #CAMPAIGN_3
	(
	merchant_id int,
	redeemed_winks int,
	campaigin_id int,
	all_time_total_winks int
	)

	INSERT INTO #CAMPAIGN_3 (merchant_id,redeemed_winks,campaigin_id,all_time_total_winks)
	SELECT #CAMPAIGN_1.merchant_id,#CAMPAIGN_1.redeemed_winks,#CAMPAIGN_1.campaign_id,#CAMPAIGN_1.all_time_total_winks
	FROM #CAMPAIGN_1 WHERE (ISNULL(#CAMPAIGN_1.all_time_total_winks,0)-ISNULL(#CAMPAIGN_1.redeemed_winks,0))>0
	
	--SELECT * from #CAMPAIGN_3
	
-- JOIN Tables
   
    IF OBJECT_ID('tempdb..#CAMPAIGN_4') IS NOT NULL DROP TABLE #CAMPAIGN_4

	CREATE TABLE #CAMPAIGN_4
	(
	merchant_id int,
	redeemed_winks int,
	campaigin_id int,
	all_time_total_winks int,
	)

	INSERT INTO #CAMPAIGN_4 (merchant_id,redeemed_winks,campaigin_id,all_time_total_winks)
	SELECT #CAMPAIGN_2.merchant_id,#CAMPAIGN_2.redeemed_winks,#CAMPAIGN_2.campaign_id,#CAMPAIGN_2.all_time_total_winks
	FROM #CAMPAIGN_2
	UNION
	SELECT #CAMPAIGN_3.merchant_id,
	#CAMPAIGN_3.redeemed_winks,#CAMPAIGN_3.campaigin_id,#CAMPAIGN_3.all_time_total_winks
	FROM #CAMPAIGN_3
	
	--Select * from #CAMPAIGN_4 
	
	 IF OBJECT_ID('tempdb..#CAMPAIGN_5') IS NOT NULL DROP TABLE #CAMPAIGN_5

	CREATE TABLE #CAMPAIGN_5
	(
	merchant_id int,
	redeemed_winks int,
	--campaigin_id int,
	all_time_total_winks int,
	)
	
	INSERT INTO #CAMPAIGN_5 (merchant_id,redeemed_winks,all_time_total_winks)
	SELECT #CAMPAIGN_4.merchant_id,SUM(ISNULL(#CAMPAIGN_4.redeemed_winks,0)),
	SUM(ISNULL(#CAMPAIGN_4.all_time_total_winks,0))
	FROM #CAMPAIGN_4
	GROUP BY #CAMPAIGN_4.merchant_id
	
	--select * from #CAMPAIGN_5
	
	
	SELECT #CAMPAIGN_5.merchant_id,#CAMPAIGN_5.redeemed_winks,#CAMPAIGN_5.all_time_total_winks,
     
	campaign_ads_banner.small_banner,campaign_ads_banner.large_banner,campaign_ads_banner.large_url,
	
	merchant.first_name,merchant.last_name
	
	From #CAMPAIGN_5
	
	JOIN merchant
	ON #CAMPAIGN_5.merchant_id  = merchant.merchant_id
	JOIN merchant_industry
	ON
	#CAMPAIGN_5.merchant_id = merchant_industry.merchant_id
	AND merchant_industry.industry_id =@industryId
	LEFT JOIN campaign_ads_banner
	ON 
	campaign_ads_banner.merchant_id=#CAMPAIGN_5.merchant_id
	
	Order By all_time_total_winks DESC
	
END

/*BEGIN
DECLARE @CURRENT_DATE DATETIME

EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT
-- Campaign WINK Purchase Only
IF OBJECT_ID('tempdb..#CAMPAIGN_REDEEMEDWINKS_TABLE_1') IS NOT NULL DROP TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE_1

	CREATE TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE_1
(
 merchant_id int,
 redeemed_winks int,
 campaigin_id int
)
	INSERT INTO #CAMPAIGN_REDEEMEDWINKS_TABLE_1 (merchant_id,campaigin_id,redeemed_winks)
	SELECT customer_earned_winks.merchant_id,customer_earned_winks.campaign_id,
	customer_earned_winks.total_winks
	From customer_earned_winks
	JOIN campaign
	ON campaign.campaign_id  = customer_earned_winks.campaign_id
	WHERE
	campaign.campaign_status ='enable' AND -- Filter Only Enable
	
	(campaign.wink_purchase_only =1  AND	
	 Lower(campaign.wink_purchase_status) ='activate')
	 AND customer_earned_winks.merchant_id IN (Select merchant_industry.merchant_id
	 from merchant_industry where merchant_industry.industry_id =@industryId)
	 
IF OBJECT_ID('tempdb..#CAMPAIGN_1') IS NOT NULL DROP TABLE #CAMPAIGN_1

	CREATE TABLE #CAMPAIGN_1
(
 merchant_id int,
 redeemed_winks int,
 --campaigin_id int,
 all_time_total_winks int
)

	INSERT INTO #CAMPAIGN_1 (merchant_id,redeemed_winks,all_time_total_winks)
	SELECT campaign.merchant_id,
     ( Select SUM(ISNULL(#CAMPAIGN_REDEEMEDWINKS_TABLE_1.redeemed_winks,0))
       From #CAMPAIGN_REDEEMEDWINKS_TABLE_1
       Where #CAMPAIGN_REDEEMEDWINKS_TABLE_1.merchant_id = campaign.merchant_id
       
     )As redeemed_winks,
        
    (
	 SUM(campaign.total_winks)
	 ) As all_time_total_winks
	
	
	From campaign
		
	WHERE
	campaign.campaign_status ='enable' AND -- Filter Only Enable
	(campaign.wink_purchase_only =1  AND	
	 Lower(campaign.wink_purchase_status) ='activate')
	 AND campaign.merchant_id IN (Select merchant_industry.merchant_id
	 from merchant_industry where merchant_industry.industry_id =@industryId)
	GROUP By campaign.merchant_id
	
	
-- Campaign Normal WINK-----------------------------
IF OBJECT_ID('tempdb..#CAMPAIGN_REDEEMEDWINKS_TABLE_2') IS NOT NULL DROP TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE_1

	CREATE TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE_2
	(
	 merchant_id int,
	 redeemed_winks int,
	 campaigin_id int
	)
	INSERT INTO #CAMPAIGN_REDEEMEDWINKS_TABLE_2 (merchant_id,campaigin_id,redeemed_winks)
	SELECT customer_earned_winks.merchant_id,customer_earned_winks.campaign_id,
	customer_earned_winks.total_winks
	From customer_earned_winks
	JOIN campaign
	ON campaign.campaign_id  = customer_earned_winks.campaign_id
	WHERE
	campaign.campaign_status ='enable' AND -- Filter Only Enable
	(
	CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
		AND 
	CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
     )
	 --new add filter
	 AND (campaign.wink_purchase_only != 1)
      AND customer_earned_winks.merchant_id IN (Select merchant_industry.merchant_id
	 from merchant_industry where merchant_industry.industry_id =@industryId)
	 
IF OBJECT_ID('tempdb..#CAMPAIGN_2') IS NOT NULL DROP TABLE #CAMPAIGN_2

	CREATE TABLE #CAMPAIGN_2
	(
	 merchant_id int,
	 redeemed_winks int,
	 --campaigin_id int,
	 all_time_total_winks int
	)

	INSERT INTO #CAMPAIGN_2 (merchant_id,redeemed_winks,all_time_total_winks)
	SELECT campaign.merchant_id,
     ( Select SUM(ISNULL(#CAMPAIGN_REDEEMEDWINKS_TABLE_2.redeemed_winks,0))
       From #CAMPAIGN_REDEEMEDWINKS_TABLE_2
       Where #CAMPAIGN_REDEEMEDWINKS_TABLE_2.merchant_id = campaign.merchant_id
       
     )As redeemed_winks,
        
    (
	 SUM(campaign.total_winks)
	 ) As all_time_total_winks
	
	
	From campaign
		
	WHERE
	campaign.campaign_status ='enable' AND -- Filter Only Enable
	(
	CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
		AND 
	CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
     )
	 --new add filter
	 AND (campaign.wink_purchase_only != 1)

     AND campaign.merchant_id IN (Select merchant_industry.merchant_id
	 from merchant_industry where merchant_industry.industry_id =@industryId)
	 GROUP By campaign.merchant_id
	
	
-- REMOVE 0 Balance from Purchase Only	
   IF OBJECT_ID('tempdb..#CAMPAIGN_3') IS NOT NULL DROP TABLE #CAMPAIGN_3

	CREATE TABLE #CAMPAIGN_3
	(
	merchant_id int,
	redeemed_winks int,
	--campaigin_id int,
	all_time_total_winks int
	)

	INSERT INTO #CAMPAIGN_3 (merchant_id,redeemed_winks,all_time_total_winks)
	SELECT #CAMPAIGN_1.merchant_id,#CAMPAIGN_1.redeemed_winks,#CAMPAIGN_1.all_time_total_winks
	FROM #CAMPAIGN_1 WHERE (ISNULL(#CAMPAIGN_1.all_time_total_winks,0)-ISNULL(#CAMPAIGN_1.redeemed_winks,0))>0
	
-- JOIN Tables
   
    IF OBJECT_ID('tempdb..#CAMPAIGN_4') IS NOT NULL DROP TABLE #CAMPAIGN_4

	CREATE TABLE #CAMPAIGN_4
	(
	merchant_id int,
	redeemed_winks int,
	--campaigin_id int,
	all_time_total_winks int,
	)

	INSERT INTO #CAMPAIGN_4 (merchant_id,redeemed_winks,all_time_total_winks)
	SELECT #CAMPAIGN_2.merchant_id,#CAMPAIGN_2.redeemed_winks,#CAMPAIGN_2.all_time_total_winks
	FROM #CAMPAIGN_2
	UNION
	SELECT #CAMPAIGN_3.merchant_id,
	#CAMPAIGN_3.redeemed_winks,#CAMPAIGN_3.all_time_total_winks
	FROM #CAMPAIGN_3
	
	 IF OBJECT_ID('tempdb..#CAMPAIGN_5') IS NOT NULL DROP TABLE #CAMPAIGN_5

	CREATE TABLE #CAMPAIGN_5
	(
	merchant_id int,
	redeemed_winks int,
	--campaigin_id int,
	all_time_total_winks int,
	)
	
	INSERT INTO #CAMPAIGN_5 (merchant_id,redeemed_winks,all_time_total_winks)
	SELECT #CAMPAIGN_4.merchant_id,SUM(ISNULL(#CAMPAIGN_4.redeemed_winks,0)),
	SUM(ISNULL(#CAMPAIGN_4.all_time_total_winks,0))
	FROM #CAMPAIGN_4
	GROUP BY #CAMPAIGN_4.merchant_id
	
	
	--SELECT * from #CAMPAIGN_4
	
	--SELECT * from #CAMPAIGN_5
	
	-- Start Campaign 
	
	SELECT #CAMPAIGN_5.merchant_id,#CAMPAIGN_5.redeemed_winks,#CAMPAIGN_5.all_time_total_winks,
     
	campaign_ads_banner.small_banner,campaign_ads_banner.large_banner,campaign_ads_banner.large_url,
	
	merchant.first_name,merchant.last_name
	
	From #CAMPAIGN_5
	
	JOIN merchant
	ON #CAMPAIGN_5.merchant_id  = merchant.merchant_id
	JOIN merchant_industry
	ON
	#CAMPAIGN_5.merchant_id = merchant_industry.merchant_id
	AND merchant_industry.industry_id =@industryId
	LEFT JOIN campaign_ads_banner
	ON 
	campaign_ads_banner.merchant_id=#CAMPAIGN_5.merchant_id
	
	Order By all_time_total_winks DESC
  
 
END*/

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

--select * from industry where industry.industry_id =86
--select * from campaign where campaign.wink_purchase_only=0 and merchant_id =1
--and campaign.wink_purchase_status ='activate'
--select * from merchant_industry

--select * from customer_earned_winks where customer_earned_winks.merchant_id=1
--select * from campaign where campaign.campaign_id =110

/*select SUM(campaign.total_winks),merchant_id from campaign
WHERE
	campaign.campaign_status ='enable' AND
	(campaign.wink_purchase_only =1  AND	
	 Lower(campaign.wink_purchase_status) ='activate')
	
	GROUP By campaign.merchant_id
	
select * from campaign WHERE
    campaign.merchant_id = 1023 AND
	campaign.campaign_status ='enable' AND
	(campaign.wink_purchase_only =1  AND	
	 Lower(campaign.wink_purchase_status) ='activate') */
