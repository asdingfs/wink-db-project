CREATE PROCEDURE [dbo].[Get_Campaign_TotalWinks_By_IndustryId_New_test] 
(
@industry_id int

)
AS
BEGIN
-- Update on 27/03/2016 - Confiscate WINK 
-- Update on 27/03/2016 - Allow all WINK to redeem until 0
DECLARE @CURRENT_DATE DATETIME
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT
	-- 1. Get Normal Campaign By Industry
	--IF OBJECT_ID('tempdb..#CAMPAIGN_INSUSTRY_TABLE_1') IS NOT NULL DROP TABLE #CAMPAIGN_INSUSTRY_TABLE_1

	DECLARE  @CAMPAIGN_INSUSTRY_TABLE_1 TABLE
	(
	 industry_id int,
	 industry_name varchar(100),
	 campaign_id int,
	 all_time_total_winks int,
	 redeemed_winks int
	)


	INSERT INTO @CAMPAIGN_INSUSTRY_TABLE_1 (industry_id,industry_name,campaign_id,all_time_total_winks,
	redeemed_winks)

	SELECT industry.industry_id,industry.industry_name,campaign.campaign_id,
	--Plus Confiscated WINK
	 SUM(campaign.total_winks) + SUM(campaign.total_wink_confiscated) As all_time_total_winks,
     ( Select SUM(ISNULL(customer_earned_winks.total_winks,0))
       From customer_earned_winks 
       Where customer_earned_winks.merchant_id In (Select merchant_industry.merchant_id
       from merchant_industry where merchant_industry.industry_id = industry.industry_id)
       
       AND customer_earned_winks.campaign_id =campaign.campaign_id
     )As redeemed_winks
         		
	From merchant_industry
	JOIN industry
	ON merchant_industry.industry_id = industry.industry_id
	JOIN merchant
	ON merchant_industry.merchant_id  = merchant.merchant_id
	JOIN campaign
	ON
	campaign.merchant_id = merchant_industry.merchant_id
	AND
	campaign.campaign_status = 'enable' AND --Select Only Enable
	--campaign.wink_purchase_only = 0 AND --Filter Normal Campaign
	(
	--CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
	CAST (@CURRENT_DATE as datetime)>= DATEADD(day, DATEDIFF(day, 0, CAMPAIGN_START_DATE), '19:00:00')
		AND (
		    (campaign.wink_purchase_only = 1 and campaign.wink_purchase_status ='activate')
			OR (campaign.wink_purchase_only =0 )
			)
		
	/*AND 
	CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
     */
     )
	WHERE
	industry.industry_id=@industry_id 
	
	GROUP By industry.industry_id,industry.industry_name,campaign.campaign_id
	
	
	--2. REMOVE 0 WINK IF Campaign is expired -------------------------
	
			--IF OBJECT_ID('tempdb..#CAMPAIGN_INSUSTRY_TABLE_3') IS NOT NULL DROP TABLE #CAMPAIGN_INSUSTRY_TABLE_3

			DECLARE  @CAMPAIGN_INSUSTRY_TABLE_3 TABLE
			(
			industry_id int,
			industry_name varchar(100),
			campaign_id int,
			all_time_total_winks int,
			 redeemed_winks int
			)

			INSERT INTO @CAMPAIGN_INSUSTRY_TABLE_3 (industry_id,industry_name,campaign_id,all_time_total_winks,
			redeemed_winks)

			SELECT a.industry_id,a.industry_name,a.campaign_id,
		
			a.all_time_total_winks,
			a.redeemed_winks
    		
			From @CAMPAIGN_INSUSTRY_TABLE_1 as a
	
			WHERE
			ISNULL(a.all_time_total_winks,0)-ISNULL(a.redeemed_winks,0)>0
			OR (a.campaign_id IN (Select campaign.campaign_id from campaign
			 where CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
			))
			
	-- Remove 0 WINKs except Global	
	
	IF(@industry_id != 12)
	BEGIN
	SELECT industry_id, industry_name,SUM(all_time_total_winks) AS all_time_total_winks ,
	SUM(ISNULL(redeemed_winks,0)) AS redeemed_winks from @CAMPAIGN_INSUSTRY_TABLE_3
	
	GROUP By industry_id,industry_name
	Having SUM(all_time_total_winks) - SUM(ISNULL(redeemed_winks,0)) >0
	
	END
	
	Else 
	Begin
	SELECT industry_id, industry_name,SUM(all_time_total_winks) AS all_time_total_winks ,
	SUM(ISNULL(redeemed_winks,0)) AS redeemed_winks from @CAMPAIGN_INSUSTRY_TABLE_3
	GROUP By industry_id,industry_name
	END

	
END
