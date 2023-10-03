CREATE PROCEDURE [dbo].[Get_Dashboard_Summary_Expired_eVoucher]
	
AS
BEGIN

	DECLARE @TOTAL_WINKS INT
	DECLARE @TOTAL_REDEEMED_WINKS INT
	DECLARE @TOTAL_eVOUCHER INT

	DECLARE @TOTAL_Expired_eVOUCHER INT

	DECLARE @TOTAL_REDEEMED_EVOUCHER INT
	DECLARE @CURRENT_DATE DATETIME
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUT
	DECLARE @confiscated_winks int
	DECLARE @Injected_WINKs INT
	DECLARE @TOTAL_Scans INT

	SET @Injected_WINKs = (SELECT SUM(campaign.total_winks)
	FROM campaign WHERE 
	campaign.campaign_status ='enable' AND campaign.merchant_id =248 AND
	((CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111))
	 OR (campaign.wink_purchase_only =1 and campaign.wink_purchase_status ='activate')))
	
	SET @TOTAL_Scans = (select count(*) from customer_earned_points)
	
	SET @TOTAL_WINKS = (SELECT SUM(campaign.total_winks)+ SUM(campaign.total_wink_confiscated) 
	FROM campaign WHERE 
	campaign.campaign_status ='enable' AND
	(CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111))
	 OR (campaign.wink_purchase_only =1 and campaign.wink_purchase_status ='activate'))
	 
	SET @confiscated_winks = ( SELECT SUM(campaign.total_wink_confiscated) 
	FROM campaign WHERE 
	campaign.campaign_status ='enable' AND
	(CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111))
	 OR (campaign.wink_purchase_only =1 and campaign.wink_purchase_status ='activate')
	 )
	
	
	SET @TOTAL_REDEEMED_WINKS = (SELECT ISNULL(SUM(customer_earned_winks.total_winks),0) FROM customer_earned_winks where customer_id !=15)
	
	SET @TOTAL_eVOUCHER = (SELECT COUNT(*) FROM customer_earned_evouchers where customer_id !=15)
	
	SET @TOTAL_REDEEMED_EVOUCHER = (SELECT COUNT(*) FROM customer_earned_evouchers WHERE customer_earned_evouchers.used_status =1 and customer_id !=15)
	
	SET @TOTAL_Expired_eVOUCHER =(SELECT COUNT(*) FROM customer_earned_evouchers where CAST (customer_earned_evouchers.expired_date as DATE) < Cast (@current_date as date) AND customer_earned_evouchers.used_status = 0 and customer_id !=15) 
	


	SELECT @TOTAL_WINKS AS TOTAL_WINKS , @TOTAL_REDEEMED_WINKS AS TOTAL_REDEEMED_WINKS, 
	@TOTAL_eVOUCHER AS TOTAL_eVOUCHER , @TOTAL_REDEEMED_EVOUCHER AS TOTAL_REDEEMED_eVOUCHER, @TOTAL_Expired_eVOUCHER AS TOTAL_Expired_eVOUCHER,
	@confiscated_winks as confiscated_winks,
	@TOTAL_Scans as total_scans,@Injected_WINKs as injected_winks
	RETURN 
	
	
	
	
	
END
