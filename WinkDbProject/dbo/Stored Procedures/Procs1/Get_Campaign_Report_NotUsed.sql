CREATE PROCEDURE [dbo].[Get_Campaign_Report_NotUsed]
	(@start_date datetime,
	 @end_date datetime)
AS
BEGIN
DECLARE @cents_per_wink int

SET @cents_per_wink = (Select rate_conversion.rate_value from rate_conversion where rate_conversion.rate_code ='cents_per_wink')

SELECT  
campaign.campaign_start_date,campaign.campaign_end_date,campaign.campaign_id,campaign.campaign_name,
campaign.campaign_amount,campaign.total_winks_amount,campaign.merchant_id,campaign.campaign_status,
campaign.wink_purchase_only,campaign.wink_purchase_status,
--CAST(((campaign.total_winks_amount*100)/@cents_per_wink) AS INT)As total_winks,
campaign.agency_comm,
CAST(campaign.total_winks AS INT) As total_winks,
merchant.mas_code,merchant.first_name,merchant.last_name,campaign.agency,
campaign.sales_commission,campaign.created_at,
(Select COUNT(customer_earned_points.campaign_id) from customer_earned_points where customer_earned_points.campaign_id =campaign.campaign_id)AS total_scans,
(Select SUM(isnull(customer_earned_winks.total_winks,0)) from customer_earned_winks where campaign.campaign_id =customer_earned_winks.campaign_id
 group by customer_earned_winks.campaign_id

)As redeemed_winks
	
FROM campaign,merchant
WHERE campaign.merchant_id = merchant.merchant_id
--AND (CAST(campaign.campaign_start_date as Date) BETWEEN @start_date AND @end_date
--AND (CAST(campaign.campaign_end_date as Date) <= @end_date))
AND CAST(campaign.created_at as Date)>= @start_date 
AND CAST(campaign.created_at as DATE) <= @end_date
GROUP BY campaign.campaign_id,campaign.campaign_name,campaign.campaign_amount,campaign.total_winks_amount,
campaign.sales_commission,campaign.merchant_id,campaign.wink_purchase_only,campaign.wink_purchase_status,
campaign.total_winks,campaign.agency_comm,campaign.campaign_status,
merchant.mas_code,merchant.first_name,merchant.last_name,campaign.agency,campaign.sales_commission,
campaign.campaign_start_date,campaign.campaign_end_date,campaign.created_at
ORDER BY campaign.campaign_id DESC
--ORDER BY CAST(campaign.created_at as Date) DESC
	/*SELECT  CAST(customer_earned_points.created_at as Date) AS c_created_at,
	COUNT(customer_earned_points.campaign_id)AS total_scans,
	customer_earned_points.campaign_id,campaign.campaign_name,
	campaign.campaign_amount,campaign.total_winks_amount,campaign.merchant_id,
	merchant.mas_code,merchant.first_name,merchant.last_name,campaign.agency,
	campaign.sales_commission FROM customer_earned_points,campaign,merchant
WHERE customer_earned_points.campaign_id = campaign.campaign_id
AND campaign.merchant_id = merchant.merchant_id
AND CAST(customer_earned_points.created_at as Date) BETWEEN @start_date AND @end_date
--AND CAST(customer_earned_points.created_at as Date)>= @start_date 
--AND CAST(customer_earned_points.created_at as DATE) <= @end_date
GROUP BY customer_earned_points.campaign_id,campaign.campaign_id,campaign.campaign_name,campaign.campaign_amount,campaign.total_winks_amount,
campaign.sales_commission,CAST(customer_earned_points.created_at as Date),campaign.merchant_id,
merchant.mas_code,merchant.first_name,merchant.last_name,campaign.agency,campaign.sales_commission
ORDER BY CAST(customer_earned_points.created_at as Date) DESC
*/
END
--select * from campaign
