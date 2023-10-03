CREATE PROCEDURE [dbo].[Get_NotBookedASM_By_AssetCode]
	(@asset_code varchar(150))
	
AS
BEGIN
	select * from asset_type_management 
	 
	where Lower(asset_type_management.asset_code)LIKE Lower('%'+@asset_code+'%')
	AND
	asset_type_management.asset_type_management_id not in 
	(select asset_management_booking.asset_type_management_id from asset_management_booking
	)
	
	
END
