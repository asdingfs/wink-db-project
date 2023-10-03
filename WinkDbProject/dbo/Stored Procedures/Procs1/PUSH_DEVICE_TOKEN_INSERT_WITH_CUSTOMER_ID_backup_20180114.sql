CREATE PROC [dbo].[PUSH_DEVICE_TOKEN_INSERT_WITH_CUSTOMER_ID_backup_20180114]
@device_token varchar(500),
@device_id varchar(10),
@auth_token varchar(255),
@customer_action varchar(50)

AS

BEGIN

	DECLARE @customer_id int;
	DECLARE @WID VARCHAR(50);

	SET @customer_id =ISNULL((SELECT customer_id FROM customer WHERE auth_token = @auth_token),'')


	---------------------Generate WID---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF EXISTS (SELECT * FROM push_device_token WHERE device_token = @device_token and (WID is not null and WID !='') and (customer_id != 0 and customer_id is not null and customer_id !=''))
		SET @WID = (SELECT TOP 1 WID FROM push_device_token WHERE device_token = @device_token and (WID is not null and WID !='') and (customer_id != 0 and customer_id is not null and customer_id !='') ORDER BY updated_at DESC)

	ELSE IF EXISTS (SELECT * FROM push_device_token WHERE (customer_id = @customer_id and customer_id != 0 and customer_id is not null and customer_id !='') and (WID is not null and WID !='') and (device_token is not null and device_token != ''))
		SET @WID = (SELECT TOP 1 WID FROM push_device_token WHERE (customer_id = @customer_id and customer_id != 0 and customer_id is not null and customer_id !='') and (WID is not null and WID !='') and (device_token is not null and device_token != '') ORDER BY updated_at DESC)

	ELSE
	BEGIN
		--IF (@customer_id != 0 and @customer_id is not null and @customer_id != '')
		IF ((@device_token is not null and @device_token != '') and (@customer_id != 0 and @customer_id is not null and @customer_id != ''))
		BEGIN
			EXEC GET_WID @WID OUTPUT
				
			WHILE EXISTS(SELECT * FROM push_device_token WHERE WID = @WID)
				EXEC GET_WID @WID OUTPUT
		END	
	END


	---------------------Insert into push log-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO [push_device_token_action_log]
           ([CUSTOMER_ID]
		   ,[WID]
           ,[device_token]
           ,[device_type]
           ,[customer_action]
           ,[created_at]
           ,[updated_at])
     VALUES
           (@customer_id
		   ,@WID
           ,@device_token
           ,@device_id
           ,@customer_action
           ,(SELECT TODAY FROM VW_CURRENT_SG_TIME)
           ,(SELECT TODAY FROM VW_CURRENT_SG_TIME))


	-----------------------Insert or update device token---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF NOT EXISTS (SELECT * FROM push_device_token WHERE device_token = @device_token AND customer_id = @customer_id)
	BEGIN
		INSERT INTO push_device_token
		([device_token]
		,[customer_id]
		,[WID]
		,[device_type]
		,[created_at]
		,[updated_at])
		VALUES
		(@device_token,@customer_id,@WID,@device_id,(SELECT TODAY FROM VW_CURRENT_SG_TIME),(SELECT TODAY FROM VW_CURRENT_SG_TIME))

		if @@ROWCOUNT > 0
		BEGIN

			IF EXISTS(SELECT * FROM push_device_token WHERE device_token = @device_token and customer_id = 0 and (WID is null or WID = '') and (@WID is not null and @WID !=''))
			BEGIN
				UPDATE push_device_token set updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME), WID = @WID
				WHERE device_token = @device_token and customer_id = 0 and (WID is null or WID = '')
			END

		END


		return;
	END
	ELSE
	BEGIN

		UPDATE push_device_token set updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME)
		WHERE device_token = @device_token AND customer_id = @customer_id

		return;
	END	

END
		