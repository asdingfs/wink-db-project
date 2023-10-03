CREATE PROCEDURE [dbo].[Get_Campaign_TotalWinks_For_All_Industry_New] 
AS
BEGIN
	--DECLARE @CURRENT_DATE DATETIME
	--EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT

	--IF(
	--	(cast(@CURRENT_DATE as time) not between '07:00:00.000' and '08:30:00.000')
	--	AND 
	--	(cast(@CURRENT_DATE as time) not between '17:30:00.000' and '19:00:00.000')	
	--)
	--BEGIN
	--	--1. Normal Campaign Filter With Start Date ------------------------------------	
	--	IF OBJECT_ID('tempdb..#CAMPAIGN_INSUSTRY_TABLE_1') IS NOT NULL DROP TABLE #CAMPAIGN_INSUSTRY_TABLE_1

	--	CREATE TABLE #CAMPAIGN_INSUSTRY_TABLE_1
	--	(
	--	 industry_id int,
	--	 industry_name varchar(100),
	--	 campaign_id int,
	--	 all_time_total_winks int,
	--	 redeemed_winks int
	--	)

	--	INSERT INTO #CAMPAIGN_INSUSTRY_TABLE_1 (industry_id,industry_name,campaign_id,all_time_total_winks,
	--		redeemed_winks)

	--		SELECT industry.industry_id,industry.industry_name,campaign.campaign_id,
	--		  SUM(campaign.total_winks) + SUM(campaign.total_wink_confiscated) As all_time_total_winks,
	--		 ( Select SUM(ISNULL(customer_earned_winks.total_winks,0))
	--		   From customer_earned_winks 
	--		   Where customer_earned_winks.merchant_id In (Select merchant_industry.merchant_id
	--		   from merchant_industry where merchant_industry.industry_id = industry.industry_id)
	       
	--		   AND customer_earned_winks.campaign_id =campaign.campaign_id
	--		 )As redeemed_winks
	     
	    
			
	--		From merchant_industry
	--		JOIN industry
	--		ON merchant_industry.industry_id = industry.industry_id
	--		JOIN merchant
	--		ON merchant_industry.merchant_id  = merchant.merchant_id
	--		JOIN campaign
	--		ON
	--		campaign.merchant_id = merchant_industry.merchant_id
	--		WHERE
	--		campaign.campaign_status ='enable' AND -- Filter Only Enable
	--		(
	--		CAST (@CURRENT_DATE as datetime)>= DATEADD(day, DATEDIFF(day, 0, CAMPAIGN_START_DATE), '08:00:00')
	--		AND (
	--			(campaign.wink_purchase_only = 1 and campaign.wink_purchase_status ='activate')
	--			OR (campaign.wink_purchase_only =0 )
	--			)
	
	--		 )
	--		GROUP By industry.industry_id,industry.industry_name,campaign.campaign_id
		
	--	--3. Remove WINK 0 For expired and Keep Non Expired
	--	IF OBJECT_ID('tempdb..#CAMPAIGN_INSUSTRY_TABLE_3') IS NOT NULL DROP TABLE #CAMPAIGN_INSUSTRY_TABLE_3

	--	CREATE TABLE #CAMPAIGN_INSUSTRY_TABLE_3
	--		(
	--		 industry_id int,
	--		 industry_name varchar(100),
	--		 campaign_id int,
	--		 all_time_total_winks int,
	--		 redeemed_winks int
	--		)
	--	INSERT INTO #CAMPAIGN_INSUSTRY_TABLE_3 (industry_id,industry_name,campaign_id,all_time_total_winks,
	--		redeemed_winks)

	--		SELECT #CAMPAIGN_INSUSTRY_TABLE_1.industry_id,#CAMPAIGN_INSUSTRY_TABLE_1.industry_name,#CAMPAIGN_INSUSTRY_TABLE_1.campaign_id,
	--			  #CAMPAIGN_INSUSTRY_TABLE_1.all_time_total_winks,
	--			  #CAMPAIGN_INSUSTRY_TABLE_1.redeemed_winks
		
				
	--		From #CAMPAIGN_INSUSTRY_TABLE_1
			
	--		WHERE
	--		ISNULL(#CAMPAIGN_INSUSTRY_TABLE_1.all_time_total_winks,0) - ISNULL(#CAMPAIGN_INSUSTRY_TABLE_1.redeemed_winks,0)>0
		
	--		OR (#CAMPAIGN_INSUSTRY_TABLE_1.campaign_id IN (Select campaign.campaign_id from campaign
	--		 where CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
	--		 ))

	--	IF OBJECT_ID('tempdb..#CAMPAIGN_INSUSTRY_TABLE_4') IS NOT NULL DROP TABLE #CAMPAIGN_INSUSTRY_TABLE_4

	--	CREATE TABLE #CAMPAIGN_INSUSTRY_TABLE_4
	--		(
	--		 id int identity(1,1) Primary Key,
	--		 industry_id int,
	--		 industry_name varchar(100),
	--		 campaign_id int,
	--		 all_time_total_winks int,
	--		 redeemed_winks int
	--		)
		
	--	-- Add Global
	--	insert into #CAMPAIGN_INSUSTRY_TABLE_4
	--	(industry_id,industry_name,all_time_total_winks,redeemed_winks)
	--	SELECT industry_id, industry_name,SUM(all_time_total_winks) AS all_time_total_winks ,
	--	SUM(ISNULL(redeemed_winks,0)) AS redeemed_winks from #CAMPAIGN_INSUSTRY_TABLE_3
	--	where industry_id =12 -- Global
	--	GROUP By industry_id,industry_name
	--	ORDER BY SUM(all_time_total_winks-redeemed_winks) asc
	--	insert into #CAMPAIGN_INSUSTRY_TABLE_4
	--	(industry_id,industry_name,all_time_total_winks,redeemed_winks)
	--	SELECT industry_id, industry_name,SUM(all_time_total_winks) AS all_time_total_winks ,
	--	SUM(ISNULL(redeemed_winks,0)) AS redeemed_winks from #CAMPAIGN_INSUSTRY_TABLE_3
	--	where industry_id !=12 -- Remove 0 WINKs
	--	GROUP By industry_id,industry_name
	--	Having (SUM(all_time_total_winks) - SUM(ISNULL(redeemed_winks,0))) >0
	--	ORDER BY (SUM(all_time_total_winks) - SUM(ISNULL(redeemed_winks,0))) asc
		
	--	select * from #CAMPAIGN_INSUSTRY_TABLE_4 
	--	order by #CAMPAIGN_INSUSTRY_TABLE_4.id desc
	--END
	--ELSE
	--BEGIN
		SELECT 0 as id, 0 as industry_id, '' as industry_name, 0 as campaign_id, 0 all_time_total_winks, 0 as redeemed_winks;
	--END
END