CREATE  PROCEDURE [dbo].[Get_Top5_Campaigns_ByWINKRedemption]

As
BEGIN
	 SELECT Top 5 T1.campaign_id,T2.campaign_name,SUM(T1.TOTAL_WINKS)AS total_winks_redemption FROM customer_earned_winks AS T1 LEFT JOIN CAMPAIGN AS T2 ON T1.campaign_id = T2.campaign_id 
	 GROUP BY T1.campaign_id,T2.campaign_name ORDER BY total_winks_redemption DESC
END
