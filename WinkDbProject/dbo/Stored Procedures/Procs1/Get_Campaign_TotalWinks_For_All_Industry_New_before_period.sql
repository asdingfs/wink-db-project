CREATE PROCEDURE [dbo].[Get_Campaign_TotalWinks_For_All_Industry_New_before_period] 
AS
BEGIN
DECLARE @CURRENT_DATE DATETIME
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT

-- Normal Campaign ------------------------------------	
IF OBJECT_ID('tempdb..#CAMPAIGN_INSUSTRY_TABLE_1') IS NOT NULL DROP TABLE #CAMPAIGN_INSUSTRY_TABLE_1

CREATE TABLE #CAMPAIGN_INSUSTRY_TABLE_1
(
 industry_id int,
 industry_name varchar(100),
 campaign_id int,
 all_time_total_winks int,
 redeemed_winks int
)



INSERT INTO #CAMPAIGN_INSUSTRY_TABLE_1 (industry_id,industry_name,campaign_id,all_time_total_winks,
redeemed_winks)

SELECT industry.industry_id,industry.industry_name,campaign.campaign_id,
	--(SUM(campaign.total_winks) - (SUM(ISNULL(customer_earned_winks.total_winks,0))))As balance_total_winks
	
	 SUM(campaign.total_winks) As all_time_total_winks,
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
	WHERE
	campaign.campaign_status ='enable' AND -- Filter Only Enable
	campaign.wink_purchase_only =0 AND -- Filter NOT PO
	(
	CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
		AND 
	CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
     )
		/*OR 
	(campaign.wink_purchase_only =1  AND	
	 Lower(campaign.wink_purchase_status) ='activate')*/
	
	GROUP By industry.industry_id,industry.industry_name,campaign.campaign_id
	
-- WINK Purchase ONLY ------------------------------------	
IF OBJECT_ID('tempdb..#CAMPAIGN_INSUSTRY_TABLE_2') IS NOT NULL DROP TABLE #CAMPAIGN_INSUSTRY_TABLE_2

CREATE TABLE #CAMPAIGN_INSUSTRY_TABLE_2
(
 industry_id int,
 industry_name varchar(100),
 campaign_id int,
 all_time_total_winks int,
 redeemed_winks int
)



INSERT INTO #CAMPAIGN_INSUSTRY_TABLE_2 (industry_id,industry_name,campaign_id,all_time_total_winks,
redeemed_winks)

SELECT industry.industry_id,industry.industry_name,campaign.campaign_id,
	--(SUM(campaign.total_winks) - (SUM(ISNULL(customer_earned_winks.total_winks,0))))As balance_total_winks
	
	 SUM(campaign.total_winks) As all_time_total_winks,
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
	WHERE
	campaign.campaign_status ='enable' AND -- Filter Only Enable
	(campaign.wink_purchase_only =1  AND	
	 Lower(campaign.wink_purchase_status) ='activate')
	
	GROUP By industry.industry_id,industry.industry_name,campaign.campaign_id
	
-- Remove WINK Purchase ONLY  0 ------------------------------------	
IF OBJECT_ID('tempdb..#CAMPAIGN_INSUSTRY_TABLE_3') IS NOT NULL DROP TABLE #CAMPAIGN_INSUSTRY_TABLE_3

CREATE TABLE #CAMPAIGN_INSUSTRY_TABLE_3
(
 industry_id int,
 industry_name varchar(100),
 campaign_id int,
 all_time_total_winks int,
 redeemed_winks int
)



INSERT INTO #CAMPAIGN_INSUSTRY_TABLE_3 (industry_id,industry_name,campaign_id,all_time_total_winks,
redeemed_winks)

SELECT #CAMPAIGN_INSUSTRY_TABLE_2.industry_id,#CAMPAIGN_INSUSTRY_TABLE_2.industry_name,#CAMPAIGN_INSUSTRY_TABLE_2.campaign_id,
	--(SUM(campaign.total_winks) - (SUM(ISNULL(customer_earned_winks.total_winks,0))))As balance_total_winks
	
      #CAMPAIGN_INSUSTRY_TABLE_2.all_time_total_winks,
      #CAMPAIGN_INSUSTRY_TABLE_2.redeemed_winks
    
		
	From #CAMPAIGN_INSUSTRY_TABLE_2
	
	WHERE
	ISNULL(#CAMPAIGN_INSUSTRY_TABLE_2.all_time_total_winks,0) - ISNULL(#CAMPAIGN_INSUSTRY_TABLE_2.redeemed_winks,0)>0
	
--  JOIN TWO Tables 
IF OBJECT_ID('tempdb..#CAMPAIGN_INSUSTRY_TABLE_4') IS NOT NULL DROP TABLE #CAMPAIGN_INSUSTRY_TABLE_4

CREATE TABLE #CAMPAIGN_INSUSTRY_TABLE_4
(
 industry_id int,
 industry_name varchar(100),
 campaign_id int,
 all_time_total_winks int,
 redeemed_winks int
)	
INSERT INTO #CAMPAIGN_INSUSTRY_TABLE_4 (industry_id,industry_name,campaign_id,all_time_total_winks,
redeemed_winks)	
SELECT #CAMPAIGN_INSUSTRY_TABLE_1.industry_id,#CAMPAIGN_INSUSTRY_TABLE_1.industry_name,#CAMPAIGN_INSUSTRY_TABLE_1.campaign_id,
	--(SUM(campaign.total_winks) - (SUM(ISNULL(customer_earned_winks.total_winks,0))))As balance_total_winks
	
      #CAMPAIGN_INSUSTRY_TABLE_1.all_time_total_winks,
      #CAMPAIGN_INSUSTRY_TABLE_1.redeemed_winks
    
		
	From #CAMPAIGN_INSUSTRY_TABLE_1
UNION

SELECT #CAMPAIGN_INSUSTRY_TABLE_3.industry_id,#CAMPAIGN_INSUSTRY_TABLE_3.industry_name,#CAMPAIGN_INSUSTRY_TABLE_3.campaign_id,
	--(SUM(campaign.total_winks) - (SUM(ISNULL(customer_earned_winks.total_winks,0))))As balance_total_winks
	
      #CAMPAIGN_INSUSTRY_TABLE_3.all_time_total_winks,
      #CAMPAIGN_INSUSTRY_TABLE_3.redeemed_winks
    
		
	From #CAMPAIGN_INSUSTRY_TABLE_3
 
	
SELECT industry_id, industry_name,SUM(all_time_total_winks) AS all_time_total_winks ,
SUM(ISNULL(redeemed_winks,0)) AS redeemed_winks from #CAMPAIGN_INSUSTRY_TABLE_4
GROUP By industry_id,industry_name

	
END
