CREATE PROCEDURE [dbo].[GetQrVauleAndIdByAssetNameCodeAndStation] 
	(@asset_code varchar(100),
	 @asset_name varchar(200),
	 @station_code varchar(100)
	 )
	 
AS
BEGIN
Select asset_type_management.asset_type_management_id,asset_type_management.qr_code_value
From asset_type_management 
where asset_type_management.asset_name=@asset_name and
asset_type_management.asset_code=@asset_code and asset_type_management.station_code=@station_code

END
