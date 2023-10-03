Create PROCEDURE [dbo].[GetDistinctStationByAssetName]
	(@asset_name varchar(50)
	 )
AS
BEGIN
 Select Distinct asset_type_management.station_code,asset_type_management.asset_name,
 station.station_id,station.station_name 
 from asset_type_management left join station on 
 asset_type_management.station_code = station.station_code
 Where  asset_type_management.asset_name = @asset_name 
 and (asset_type_management.scan_end_date is null or scan_end_date ='')
 and (asset_type_management.scan_start_date is null or scan_start_date ='')
 Group By asset_type_management.station_code,asset_name,station.station_id,station.station_name
 Order by station.station_name;

END
