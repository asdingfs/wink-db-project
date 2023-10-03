CREATE PROCEDURE [dbo].[GetPointsByQrScan] 
	(@customer_id int,
	 @campaign_booking_id int
	 )
AS
BEGIN
Declare @valid_campaign int
Declare @scan_interval int
Declare @last_scanned_time DateTime
Declare @time_dif DateTime
Declare @points Decimal(10,2)
Declare @qr_code varchar(50)
Declare @current_customer_earned_points_id int 

SET @valid_campaign= (Select campaign_booking.campaign_booking_id from campaign_booking Where GETDATE()>=campaign_booking.start_date 
and GETDATE()<=campaign_booking.end_date);
If(@valid_campaign!='')
Begin
   
SET @last_scanned_time = (Select MAX(last_scanned_time) As startDate from customer_earned_points);
SET @scan_interval = (Select campaign_booking.scan_interval From campaign_booking Where campaign_booking.campaign_booking_id =campaign_booking_id);
SET @time_dif = DATEDIFF(Minute,@last_scanned_time,GETDATE());
If(@time_dif<@scan_interval)
Begin
SET @points = (Select campaign_booking.scan_value From campaign_booking);
INSERT INTO customer_earned_points (customer_id,campaign_booking_id,points,last_scanned_time,qr_code)
Values (@customer_id,@campaign_booking_id,@points,GETDATE(),@qr_code);
 SET @current_customer_earned_points_id  =  (SELECT SCOPE_IDENTITY());
if(@@ROWCOUNT>0)
Begin
Select campaign_booking.scan_value,customer_earned_points.last_scanned_time,campaign_ads_banner.small_banner
FROM campaign_booking,customer_earned_points,campaign_ads_banner
WHERE campaign_booking.campaign_booking_id = customer_earned_points.campaign_booking_id
AND campaign_booking.merchant_id = campaign_ads_banner.merchant_id
AND customer_earned_points.earned_points_id = @current_customer_earned_points_id;
End
End
End
END
