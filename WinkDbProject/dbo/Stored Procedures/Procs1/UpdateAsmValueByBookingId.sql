CREATE PROCEDURE [dbo].[UpdateAsmValueByBookingId]
	(@booking_id int,
	 @scan_interval int,
	 @scan_value int,
	 @start_date DateTime,
	 @end_date DateTime,
	 @image_id int,
	 @image_name varchar(200),
	 @image_url varchar(250)
	 )
 
AS
BEGIN
-- Update on 17/11/2016 for Special Campaign
Declare @current_date datetime
Declare @customer_scan_startdate datetime
Declare @customer_last_scandate datetime
Declare @old_scan_startdate datetime
Declare @old_scan_enddate datetime
Declare @vaild_to_updte int
Declare @special_campaign varchar(10)
Declare @asset_type_management_id int
Declare @valid_to_update varchar(2)

select @special_campaign = special_campaign,@asset_type_management_id = asset_management_booking.asset_type_management_id ,
@old_scan_startdate=start_date , @old_scan_enddate = end_date
from asset_type_management, asset_management_booking
where asset_management_booking.asset_type_management_id = asset_type_management.asset_type_management_id
and asset_management_booking.booking_id = @booking_id


Set @vaild_to_updte =1

If Exists (select 1 from asset_management_booking as b where 
    b.asset_type_management_id = @asset_type_management_id	
	and 
	(
	(Cast(@start_date as date ) Between CAST(b.start_date as date) and CAST(b.end_date as date)) 
	OR 
	(Cast(@end_date as date ) Between CAST(b.start_date as date) and CAST(b.end_date as date))
	) and booking_id != @booking_id)
    BEGIN
     Set @vaild_to_updte =0
     END
     
 IF(@start_date is not null and @start_date is not null and @end_date !='' and @end_date!='')
Begin
    print(1)
	If Exists (Select 1 from customer_earned_points where qr_code=(select qr_code from asset_type_management where asset_type_management.asset_type_management_id = @asset_type_management_id
	and campaign_booking_id = @booking_id
	))
	BEGIN
	print(2)
	Select @customer_scan_startdate= CAST(created_at as date) from customer_earned_points where qr_code=(select qr_code from asset_type_management where asset_type_management.asset_type_management_id = @asset_type_management_id)
	Select @customer_last_scandate= CAST(created_at as date) from customer_earned_points where qr_code=(select qr_code from asset_type_management where asset_type_management.asset_type_management_id = @asset_type_management_id)order by created_at desc
	
	print('@customer_scan_startdate')
	print(@customer_scan_startdate)
	
	print('@customer_last_scandate')
	print(@customer_scan_startdate)
	
	if(@old_scan_startdate !='' and @old_scan_enddate !='')
	 BEGIN
		print(3)
		Begin
			
            if(cast(@start_date as date) != CAST(@old_scan_startdate as date))
			Begin
			Print(4)
			if(cast(@start_date as date) != CAST (@customer_scan_startdate as date) and
			cast(@start_date as date) > CAST (@customer_scan_startdate as date)
			)
			 Begin
			 print(5)
				Set @valid_to_update =0
			 End
			END
	         if(cast(@end_date as date) != CAST (@old_scan_enddate as date))
	         BEGIN
	         
	         print (6)
			 if( CAST(@end_date as date) < CAST(@current_date as date) and CAST(@end_date as date) !=  CAST (@customer_last_scandate as date))
			 Begin
			 Print (7)
				Set @valid_to_update =0
			 End
			 END
			 
			
		
		END
	 END
	 	
	
	END
END

Else 
Begin
 Set @valid_to_update =0 
End

if(@vaild_to_updte=1)
BEGIN

			Update asset_management_booking set 
			scan_interval = @scan_interval,
			scan_value = @scan_value,
			image_id = @image_id,
			image_url = @image_url,
			image_name = @image_name,
			start_date = @start_date,
			end_date = @end_date,
			updated_at = GETDATE()
			Where booking_id = @booking_id

			If(@@ROWCOUNT>0)
			Begin
			
			
			-- Check special campaign
			if(@special_campaign='Yes')
							BEGIN
							update asset_type_management set scan_start_date =@start_date,
							scan_end_date = @end_date where asset_type_management.asset_type_management_id = @asset_type_management_id
							END
							

			End
			
			If(@@ERROR =0)
			Select 1 as success , 'Successfully saved' as response_message


END

ELSE

BEGIN

	
Select 0 as success , 'Cannot update start date and end date. Asset already booked during this period' as response_message


END


END
