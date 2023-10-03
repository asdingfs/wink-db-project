CREATE PROCEDURE [dbo].[DisableQRAsset]
(@qrCode varchar(100))
AS
BEGIN
    DECLARE @current_date date
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

	DECLARE @current_datetime datetime
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime OUTPUT

	UPDATE asset_type_management
	SET asset_status = '0', updated_at = @current_datetime
	where qr_code_value like @qrCode;

	IF(@@ROWCOUNT>0)
	BEGIN
		IF EXISTS (
			SELECT 1 FROM asset_management_booking 
			WHERE qr_code_value like @qrCode
			AND @current_date between cast([start_date] as date) and cast([end_date] as date)
			AND  booked_status = 'True')
		BEGIN
			UPDATE asset_management_booking 
			SET booked_status = 'False', updated_at = @current_datetime
			WHERE qr_code_value like @qrCode
			AND @current_date between cast([start_date] as date) and cast([end_date] as date)
			AND  booked_status = 'True';
			IF(@@ROWCOUNT>0)
			BEGIN
				select '1' as response_code , 'Successfully disabled' as response_message
			END
			ELSE
			BEGIN
				select '0' as response_code , 'Failed to disable' as response_message
			END
		END
		ELSE
		BEGIN
			select '1' as response_code , 'Successfully disabled' as response_message
		END
	END
	ELSE
	BEGIN
		select '0' as response_code , 'Failed to disable' as response_message
	END
END
