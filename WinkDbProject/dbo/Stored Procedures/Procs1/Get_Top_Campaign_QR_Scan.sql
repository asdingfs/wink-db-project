CREATE PROCEDURE [dbo].[Get_Top_Campaign_QR_Scan]
	
AS
BEGIN
Select Top 5 customer_earned_points.earned_points_id,customer_earned_points.points,customer_earned_points.qr_code,
customer_earned_points.last_scanned_time,customer.first_name,customer.last_name,
campaign.campaign_name from customer_earned_points , campaign,customer,asset_management_booking
where customer_earned_points.campaign_booking_id = asset_management_booking.booking_id
AND asset_management_booking.campaign_id = campaign.campaign_id
And customer_earned_points.customer_id = customer.customer_id
ORDER BY customer_earned_points.earned_points_id DESC
END
