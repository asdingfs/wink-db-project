CREATE PROCEDURE [dbo].[Get_CampaignMerchants_By_TopSponsorWinks_New2]
AS
BEGIN

	--DECLARE @CURRENT_DATE DATETIME
	--EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT

	--IF(cast(@CURRENT_DATE as time) not between '07:00:00.000' and '08:00:00.000')
	--BEGIN
	--	IF OBJECT_ID('tempdb..#CAMPAIGN_REDEEMEDWINKS_TABLE') IS NOT NULL DROP TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE
	--	--1. Redeem WINKs 
	--	CREATE TABLE #CAMPAIGN_REDEEMEDWINKS_TABLE
	--	(
	--	 merchant_id int,
	--	 redeemed_winks int,
	--	 campaigin_id int
	--	)
	--	INSERT INTO #CAMPAIGN_REDEEMEDWINKS_TABLE (merchant_id,campaigin_id,redeemed_winks)
	--	SELECT customer_earned_winks.merchant_id,customer_earned_winks.campaign_id,
	--	customer_earned_winks.total_winks
	--	From customer_earned_winks
	--		JOIN campaign
	--		ON campaign.campaign_id  = customer_earned_winks.campaign_id
	--		WHERE
	--		campaign.campaign_status = 'enable' -- Filter Only Enable
	--		AND
	--		CAST (@CURRENT_DATE as datetime)>= DATEADD(day, DATEDIFF(day, 0, CAMPAIGN_START_DATE), '08:00:00')
	--		AND campaign.campaign_id NOT IN (select campaign.campaign_id from campaign
	--		where campaign.wink_purchase_only =1 and campaign.wink_purchase_status ='on hold')
	--	--2. Avaiable WINKs 

	--	IF OBJECT_ID('tempdb..#CAMPAIGN_TABLE_1') IS NOT NULL DROP TABLE #CAMPAIGN_TABLE_1

	--	CREATE TABLE #CAMPAIGN_TABLE_1
	--	(
	--	 campaign_id int,
	--	 merchant_id int,
	--	 redeemed_winks int,
	--	 all_time_total_winks int,
	--	 small_banner varchar(200),
	--	 large_banner varchar(200),
	--	 large_url varchar(200),
	--	 banner_id int,
	--	 first_name varchar(200),
	--	 last_name varchar(200)
	--	)
	--	INSERT INTO #CAMPAIGN_TABLE_1
	--	SELECT campaign.campaign_id,campaign.merchant_id,
	--		 ( Select SUM(ISNULL(#CAMPAIGN_REDEEMEDWINKS_TABLE.redeemed_winks,0))
	--		   From #CAMPAIGN_REDEEMEDWINKS_TABLE
	--		   Where #CAMPAIGN_REDEEMEDWINKS_TABLE.campaigin_id = campaign.campaign_id
       
	--		 )As redeemed_winks,
        
	--		(
	--		 SUM(campaign.total_winks)+ SUM(campaign.total_wink_confiscated)-- Plus Confiscated WINKs
	--		 ) As all_time_total_winks, 
	 
	--		campaign_small_image.small_image_name as small_banner,campaign_large_image.large_image_name as large_banner,campaign_large_image.large_image_url as large_url,
	--		campaign_large_image.id as banner_id,
	--		merchant.first_name,merchant.last_name
	
	--		From campaign
	--		JOIN merchant
	--		ON campaign.merchant_id  = merchant.merchant_id
	--		LEFT JOIN campaign_small_image 
	--		ON 
	--		campaign_small_image.campaign_id=campaign.campaign_id
	--		And campaign_small_image.small_image_status =1
	
	--		LEFT JOIN campaign_large_image
	--		ON 
	--		campaign_large_image.campaign_id=campaign.campaign_id
	--		and campaign_large_image.large_image_status =1
	--		WHERE
	--		campaign.campaign_status = 'enable' -- Filter Only Enable
	--		AND
	--		CAST (@CURRENT_DATE as datetime)>= DATEADD(day, DATEDIFF(day, 0, CAMPAIGN_START_DATE), '08:00:00')
	--		AND campaign.campaign_id NOT IN (select campaign.campaign_id from campaign
	--		where campaign.wink_purchase_only =1 and campaign.wink_purchase_status ='on hold')
	
	--		GROUP By campaign.campaign_id,campaign.merchant_id,merchant.first_name,merchant.last_name,
	--		campaign_small_image.small_image_name ,campaign_large_image.large_image_name ,campaign_large_image.large_image_url,campaign_large_image.id 
	--		Order By all_time_total_winks DESC
	
	--	IF OBJECT_ID('tempdb..#CAMPAIGN_TABLE_2') IS NOT NULL DROP TABLE #CAMPAIGN_TABLE_2

	--	CREATE TABLE #CAMPAIGN_TABLE_2
	--	(
	--	campaign_id int,
	--	 merchant_id int,
	--	 redeemed_winks int,
	--	 all_time_total_winks int,
	--	 small_banner varchar(200),
	--	 large_banner varchar(200),
	--	 large_url varchar(200),
	--	  banner_id int,
	--	 first_name varchar(200),
	--	 last_name varchar(200)
	--	)


	--	INSERT INTO #CAMPAIGN_TABLE_2
	--	Select #CAMPAIGN_TABLE_1.campaign_id,merchant_id,redeemed_winks,all_time_total_winks,small_banner,
	--	large_banner,large_url,banner_id ,first_name,last_name from #CAMPAIGN_TABLE_1
	--	where 
	--	(ISNULL(#CAMPAIGN_TABLE_1.all_time_total_winks,0) - ISNULL(#CAMPAIGN_TABLE_1.redeemed_winks,0)>0)
	--	OR  (#CAMPAIGN_TABLE_1.campaign_id IN (select campaign.campaign_id from campaign
	--	where campaign.campaign_end_date >= CONVERT(CHAR(10),@CURRENT_DATE,111)))

	--	-- Remove 0 WINKs except Global
	--	Select * from (
	--	Select merchant_id,SUM(ISNULL(redeemed_winks,0))as redeemed_winks ,SUM(all_time_total_winks) as all_time_total_winks ,first_name,last_name,small_banner,
	--	large_banner,large_url,banner_id from #CAMPAIGN_TABLE_2
	--	where merchant_id =64 -- Global  248 in prod, 64 in beta
	--	group by merchant_id,first_name,last_name,small_banner,
	--	large_banner,large_url,redeemed_winks,all_time_total_winks,banner_id

	--	UNION 
	--	-- Remove 0 WINKs
	--	Select merchant_id,SUM(ISNULL(redeemed_winks,0))as redeemed_winks ,SUM(all_time_total_winks) as all_time_total_winks ,first_name,last_name,small_banner,
	--	large_banner,large_url,banner_id from #CAMPAIGN_TABLE_2
	--	where merchant_id !=64  -- Non Global  248 in prod, 64 in beta
	--	group by merchant_id,first_name,last_name,small_banner,
	--	large_banner,large_url,redeemed_winks,all_time_total_winks,banner_id
	--	Having SUM(all_time_total_winks)-SUM(ISNULL(redeemed_winks,0))>0
	--	) as aa 
	--	order by aa.all_time_total_winks - aa.redeemed_winks desc
	--END
	--ELSE
	--BEGIN
		SELECT 0 as campaign_id, 0 as merchant_id, 0 as redeemed_winks,0 as all_time_total_winks,
		'' as small_banner, '' as large_banner, '' as large_url, 0 as banner_id, '' as first_name, '' as last_name;
	--END
END
