CREATE PROCEDURE [dbo].[CreateNewAsmBooking_withImage]
	(@campaign_id int,
	 @asset_type_management_id int,
	 @scan_value int,
	 @scan_interval decimal(10,2),
	 @created_at DateTime,
	 @updated_at DateTime,
	 @start_date DateTime,
	 @end_date DateTime,
	 @image_name varchar(200),
	 @image_url varchar(200),
	 @image_id int 
	 
		 )
	 
AS
BEGIN
DECLARE @special_campaign varchar(10)
DECLARE @bookId int;
DECLARE @qr_code_value varchar(255)
DECLARE @existing_bookingId int
DEClARE  @station_id int ,@station_group_id int, @asset_type_name varchar(200),
	 @asset_type_code varchar(100), @station_code varchar(100)


Select @station_id = asm.station_id,@station_code=asm.station_code,
@qr_code_value =asm.qr_code_value,@station_group_id =asm.station_group_id,
@asset_type_code = asm.asset_code, @asset_type_name = asm.asset_name,
@special_campaign= asm.special_campaign
from asset_type_management as asm where asm.asset_type_management_id = @asset_type_management_id
 and asm.special_campaign ='No'

	SET	@bookId = (
	Select COUNT(*) from asset_management_booking 
	Where Lower(asset_management_booking.asset_type_name) = Lower(@asset_type_name)
	AND Lower(asset_management_booking.asset_type_code) = Lower(@asset_type_code)
	AND asset_management_booking.station_code= @station_code
	AND 
	(
	
	(@start_date BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date
	OR @end_date BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date)
	AND asset_management_booking.booked_status ='true'
	)
	)
	
	
	
	SET @existing_bookingId =ISNULL(@bookId,0);
		
	IF @existing_bookingId=0

	BEGIN	
         print(@existing_bookingId)
         
  		IF(@asset_type_management_id IS NOT NULL AND @qr_code_value IS NOT NULL)
		BEGIN
		    print('Asset')
			print(@asset_type_management_id)
			INSERT INTO asset_management_booking
            (campaign_id,station_id,
             asset_type_management_id,
             scan_value,
             scan_interval,qr_code_value,
             station_group_id,asset_type_name,
             asset_type_code,station_code,
             created_at,updated_at,
             start_date,end_date,
             image_name,image_url,
             image_id
             )
             VALUES(@campaign_id,@station_id,
             @asset_type_management_id,
             @scan_value,
             @scan_interval,@qr_code_value,
             @station_group_id,@asset_type_name,
             @asset_type_code,@station_code,
             @created_at,@updated_at,
             @start_date,@end_date,
             @image_name,@image_url,@image_id
             );   
             
				IF (@@ROWCOUNT>0)
				BEGIN
				
				--- for Special Campaign update start date and end date
				/*if(@special_campaign='Yes')
				BEGIN
				update asset_type_management set scan_start_date =@start_date,
				scan_end_date = @end_date where asset_type_management.asset_type_management_id = @asset_type_management_id
				END*/
				
				SELECT '1' AS response_code , 'Successfully link asset'
				AS response_message
				RETURN
				
				END
				ELSE 
				BEGIN
				SELECT '0' AS response_code , 'Fail ot link asset'
				AS response_message
				RETURN
				END
             

	END
	
	
	
	END
	
	ELSE 
		BEGIN

 
 IF (@station_code IS NOT NULL AND @station_code !='' AND @station_id != 0 AND @station_code!='No')
 BEGIN 
 
 SELECT '2' as response_code , asset_management_booking.booking_id,
 asset_management_booking.asset_type_management_id,
 asset_management_booking.qr_code_value,
 asset_management_booking.scan_value,
 asset_management_booking.scan_interval,
 asset_management_booking.asset_type_code,
 asset_management_booking.asset_type_name,
 asset_management_booking.start_date,
 asset_management_booking.end_date,
 asset_management_booking.updated_at,
 asset_management_booking.created_at,
 station.station_name,
 campaign.campaign_name,
 campaign.campaign_id,
 merchant.first_name,
 merchant.last_name
 FROM asset_management_booking,
 campaign,merchant,station
 Where Lower(asset_management_booking.asset_type_name) = Lower(@asset_type_name)
	AND Lower(asset_management_booking.asset_type_code) = Lower(@asset_type_code)
	AND asset_management_booking.station_code= @station_code
	AND 
	(
	
	(@start_date BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date
	OR @end_date BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date)
	AND asset_management_booking.booked_status ='true'
	)
 
  AND
       asset_management_booking.station_code= station.station_code
       AND 
        asset_management_booking.campaign_id = campaign.campaign_id
       AND campaign.merchant_id = merchant.merchant_id 
 
 
 END
 ELSE
 BEGIN
 
 SELECT '2' as response_code ,asset_management_booking.booking_id,
 asset_management_booking.asset_type_management_id,
 asset_management_booking.qr_code_value,
 asset_management_booking.scan_value,
 asset_management_booking.scan_interval,
 asset_management_booking.asset_type_code,
 asset_management_booking.asset_type_name,
 asset_management_booking.start_date,
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
 
 Where Lower(asset_management_booking.asset_type_name) = Lower(@asset_type_name)
	AND Lower(asset_management_booking.asset_type_code) = Lower(@asset_type_code)
	AND asset_management_booking.station_code= @station_code
	AND 
	(
	
	(@start_date BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date
	OR @end_date BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date)
	AND asset_management_booking.booked_status ='true'
	)
 
  AND
       --asset_management_booking.station_code= station.station_code
      -- AND 
        asset_management_booking.campaign_id = campaign.campaign_id
       AND campaign.merchant_id = merchant.merchant_id 
 
 
 
 END
 
END
	

END

