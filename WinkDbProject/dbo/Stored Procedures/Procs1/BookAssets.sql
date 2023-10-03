
CREATE PROC [BookAssets]
(
	@campaign_id int,
	@station_id int,
	@scan_value int,
	@scan_interval int
)

AS
BEGIN
 
INSERT INTO [asset_management_booking]
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
           ,event_status)
 
	SELECT @campaign_id,asset_type_management_id,@scan_value,@scan_interval,(select campaign_start_date from campaign where campaign_id = @campaign_id), (select campaign_end_date from campaign where campaign_id = @campaign_id),getdate(),getdate(),(select merchant_id from campaign where campaign_id = @campaign_id),station_id,station_name,asset_name,asset_code,qr_code_value,0,'TRUE',1
	FROM asset_type_management 
	WHERE STATION_ID = @station_id AND asset_type_management_id not in (select asset_type_management_id from asset_management_booking where station_id = @station_id)

END

