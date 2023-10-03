CREATE PROCEDURE [dbo].[GetAsmBookingByBookingId]
	(@bookingId int)
AS
BEGIN
 DECLARE @stationCode varchar(150)
 DECLARE @station_id int
 Select @stationCode=asset_management_booking.station_code ,@station_id =station_id from 
 asset_management_booking where asset_management_booking.booking_id=@bookingId
 
 IF (@stationCode IS NOT NULL AND @stationCode !='' AND @station_id != 0 AND @stationCode!='No')
 BEGIN 
 
 SELECT asset_management_booking.booking_id,
 asset_management_booking.asset_type_management_id,
 asset_management_booking.qr_code_value,
 asset_management_booking.scan_value,
 asset_management_booking.scan_interval,
 asset_management_booking.asset_type_code,
 asset_management_booking.asset_type_name,
 asset_management_booking.[start_date],
 asset_management_booking.end_date,
 asset_management_booking.updated_at,
 asset_management_booking.created_at,
 asset_management_booking.image_id,
 asset_management_booking.image_name,
 asset_management_booking.image_url,
 
 station.station_name,
 campaign.campaign_name,
 campaign.campaign_id,
 merchant.first_name,
 merchant.last_name,
 asset_type_management.special_campaign
  FROM asset_management_booking,
 campaign,merchant,station,asset_type_management
 Where asset_management_booking.booking_id= @bookingId AND
       asset_management_booking.station_code= station.station_code
       AND 
 asset_management_booking.campaign_id = campaign.campaign_id
 AND campaign.merchant_id = merchant.merchant_id 
 and asset_management_booking.asset_type_management_id = asset_type_management.asset_type_management_id
 
 
 END
 ELSE
 BEGIN
 
 SELECT asset_management_booking.booking_id,
 asset_management_booking.asset_type_management_id,
 asset_management_booking.qr_code_value,
 asset_management_booking.scan_value,
 asset_management_booking.scan_interval,
 asset_management_booking.asset_type_code,
 asset_management_booking.asset_type_name,
 asset_management_booking.[start_date],
 asset_management_booking.end_date,
 asset_management_booking.updated_at,
 asset_management_booking.created_at,
 'None' As station_name,
 /*station.station_name,"+*/
 campaign.campaign_name,
 merchant.first_name,
 merchant.last_name
  FROM asset_management_booking,
 campaign,merchant
 Where asset_management_booking.booking_id= @bookingId AND
                            /*asset_management_booking.station_id= station.station_id*/
                            /*AND */
 asset_management_booking.campaign_id = campaign.campaign_id
 AND campaign.merchant_id = merchant.merchant_id 
 
 
 END
 
END
