CREATE Procedure [dbo].[CreateNewAssetManagementAndLinktoCampaignId]
(           @asset_type_management_id int Out
           ,@station_name varchar(255)
           ,@asset_code varchar(150)
           ,@asset_name varchar(150)
           ,@station_id int
           ,@scan_value int
           ,@scan_interval decimal(10,2)
           ,@qr_code_value varchar(255)
           ,@created_at DateTime
           ,@updated_at DateTime
           ,@station_group_id int
           ,@station_code varchar(150)
           ,@booking_id int out
           ,@campaign_id int
           ,@merchant_id int 
           ,@start_date DateTime
           ,@end_date DateTime
)
AS
BEGIN
Declare @maxID int
	INSERT INTO asset_type_management
           ([station_name]
           ,[asset_code]
           ,[asset_name]
           ,[station_id]
           ,[scan_value]
           ,[scan_interval]
           ,[qr_code_value]
           ,[created_at]
           ,[updated_at]
           ,[station_group_id]
           ,[station_code])
     VALUES
            (@station_name
           ,@asset_code
           ,@asset_name
           ,@station_id
           ,@scan_value
           ,@scan_interval
           ,@qr_code_value
           ,GETDATE()
           ,GETDATE()
           ,@station_group_id
           ,@station_code)
     
          SET @maxID = (SELECT @@IDENTITY);
     
     IF (@maxID > 0)
     BEGIN
      SET @asset_type_management_id  =  (SELECT SCOPE_IDENTITY());
     INSERT INTO asset_management_booking
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
           ,[station_group_id])
     VALUES
           (@campaign_id
           ,@asset_type_management_id
           ,@scan_value
           ,@scan_interval
           ,@start_date
           ,@end_date
           ,GETDATE()
           ,GETDATE()
           ,@merchant_id
           ,@station_id
           ,@station_code
           ,@asset_name
           ,@asset_code
           ,@qr_code_value
           ,@station_group_id)
           
     SET @booking_id  =  (SELECT SCOPE_IDENTITY());

      
      END   
      
      
     

END
