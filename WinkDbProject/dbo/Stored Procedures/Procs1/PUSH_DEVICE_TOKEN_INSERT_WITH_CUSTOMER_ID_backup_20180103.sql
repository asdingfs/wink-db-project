CREATE PROC [dbo].[PUSH_DEVICE_TOKEN_INSERT_WITH_CUSTOMER_ID_backup_20180103]
@device_token varchar(500),
@device_id varchar(10),
@auth_token varchar(255),
@customer_action varchar(50)

AS

BEGIN

	DECLARE @customer_id int;

	SET @customer_id =ISNULL((SELECT customer_id FROM customer WHERE auth_token = @auth_token),'')

	---------------------Insert into push log---------------------------------------------------------------------------------
	INSERT INTO [push_device_token_action_log]
           ([CUSTOMER_ID]
           ,[device_token]
           ,[device_type]
           ,[customer_action]
           ,[created_at]
           ,[updated_at])
     VALUES
           (@customer_id
           ,@device_token
           ,@device_id
           ,@customer_action
           ,(SELECT TODAY FROM VW_CURRENT_SG_TIME)
           ,(SELECT TODAY FROM VW_CURRENT_SG_TIME))


	-----------------------iOS device----------------------------------------------------------------------------------------------
	IF @device_id = 'iOS'
	BEGIN
		IF NOT EXISTS (SELECT * FROM push_device_token_ios WHERE device_token = @device_token AND customer_id = @customer_id)
		BEGIN
			INSERT INTO push_device_token_ios
			([device_token]
			,[customer_id]
			,[created_at]
			,[updated_at])
			VALUES
			(@device_token,@customer_id,(SELECT TODAY FROM VW_CURRENT_SG_TIME),(SELECT TODAY FROM VW_CURRENT_SG_TIME))

			return;
		END
		ELSE
		BEGIN
			--SELECT (@device_token+ ' already exists in the table push_device_token_ios') as error_response

			UPDATE push_device_token_ios set updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME)
			WHERE device_token = @device_token AND customer_id = @customer_id

			return;
		END
	END


	-----------------------android device----------------------------------------------------------------------------------------------
	ELSE IF @device_id = 'android'
	BEGIN
		IF NOT EXISTS (SELECT * FROM push_device_token_android WHERE device_token = @device_token AND customer_id = @customer_id)
		BEGIN
			INSERT INTO push_device_token_android
			([device_token]
			,[customer_id]
			,[created_at]
			,[updated_at])
			VALUES
			(@device_token,@customer_id,(SELECT TODAY FROM VW_CURRENT_SG_TIME),(SELECT TODAY FROM VW_CURRENT_SG_TIME))

			return;
		END
		BEGIN
			--SELECT (@device_token+ ' already exists in the table push_device_token_android') as error_response

			UPDATE push_device_token_android set updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME)
			WHERE device_token = @device_token AND customer_id = @customer_id

			return;
		END
	END

END
		