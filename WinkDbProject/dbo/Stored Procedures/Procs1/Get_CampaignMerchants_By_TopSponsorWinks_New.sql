CREATE PROCEDURE [dbo].[Get_CampaignMerchants_By_TopSponsorWinks_New]
AS
BEGIN

-- Update on 27/03/2016 - Confiscate WINK

-- Update on 27/03/2016 - ALL wink except 0 

DECLARE @CURRENT_DATE DATETIME

EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT

IF OBJECT_ID('tempdb..#CAMPAIGN_REDEEMEDWINKS_TABLE') IS NOT NULL DROP TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE
--1. Redeem WINKs 
CREATE TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE
(
 merchant_id int,
 redeemed_winks int,
 campaigin_id int
)
INSERT INTO #CAMPAIGN_REDEEMEDWINKS_TABLE (merchant_id,campaigin_id,redeemed_winks)
SELECT customer_earned_winks.merchant_id,customer_earned_winks.campaign_id,
customer_earned_winks.total_winks
From customer_earned_winks
	JOIN campaign
	ON campaign.campaign_id  = customer_earned_winks.campaign_id
	WHERE
	campaign.campaign_status = 'enable' -- Filter Only Enable
	AND
	CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
	AND campaign.campaign_id NOT IN (select campaign.campaign_id from campaign
	where campaign.wink_purchase_only =1 and campaign.wink_purchase_status ='on hold')
	/*(
	(
	CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
	AND 
	CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
     
     )
		OR 
	(campaign.wink_purchase_only =1  AND	
	 Lower(campaign.wink_purchase_status) ='activate'))*/

--2. Avaiable WINKs 

IF OBJECT_ID('tempdb..#CAMPAIGN_TABLE_1') IS NOT NULL DROP TABLE #CAMPAIGN_TABLE_1

CREATE TABLE #CAMPAIGN_TABLE_1
(
 campaign_id int,
 merchant_id int,
 redeemed_winks int,
 all_time_total_winks int,
 small_banner varchar(200),
 large_banner varchar(200),
 large_url varchar(200),
 first_name varchar(200),
 last_name varchar(200)
)
INSERT INTO #CAMPAIGN_TABLE_1
SELECT campaign.campaign_id,campaign.merchant_id,
     ( Select SUM(ISNULL(#CAMPAIGN_REDEEMEDWINKS_TABLE.redeemed_winks,0))
       From #CAMPAIGN_REDEEMEDWINKS_TABLE
       Where #CAMPAIGN_REDEEMEDWINKS_TABLE.campaigin_id = campaign.campaign_id
       
     )As redeemed_winks,
        
    (
	 SUM(campaign.total_winks)+ SUM(campaign.total_wink_confiscated)-- Plus Confiscated WINKs
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
	campaign.campaign_status = 'enable' -- Filter Only Enable
	AND
	CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
	AND campaign.campaign_id NOT IN (select campaign.campaign_id from campaign
	where campaign.wink_purchase_only =1 and campaign.wink_purchase_status ='on hold')
	
	/*(
	(
	CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
	AND 
	CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
     
     )
		OR 
	(campaign.wink_purchase_only =1  AND	
	 Lower(campaign.wink_purchase_status) ='activate'))*/

	GROUP By campaign_id,campaign.merchant_id,merchant.first_name,merchant.last_name,campaign_ads_banner.small_banner,
	campaign_ads_banner.large_banner,campaign_ads_banner.large_url
	Order By all_time_total_winks DESC
	
	/*SELECT Top 5 * FROM #CAMPAIGN_TABLE_1 
	WHERE
	ISNULL(#CAMPAIGN_TABLE_1.all_time_total_winks,0) - ISNULL(#CAMPAIGN_TABLE_1.redeemed_winks,0)>0
	
	*/
IF OBJECT_ID('tempdb..#CAMPAIGN_TABLE_2') IS NOT NULL DROP TABLE #CAMPAIGN_TABLE_2

CREATE TABLE #CAMPAIGN_TABLE_2
(
campaign_id int,
 merchant_id int,
 redeemed_winks int,
 all_time_total_winks int,
 small_banner varchar(200),
 large_banner varchar(200),
 large_url varchar(200),
 first_name varchar(200),
 last_name varchar(200)
)


INSERT INTO #CAMPAIGN_TABLE_2
Select #CAMPAIGN_TABLE_1.campaign_id,merchant_id,redeemed_winks,all_time_total_winks,small_banner,
large_banner,large_url,first_name,last_name from #CAMPAIGN_TABLE_1
where 
(ISNULL(#CAMPAIGN_TABLE_1.all_time_total_winks,0) - ISNULL(#CAMPAIGN_TABLE_1.redeemed_winks,0)>0)
OR  (#CAMPAIGN_TABLE_1.campaign_id IN (select campaign.campaign_id from campaign
where campaign.campaign_end_date >= CONVERT(CHAR(10),@CURRENT_DATE,111)))

-- Remove 0 WINKs except Global
Select * from (
Select merchant_id,SUM(ISNULL(redeemed_winks,0))as redeemed_winks ,SUM(all_time_total_winks) as all_time_total_winks ,first_name,last_name,small_banner,
large_banner,large_url from #CAMPAIGN_TABLE_2
where merchant_id =248 -- Global
group by merchant_id,first_name,last_name,small_banner,
large_banner,large_url,redeemed_winks,all_time_total_winks

UNION 
-- Remove 0 WINKs
Select merchant_id,SUM(ISNULL(redeemed_winks,0))as redeemed_winks ,SUM(all_time_total_winks) as all_time_total_winks ,first_name,last_name,small_banner,
large_banner,large_url from #CAMPAIGN_TABLE_2
where merchant_id !=248  -- Non Global
group by merchant_id,first_name,last_name,small_banner,
large_banner,large_url,redeemed_winks,all_time_total_winks
Having SUM(all_time_total_winks)-SUM(ISNULL(redeemed_winks,0))>0
) as aa 
order by aa.all_time_total_winks - aa.redeemed_winks desc

--ORDER BY SUM(all_time_total_winks) -SUM(redeemed_winks) desc




	
END
