CREATE  PROCEDURE [dbo].[Get_Top5_Advertisers_ByWINKRedemption]

As
BEGIN
	 SELECT TOP 5 T1.merchant_id,(T2.first_name + ' '+ T2.last_name) AS merchant_name,SUM(T1.TOTAL_WINKS)AS total_winks_redemption FROM customer_earned_winks AS T1 LEFT JOIN MERCHANT AS T2 ON T1.merchant_id = T2.merchant_id 
	 GROUP BY T1.merchant_id,(T2.first_name + ' ' + T2.last_name) ORDER BY total_winks_redemption DESC
END
