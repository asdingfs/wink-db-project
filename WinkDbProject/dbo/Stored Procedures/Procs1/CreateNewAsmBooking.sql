CREATE PROCEDURE [dbo].[CreateNewAsmBooking]
	(@campaign_id int,
	 @station_id int,
	 @scan_value int,
	 @scan_interval decimal(10,2),
	 @station_group_id int,
	 @asset_type_name varchar(200),
	 @asset_type_code varchar(100),
	 @station_code varchar(100),
	 @created_at DateTime,
	 @updated_at DateTime,
	 @start_date DateTime,
	 @end_date DateTime
	 
		 )
	 
AS
BEGIN
DECLARE @bookId int;
DECLARE @qr_code_value varchar(255)
DECLARE @asset_management_id int
DECLARE @existing_bookingId int


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

		SET  @qr_code_value =(Select asset_type_management.qr_code_value
		From asset_type_management 
		where asset_type_management.asset_name=@asset_type_name and
		asset_type_management.asset_code=@asset_type_code and asset_type_management.station_code=@station_code)

		SET  @asset_management_id =(Select asset_type_management.asset_type_management_id
		From asset_type_management 
		where asset_type_management.asset_name=@asset_type_name and
		asset_type_management.asset_code=@asset_type_code and asset_type_management.station_code=@station_code)

		IF(@asset_management_id IS NOT NULL AND @qr_code_value IS NOT NULL)
		BEGIN
			INSERT INTO asset_management_booking
            (campaign_id,station_id,
             asset_type_management_id,
             scan_value,
             scan_interval,qr_code_value,
             station_group_id,asset_type_name,
             asset_type_code,station_code,
             created_at,updated_at,
             start_date,end_date
             )
             VALUES(@campaign_id,@station_id,
             @asset_management_id,
             @scan_value,
             @scan_interval,@qr_code_value,
             @station_group_id,@asset_type_name,
             @asset_type_code,@station_code,
             @created_at,@updated_at,
             @start_date,@end_date);   
             
				IF (@@ROWCOUNT>0)
				BEGIN
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
/*ELSE 
BEGIN

SELECT * FROM asset_management_booking Where asset_management_booking.booking_id=@existing_bookingId;

END*/


		/*Select * from asset_management_booking 
	Where Lower(asset_management_booking.asset_type_name) = Lower('popo_testing_026')
	AND Lower(asset_management_booking.asset_type_code) = Lower('026')
	--AND asset_management_booking.station_code= @station_code
	AND 
	(
	
	('2015-09-22' BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date
	OR '2015-09-29' BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date)
	AND asset_management_booking.booked_status ='true'
	)
	
	Delete from asset_management_booking where booking_id =336
	
	select COUNT (*) from asset_management_booking 
	Where Lower(asset_management_booking.asset_type_name) = Lower('popo_testing_026')
	AND Lower(asset_management_booking.asset_type_code) = Lower('026')
	--AND asset_management_booking.station_code= @station_code
	AND 
	(
	
	('2015-09-22' BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date
	OR '2015-09-30' BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date)
	AND asset_management_booking.booked_status ='true'
	)*/
