Create PROCEDURE [dbo].[Get_All_Asm_And_AsmBooking_ByAssetCode_with_paging]
	(@asset_code varchar(150),
	@intPage int,
 @intPageSize int)
	
	
	
	
AS
BEGIN

DECLARE @intStartRow int;
DECLARE @intEndRow int;
DECLARE @total int

SET @intStartRow = (@intPage -1) * @intPageSize + 1;
SET @intEndRow = @intPage * @intPageSize;
WITH asset AS(
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
	asset_management_booking.booked_status,
	ROW_NUMBER() OVER(ORDER BY asset_type_management.asset_type_management_id DESC) as intRow, 
     COUNT(asset_type_management.asset_type_management_id) OVER() AS total_count
	from asset_type_management
	FULL OUTER JOIN asset_management_booking On 
	asset_type_management.asset_type_management_id = asset_management_booking.asset_type_management_id
	and asset_management_booking.booked_status!='false'
	Left JOIN campaign On asset_management_booking.campaign_id = campaign.campaign_id
	Left JOIN station on station.station_id = asset_type_management .station_id
	where Lower(asset_type_management.asset_code)LIKE Lower('%'+@asset_code+'%')
	)
	SELECT * FROM asset
WHERE intRow BETWEEN @intStartRow AND @intEndRow
Order By asset_type_management_id DESC
   
	/*AND asset_type_management.asset_type_management_id NOT IN 
	(SELECT asset_management_booking.asset_type_management_id where 
	asset_management_booking.booked_status ='false')*/
	--Order By asset_type_management.asset_type_management_id DESC)
END
