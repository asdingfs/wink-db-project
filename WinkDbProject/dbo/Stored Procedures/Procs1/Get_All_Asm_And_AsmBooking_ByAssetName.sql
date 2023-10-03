CREATE PROCEDURE [dbo].[Get_All_Asm_And_AsmBooking_ByAssetName]
	(@asset_name varchar(150))
	
AS
BEGIN
	Select asset_type_management.asset_name,asset_type_management.asset_code,asset_type_management.qr_code_value,
	--asset_type_management.station_name,
	asset_type_management.asset_type_management_id,
	asset_management_booking.start_date,asset_management_booking.end_date,
	station.station_name,
	campaign.campaign_name,
	asset_management_booking.booking_id,
	asset_management_booking.asset_type_name,
	asset_management_booking.asset_type_code,
	asset_management_booking.campaign_id,
	asset_management_booking.booked_status
	from asset_type_management
	FULL OUTER JOIN asset_management_booking On 
	asset_type_management.asset_type_management_id = asset_management_booking.asset_type_management_id
	and asset_management_booking.booked_status!='false'
	Left JOIN campaign On asset_management_booking.campaign_id = campaign.campaign_id
	Left JOIN station on station.station_id = asset_type_management .station_id
	where Lower(asset_type_management.asset_name)LIKE Lower('%'+@asset_name+'%')
	AND asset_type_management.asset_type_management_id NOT IN 
	(SELECT asset_management_booking.asset_type_management_id where 
	asset_management_booking.booked_status ='false')
	Order By asset_type_management.asset_type_management_id DESC
END
