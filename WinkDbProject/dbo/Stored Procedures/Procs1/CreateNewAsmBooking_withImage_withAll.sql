CREATE PROCEDURE [dbo].[CreateNewAsmBooking_withImage_withAll] 
	( @campaign_id int,
	 @start_date datetime,
	 @end_date datetime,
	 @image_id int,
	 @image_name varchar(100),
	 @image_url varchar(100)
	 )
AS
BEGIN
Declare @login_times int
Declare @current_date datetime
Declare @admin_user_id int 
Declare @response_code int
Declare @merchant_id int


Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

set @merchant_id = (select merchant_id from campaign where campaign.campaign_id =@campaign_id)

 INSERT INTO [dbo].[asset_management_booking]
           ([campaign_id]
           ,[asset_type_management_id]
           ,[scan_value]
           ,[scan_interval]
           ,[start_date]
           ,[end_date]
           ,[created_at]
           ,[updated_at]
           ,[merchant_id]
           ,[station_id]
           ,[station_code]
           ,[asset_type_name]
           ,[asset_type_code]
           ,[qr_code_value]
           ,[station_group_id]
           ,[booked_status]
           ,[event_status]
           ,[image_name]
           ,[image_url]
           ,[image_id]
           ,[winktag_id])

		   select @campaign_id,a.asset_type_management_id,a.scan_value,
		   a.scan_interval,@start_date,@end_date,
		   @current_date,@current_date,@merchant_id,a.station_id,a.station_code,
		   a.asset_name,a.asset_code,a.qr_code_value,a.station_group_id,
		   'TRUE',0,@image_name,@image_url,@image_id,0

		   
		   from asset_type_management as a
		   where a.wink_asset_category ='global'
		   and a.asset_status !=0
		   and a.special_campaign='No'
		  
		   and a.asset_type_management_id not in 
		   (
		     select asm.asset_type_management_id from asset_management_booking as asm 
			 where 
		      (
			    (cast(asm.start_date as date) BETWEEN cast(@start_date as date) AND cast(@end_date as date))
				OR (cast(asm.end_date as date) BETWEEN cast(@start_date as date) AND cast(@end_date as date))
			    OR (@start_date BETWEEN asm.start_date AND asm.end_date)
	            OR (@end_date BETWEEN asm.start_date AND asm.end_date)
			  )

				AND asm.booked_status ='true'
			   
			    
			 
			 )


IF @@ROWCOUNT >0
BEGIN
print ('@@ROWCOUNT')
print ('KKKKK')
IF EXISTS (select 1 From asset_management_booking as asm where 
  
	(
	 (cast(asm.start_date as date) BETWEEN cast(@start_date as date) AND cast(@end_date as date))
	 OR (cast(asm.end_date as date) BETWEEN cast(@start_date as date) AND cast(@end_date as date))
	 OR (@start_date BETWEEN asm.start_date AND asm.end_date)
	 OR (@end_date BETWEEN asm.start_date AND asm.end_date)
	)
	AND asm.booked_status ='true'
	and campaign_id !=@campaign_id
	
	and asm.asset_type_management_id in 
	(
	  select a.asset_type_management_id from asset_type_management as a where 
	   a.wink_asset_category ='global'
	)
	)

	BEGIN
	print ('Have Booking 1')

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
 Where 
 campaign.campaign_id = asset_management_booking.campaign_id
 and 
 campaign.merchant_id = merchant.merchant_id
 and
 station.station_id = asset_management_booking.station_id
 and
	
	(
	
	cast(asset_management_booking.start_date as date) BETWEEN cast(@start_date as date) AND cast(@end_date as date)
	OR cast(asset_management_booking.end_date as date) BETWEEN cast(@start_date as date) AND cast(@end_date as date)
	OR @start_date BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date
	OR @end_date BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date
	
	

	)
	AND asset_management_booking.booked_status ='true'
	and asset_management_booking.campaign_id !=@campaign_id
	
	and asset_management_booking.asset_type_management_id in 
	(
	  select a.asset_type_management_id from asset_type_management as a where 
	   a.wink_asset_category ='global'
	)
  
 
 
 END

    Else 
	BEGIN
	 print ('Do not Have Booking')
	 select '1' as response_code

	END
END
ELSE 
BEGIN
print ('@@ROWCOUNT')
print ('PPPP')
IF EXISTS (select 1 From asset_management_booking as asm where 
  
     (
	 (cast(asm.start_date as date) BETWEEN cast(@start_date as date) AND cast(@end_date as date))
	 OR (cast(asm.end_date as date) BETWEEN cast(@start_date as date) AND cast(@end_date as date))
	 OR (@start_date BETWEEN asm.start_date AND asm.end_date)
	 OR (@end_date BETWEEN asm.start_date AND asm.end_date)
	)
	AND asm.booked_status ='true'
	and campaign_id !=@campaign_id
	
	and asm.asset_type_management_id in 
	(
	  select a.asset_type_management_id from asset_type_management as a where 
	   a.wink_asset_category ='global'
	)
	)

	BEGIN
	print ('Have Booking 1')

SELECT '0' as response_code , asset_management_booking.booking_id,
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
 Where 
 campaign.campaign_id = asset_management_booking.campaign_id
 and 
 campaign.merchant_id = merchant.merchant_id
 and
 station.station_id = asset_management_booking.station_id
 and
	
	(
	
    (cast(asset_management_booking.start_date as date) BETWEEN cast(@start_date as date) AND cast(@end_date as date))
	OR (cast(asset_management_booking.end_date as date) BETWEEN cast(@start_date as date) AND cast(@end_date as date))
	OR (@start_date BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date)
	OR (@end_date BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date)
	
	)
	and asset_management_booking.booked_status = 'True'
	and asset_management_booking.campaign_id !=@campaign_id
	
	and asset_management_booking.asset_type_management_id in 
	(
	  select a.asset_type_management_id from asset_type_management as a where 
	   a.wink_asset_category ='global'
	)
  
  
    END
    Else 
	BEGIN
	 print ('Do not Have Booking')
	 select '0' as response_code

	END

END

END

