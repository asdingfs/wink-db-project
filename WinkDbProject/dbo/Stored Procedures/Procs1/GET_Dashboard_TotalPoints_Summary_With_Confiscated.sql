

CREATE PROCEDURE [dbo].[GET_Dashboard_TotalPoints_Summary_With_Confiscated] 
AS
BEGIN
	DECLARE @points_per_wink int
	DECLARE @TOTAL_WINKS INT
	DECLARE @TOTAL_REDEEMED_WINKS INT
	DECLARE @CURRENT_DATE DATETIME
	DECLARE @Total_Wink_Confiscated INT
	DECLARE @Total_Point_Confiscated INT

	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUT
	
	SET @TOTAL_WINKS = (SELECT SUM(campaign.total_winks)+SUM(campaign.total_wink_confiscated) FROM campaign WHERE 
	campaign.campaign_status ='enable' 
	AND
	(CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111))
	 OR (campaign.wink_purchase_only =1 and campaign.wink_purchase_status ='activate'))
	
	SET @Total_Wink_Confiscated = (SELECT SUM(campaign.total_wink_confiscated) FROM campaign WHERE 
	campaign.campaign_status ='enable' 
	AND
	(CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111))
	 OR (campaign.wink_purchase_only =1 and campaign.wink_purchase_status ='activate'))

	SET @Total_Point_Confiscated = (select sum(confiscated_points) FROM points_confiscated_detail)


	SET @TOTAL_REDEEMED_WINKS = (SELECT ISNULL(SUM(customer_earned_winks.total_winks),0) FROM customer_earned_winks)
	
	SET @points_per_wink = (select rate_conversion.rate_value from rate_conversion where rate_code='points_per_wink')
	select CONVERT(int,SUM(customer_balance.total_points-(customer_balance.used_points + customer_balance.confiscated_points))) AS points_balance,
	CONVERT(int,SUM(customer_balance.total_points-(customer_balance.used_points + customer_balance.confiscated_points))/@points_per_wink) as equivalent_wink,
	@TOTAL_WINKS-@TOTAL_REDEEMED_WINKS As avaiable_wink
	,@Total_Wink_Confiscated As total_confiscated_winks
	,@Total_Point_Confiscated As total_confiscated_points

	 from customer_balance

END

