CREATE PROCEDURE [dbo].[Get_Dashboard_Summary_Backup]
	
AS
BEGIN
	DECLARE @TOTAL_WINKS INT
	DECLARE @TOTAL_REDEEMED_WINKS INT
	DECLARE @TOTAL_eVOUCHER INT
	DECLARE @TOTAL_REDEEMED_EVOUCHER INT
	DECLARE @CURRENT_DATE DATETIME
	DECLARE @Total_Wink_Confiscated INT
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUT
	
	
	/*SET @TOTAL_WINKS = (SELECT SUM(campaign.total_winks)+SUM(campaign.total_wink_confiscated) FROM campaign WHERE 
	campaign.campaign_status ='enable' AND
	(CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111))
	 OR (campaign.wink_purchase_only =1 and campaign.wink_purchase_status ='activate'))*/
	
	SELECT @TOTAL_WINKS = (SUM(campaign.total_winks)+ SUM(campaign.total_wink_confiscated)),
	@Total_Wink_Confiscated = SUM(campaign.total_wink_confiscated) 
	FROM campaign WHERE 
	campaign.campaign_status ='enable' AND
	((CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111))
	AND campaign.campaign_id NOT IN (select campaign.campaign_id where campaign.wink_purchase_only =1 and campaign.wink_purchase_status ='on hold'))
	
	SET @TOTAL_REDEEMED_WINKS = (SELECT ISNULL(SUM(customer_earned_winks.total_winks),0) FROM customer_earned_winks)
	
	SET @TOTAL_eVOUCHER = (SELECT COUNT(*) FROM customer_earned_evouchers)
	
	SET @TOTAL_REDEEMED_EVOUCHER = (SELECT COUNT(*) FROM customer_earned_evouchers WHERE customer_earned_evouchers.used_status =1)
	
	SELECT @TOTAL_WINKS AS TOTAL_WINKS , @TOTAL_REDEEMED_WINKS AS TOTAL_REDEEMED_WINKS,
	@TOTAL_eVOUCHER AS TOTAL_eVOUCHER , @TOTAL_REDEEMED_EVOUCHER AS TOTAL_REDEEMED_eVOUCHER
	RETURN 
	
	
	
	
	
END

