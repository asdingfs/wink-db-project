CREATE Procedure [dbo].[CreateNewAssetManagement]
(          @asset_type_management_id int Out
           ,@station_name varchar(100)
           ,@asset_code varchar(150)
           ,@asset_name varchar(150)
           ,@station_id int
           ,@scan_value int
           ,@scan_interval decimal(10,2)
           ,@qr_code_value varchar(255)
           ,@created_at DateTime
           ,@updated_at DateTime
           ,@station_group_id int
           ,@station_code varchar(100)
           )
AS
BEGIN
-- Update on 16/11/2016 
-- Including start date , end date and special campaign
Declare @maxID int
--SET @scan_start_date = '2016-11-13'
--SET @scan_end_date = '2016-11-13'
SET @station_name = (select station.station_name from station where station.station_id =@station_id)
IF NOT Exists (select 1 from asset_type_management a where a.asset_code =@asset_code and 
a.asset_name = @asset_name and a.station_id = @station_id and a.station_code =@station_code)
BEGIN
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
           ,[station_code]
                
           )
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
           ,@station_code
          
           )
     
          SET @maxID = (SELECT @@IDENTITY);
     
     IF (@maxID > 0)
     BEGIN
      SET @asset_type_management_id  =  (SELECT SCOPE_IDENTITY());
      update asset_type_management set qr_code_value = REPLACE(Concat(qr_code_value,'_',@asset_type_management_id),'-','_')
      where asset_type_management.asset_type_management_id =@asset_type_management_id
      if(@@ROWCOUNT>0)
      return @asset_type_management_id
      END   
 END
 
  

END

