CREATE  PROCEDURE [dbo].[Get_Top5_Advertisers_ByWINKsContributed]
AS
BEGIN
-- Check null or empty
	
IF OBJECT_ID('tempdb..#tmpmerchant') IS NOT NULL 
Drop table #tmpmerchant
CREATE TABLE #tmpmerchant 
(
	campaign_id int,
	merchant_id int,
	
	imobshop_id int ,
	first_name varchar(100),
	last_name varchar(100),
	mas_code varchar(50),
	email varchar(150),
	total_winks int,
	redeemed_winks int)
	
	BEGIN
		INSERT INTO #tmpmerchant (campaign_id,merchant_id,
	imobshop_id,first_name,last_name,mas_code,email,total_winks,redeemed_winks)


	SELECT campaign.campaign_id,merchant.merchant_id,merchant.imobshop_merchant_id,merchant.first_name,merchant.last_name,merchant.mas_code,
	merchant.email,campaign.total_winks,
    
	 (SELECT SUM(ISNULL(customer_earned_winks.total_winks,0)) from customer_earned_winks 
	 WHERE customer_earned_winks.campaign_id = campaign.campaign_id
	 ) AS Redeemed_Winks
	 
	 FROM merchant,campaign
	 WHERE merchant.merchant_id = campaign.merchant_id
	  
	
	END 
	
	SELECT TOP 5 (#tmpmerchant.first_name + ' '+  #tmpmerchant.last_name)  AS advertiser_name,#tmpmerchant.mas_code,SUM(ISNULL(#tmpmerchant.total_winks,0)) AS total_winks,
	SUM(ISNULL(#tmpmerchant.Redeemed_Winks,0)) AS Redeemed_Winks
	FROM #tmpmerchant
	GROUP BY #tmpmerchant.merchant_id,#tmpmerchant.imobshop_id,#tmpmerchant.first_name,
	#tmpmerchant.last_name,#tmpmerchant.email,#tmpmerchant.mas_code
	ORDER BY total_winks DESC
	
	DROP TABLE #tmpmerchant
	
END
