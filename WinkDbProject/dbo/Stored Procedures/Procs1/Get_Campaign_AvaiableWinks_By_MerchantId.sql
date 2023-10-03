CREATE PROCEDURE [dbo].[Get_Campaign_AvaiableWinks_By_MerchantId]
(@merchantId int)
AS
BEGIN
	IF OBJECT_ID('tempdb..#merchantcampaigntemp') IS NOT NULL 
	BEGIN
	PRINT ('NOT NULL')
	DROP TABLE #merchantcampaigntemp
	END
	ELSE
	BEGIN
	CREATE Table #merchantcampaigntemp
	( campaign_id int,
	  total_winks int,
	  redeemed_winks int)
    END
	
	DECLARE @CURRENT_DATETIME DATETIME

	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUT	
	
	INSERT INTO #merchantcampaigntemp (#merchantcampaigntemp.campaign_id,#merchantcampaigntemp.total_winks,#merchantcampaigntemp.redeemed_winks)
	select campaign.campaign_id ,(ISNULL(campaign.total_winks,0)+ ISNULL( campaign.total_wink_confiscated,0)) 
	 AS total_winks ,
    (
    ISNULL(
	(Select Sum(customer_earned_winks.total_winks) from customer_earned_winks where customer_earned_winks.campaign_id =campaign.campaign_id
	group by customer_earned_winks.campaign_id
	
	) ,0) )AS redeemed_winks
	
	
	
	FROM campaign
	WHERE 
	campaign.merchant_id = @merchantId
	AND
	campaign.campaign_status = 'enable'
	AND
	CONVERT(CHAR(10),@CURRENT_DATETIME,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
	AND
	(
	(campaign.wink_purchase_only =1  
	 and Lower(campaign.wink_purchase_status) ='activate')
	 OR campaign.wink_purchase_status=0
	 )
	 
	/*(
	(
	CONVERT(CHAR(10),@CURRENT_DATETIME,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
		AND 
	CONVERT(CHAR(10),@CURRENT_DATETIME,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
		AND campaign.wink_purchase_only=0
     )
		OR 
	(campaign.wink_purchase_only =1  
	 and Lower(campaign.wink_purchase_status) ='activate'
	
	)) */
		
	ORDER BY campaign.campaign_id ASC
	
	
	SELECT * FROM #merchantcampaigntemp 
	WHERE (#merchantcampaigntemp.total_winks - #merchantcampaigntemp.redeemed_winks )>0
	
	DROP Table #merchantcampaigntemp
	
END
