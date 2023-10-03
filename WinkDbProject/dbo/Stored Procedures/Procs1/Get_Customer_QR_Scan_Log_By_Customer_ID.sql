CREATE PROCEDURE [dbo].[Get_Customer_QR_Scan_Log_By_Customer_ID]
	(@customer_id int)
AS
BEGIN
Select customer_earned_points.qr_code,customer_earned_points.points,
customer_earned_points.last_scanned_time,customer.first_name as c_first_name,
customer.last_name as c_last_name,
customer_earned_points.campaign_id,campaign.campaign_name,campaign.merchant_id,
merchant.first_name as m_first_name , merchant.last_name as m_last_name,customer_earned_points.GPS_location as scanned_location
from customer_earned_points , merchant,campaign,customer
Where customer_earned_points.customer_id= @customer_id
AND customer_earned_points.campaign_id = campaign.campaign_id
AND campaign.merchant_id = merchant.merchant_id
AND customer_earned_points.customer_id = customer.customer_id
--AND customer_earned_points.campaign_id = campaign.campaign_id
--AND customer_earned_points.customer_id= @customer_id
order by customer_earned_points.earned_points_id desc

END
