Create PROCEDURE [dbo].[Create_Booked_AllAsset] 
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

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output
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

		   select 142,a.asset_type_management_id,a.scan_value,
		   a.scan_interval,@start_date,@end_date,
		   @current_date,@current_date,241,6,a.station_code,
		   a.asset_name,a.asset_code,a.qr_code_value,a.station_group_id,
		   'TRUE',0,@image_name,@image_url,@image_id,0

		   
		   from asset_type_management as a
		   where a.wink_asset_category ='global'
   


END

