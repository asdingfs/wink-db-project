CREATE Procedure [dbo].[CreateNewAssetManagement_withPeriod]
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
           ,@special_campaign varchar(10)
           ,@scan_start_date varchar(50)
           ,@scan_end_date varchar(50)
           ,@asset_status varchar(10)
           


)
AS
BEGIN
-- Update on 16/11/2016 
-- Including start date , end date and special campaign
Declare @maxID int
--SET @scan_start_date = '2016-11-13'
--SET @scan_end_date = '2016-11-13'
--SET @station_name = (select station.station_name from station where station.station_id =@station_id)
if(@scan_end_date ='')
 set @scan_end_date =null
if(@scan_start_date ='')
 set @scan_start_date =null
 
 -- Update on 04/09/2017
 Declare @asset_category varchar (20)
 set @asset_category = 'global'
 if(@special_campaign ='Yes')
 set @asset_category ='event'
  
 
 if(@station_id =0 OR @station_id ='' OR @station_id is null)
  BEGIN
  print('station1')
  IF(@station_name is not null and  @station_code is not null and @station_name !='' and @station_code !='')
  BEGIN
  IF NOT EXISTS(SELECT * FROM station WHERE LOWER(STATION.station_name) = @STATION_NAME OR LOWER(STATION.station_code) = @station_code )
  BEGIN
  print('station2')
     INSERT INTO station (station_name,station_code,created_at,updated_at)
	         VALUES (@STATION_NAME,@STATION_CODE,@created_at,@created_at)
	         
	 set @station_id = SCOPE_IDENTITY();
	  
  END
  ELSE
  BEGIN
    select '0' as success , 0  as asset_id, 'Asset Name or Asset Name Code already in used' as response_message
    Return
  
  END
  END
  ELSE
  BEGIN
   select '0' as success , 0  as asset_id, 'Fail to save new asset name' as response_message
    Return
  END
  END
  
 
    
  IF(@station_id>0)
	 Select @station_name=station.station_name, @station_code = station.station_code from station where station.station_id =@station_id
IF(@station_id is not null and @station_id !='')

IF NOT Exists (select 1 from asset_type_management a where a.asset_code =@asset_code and 
a.asset_name = @asset_name and a.station_id = @station_id and a.station_code =@station_code)
BEGIN
-- QR Code value format -- 
    set @qr_code_value =Concat(@station_code,'_',@asset_name,'_',@asset_code)
    If NOT Exists (select 1 from asset_type_management where @qr_code_value = qr_code_value)
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
           ,asset_status
           ,scan_start_date
           ,scan_end_date
           ,special_campaign
           ,wink_asset_category
           
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
           ,@asset_status
           ,@scan_start_date
           ,@scan_end_date
           ,@special_campaign
		   ,@asset_category
           )
     
          SET @maxID = (SELECT @@IDENTITY);
     
     IF (@maxID > 0)
     BEGIN
      SET @asset_type_management_id  =  (SELECT SCOPE_IDENTITY());
     ---- QR Code value format -- 
	 update asset_type_management set qr_code_value = REPLACE(Concat(qr_code_value,'_',@asset_type_management_id),'-','_')
      where asset_type_management.asset_type_management_id =@asset_type_management_id
      if(@@ROWCOUNT>0)
      select '1' as success , @asset_type_management_id  as asset_id
      END   
 END
 ELSE 
 BEGIN
      -- Asset already have
     select '0' as success , 0  as asset_id, 'The same asset already created' as response_messasge
     Return
 END    

END