-- =============================================
CREATE PROCEDURE [dbo].[GetAllAssetManagementDetailList]

AS	
BEGIN
SELECT asset_type_management.asset_type_management_id,
                            asset_type_management.station_group_id,
                            asset_type_management.station_id,
                            asset_type_management.asset_code,
                            asset_type_management.qr_code_value,
                            asset_type_management.scan_value,
                            asset_type_management.scan_interval,
                            asset_type_management.created_at,
                            asset_type_management.asset_code,
                            asset_type_management.asset_name,
                            asset_type_management.updated_at,
                            station.station_name
                            
                            FROM asset_type_management Left JOIN station
                            ON Lower(asset_type_management.station_code) =  Lower(station.station_code)
                            ORDER BY asset_type_management_id DESC
                            
END
