CREATE PROCEDURE [dbo].[GetQRAssetsList]
(
	@assetName varchar(150),
	@assetType varchar(150),
	@assetCode varchar(150),
	@special varchar(5),
	@bookedStatus varchar(5),
	@assetStatus varchar(5),
	@assetQrCode varchar(100) = NULL,
    @start_date varchar(50),
	@end_date varchar(50)
)
	
AS
BEGIN
	DECLARE @CURRENT_DATETIME Date ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 
	DECLARE @isBooked int

	IF(@assetName is null or @assetName = '')
	BEGIN
		set @assetName = null;
	END

	IF(@assetType is null or @assetType = '')
	BEGIN
		set @assetType = null;
	END

	IF(@assetCode is null or @assetCode = '')
	BEGIN
		set @assetCode = null;
	END

	IF(@special is null or @special = '')
	BEGIN
		set @special = null;
	END

	IF(@bookedStatus is null or @bookedStatus = '')
	BEGIN
		SET @isBooked = null;
	END
	ELSE IF(@bookedStatus like '1')
	BEGIN
		SET @isBooked = 1;
	END
	ELSE IF(@bookedStatus like '0')
	BEGIN
		SET @isBooked = 0;
	END

	IF(@assetStatus is null or @assetStatus = '')
	BEGIN
		set @assetStatus = null;
	END

	IF(@assetQrCode is null or @assetQrCode = '')
	BEGIN
		set @assetQrCode = null;
	END

	SELECT * from (
		SELECT atm.asset_type_management_id as assetId
			,atm.[station_name] as assetName
			,atm.[asset_name] as assetType
			,atm.[asset_code] as assetCode
			,atm.[qr_code_value] as assetQrCode
			,atm.[special_campaign] as assetSpecial
			,CASE WHEN EXISTS (
				SELECT Top (1)1 
				FROM asset_management_booking as amb
				where atm.asset_type_management_id = amb.asset_type_management_id
				AND (@CURRENT_DATETIME between amb.[start_date] AND amb.[end_date])
				AND amb.booked_status = 'TRUE'
			) THEN 1
			ELSE 0 END 
			AS bookedStatus 
			,atm.[asset_status] as assetStatus
			,atm.created_at
		FROM [winkwink].[dbo].[asset_type_management] as atm
		WHERE atm.special_campaign like 'No'
        AND CAST(atm.created_at as Date)>= CAST(@start_date  as DATE)
		AND CAST (atm.created_at as DATE) <= CAST(@end_date as DATE)
        

		UNION 

		SELECT  atm.asset_type_management_id as assetId
			,atm.[station_name] as assetName
			,atm.[asset_name] as assetType
			,atm.[asset_code] as assetCode
			,atm.[qr_code_value] as assetQrCode
			,atm.[special_campaign] as assetSpecial
			,CASE WHEN EXISTS (
				SELECT 1
				FROM asset_type_management as satm
				where atm.asset_type_management_id = satm.asset_type_management_id
				AND (@CURRENT_DATETIME between cast(satm.scan_start_date as date) AND cast(satm.scan_end_date as date))
			) THEN 1
			ELSE 0 END 
			AS bookedStatus 
			,atm.[asset_status] as assetStatus
			,atm.created_at
		FROM [winkwink].[dbo].[asset_type_management] as atm
		where atm.special_campaign like 'Yes'
        AND CAST(atm.created_at as Date)>= CAST(@start_date  as DATE)
		AND CAST (atm.created_at as DATE) <= CAST(@end_date as DATE)
	) as AL
	WHERE  (@assetName is null or AL.assetName like '%'+@assetName+'%')
	AND (@assetType is null or AL.assetType like '%'+@assetType+'%')
	AND (@assetCode is null or AL.assetCode like '%'+@assetCode+'%')
	AND (@special is null or AL.assetSpecial like '%'+@special+'%')
	AND (@isBooked is null or AL.bookedStatus = @isBooked)
	AND (@assetStatus is null or AL.assetStatus like '%'+@assetStatus+'%')
	AND (@assetQrCode is null or AL.assetQrCode like '%'+@assetQrCode+'%')

	order by AL.created_at desc


END
