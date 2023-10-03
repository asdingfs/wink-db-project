CREATE PROC [dbo].[SET_CUSTOMER_SIGN_OUT_BY_DEVICE_TOKEN_backup_20180116]
@auth_token varchar(255),
@device_token varchar(255)

AS

BEGIN

	
	DECLARE @customer_id varchar(50)

	IF @device_token is null or @device_token = ''
		SET @device_token = NULL

	SET @customer_id = (SELECT CUSTOMER_ID FROM CUSTOMER WHERE auth_token = @auth_token)


	----SET SIGN OUT STATUS IN CUSTOMER TABLE--------------------------------------------------------------------
	



	----SET SIGN OUT STATUS IN PUSH_DEVICE_TOKEN TABLE-----------------------------------------------------------

	IF @device_token IS NOT NULL
	BEGIN
		IF @customer_id IS NULL 
		BEGIN

			IF EXISTS(SELECT * FROM push_device_token WHERE device_token = @device_token)
				UPDATE push_device_token SET active_status = 0 WHERE device_token = @device_token

		END
		ELSE
		BEGIN
			
			IF EXISTS (SELECT * FROM push_device_token WHERE customer_id = @customer_id AND @device_token = @device_token)
				UPDATE push_device_token SET active_status = 0 WHERE device_token = @device_token AND customer_id = @customer_id
		END
				
	END
	

	SELECT '1' AS response_code, 'success' as response_message
	return;
	
END