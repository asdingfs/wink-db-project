CREATE PROCEDURE [dbo].[EnableQRAsset]
(@qrCode varchar(100))
AS
BEGIN
    DECLARE @current_datetime datetime
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime OUTPUT

	UPDATE asset_type_management
	SET asset_status = '1', updated_at = @current_datetime
	where qr_code_value like @qrCode;

	IF(@@ROWCOUNT>0)
	BEGIN
		select '1' as response_code , 'Successfully enabled' as response_message
	END
	ELSE
	BEGIN
		select '0' as response_code , 'Failed to enable' as response_message
	END
END
