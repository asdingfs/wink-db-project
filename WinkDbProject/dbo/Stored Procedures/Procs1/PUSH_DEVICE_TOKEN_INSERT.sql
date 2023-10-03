CREATE PROC [dbo].[PUSH_DEVICE_TOKEN_INSERT]
@device_token varchar(500),
@device_id varchar(10)

AS

BEGIN
	
	/*
	IF NOT EXISTS (SELECT * FROM push_device_token WHERE device_token = @device_token)
	BEGIN
		INSERT INTO push_device_token
		([device_token]
		,[device_type]
		,[created_at]
		,[updated_at])
		VALUES
		(@device_token,@device_id,(SELECT TODAY FROM VW_CURRENT_SG_TIME),(SELECT TODAY FROM VW_CURRENT_SG_TIME))

		return;
	END
	ELSE
	BEGIN

		UPDATE push_device_token set updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME)
		WHERE device_token = @device_token

		return;
	END

	*/

	SELECT 'push' as push

END
		