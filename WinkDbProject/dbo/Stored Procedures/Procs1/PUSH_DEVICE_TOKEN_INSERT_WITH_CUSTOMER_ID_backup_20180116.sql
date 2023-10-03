CREATE PROC [dbo].[PUSH_DEVICE_TOKEN_INSERT_WITH_CUSTOMER_ID_backup_20180116]
@device_token varchar(500),
@device_id varchar(10),
@auth_token varchar(255),
@customer_action varchar(50)

AS

BEGIN

	DECLARE @customer_id varchar(50);
	DECLARE @WID VARCHAR(50);
	DECLARE @to_lock_customer_id varchar(50);
	DECLARE @active_status varchar(10) = 0;

	SET @customer_id = (SELECT customer_id FROM customer WHERE auth_token = @auth_token)

	if @device_token is null or @device_token = ''
		SET @device_token = NULL;

	
	---------------------set WID in customer table--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF @customer_id IS NOT NULL
	BEGIN

		SET @active_status = 1;

		IF EXISTS(SELECT * FROM customer WHERE customer_id = @customer_id AND WID IS NULL)
		BEGIN

			EXEC GET_WID @WID OUTPUT
				
			WHILE EXISTS(SELECT * FROM customer WHERE WID = @WID)
				EXEC GET_WID @WID OUTPUT

			UPDATE customer SET WID = @WID, updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME) WHERE CUSTOMER_ID = @customer_id

		END

		IF EXISTS(SELECT * FROM customer WHERE customer_id = @customer_id AND WID IS NOT NULL)
			SET @WID = (SELECT WID FROM customer WHERE customer_id = @customer_id)

	END
		
	IF @device_token IS NOT NULL
	BEGIN

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
		IF @customer_id IS NOT NULL
		BEGIN
			IF EXISTS (SELECT * FROM push_device_token WHERE customer_id = @customer_id AND device_token != @device_token)
				UPDATE push_device_token SET active_status = 0 WHERE customer_id = @customer_id
		END
		
		IF NOT EXISTS (SELECT * FROM push_device_token WHERE device_token = @device_token AND customer_id = @customer_id)
		BEGIN

			INSERT INTO push_device_token
			([device_token]
			,[customer_id]
			,[WID]
			,[device_type]
			,[active_status]
			,[created_at]
			,[updated_at])
			VALUES
			(@device_token,@customer_id,@WID,@device_id,@active_status,(SELECT TODAY FROM VW_CURRENT_SG_TIME),(SELECT TODAY FROM VW_CURRENT_SG_TIME))

		END
		ELSE
		BEGIN
			
			UPDATE push_device_token set updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME), active_status = @active_status
			WHERE device_token = @device_token AND customer_id = @customer_id

		END	


		/*
		-----------------------------------locked for multiple account------------------------------------------------------------
		IF @customer_id IS NOT NULL
		BEGIN
			IF (SELECT COUNT(*) FROM push_device_token WHERE customer_id IS NOT NULL AND device_token = @device_token) > 1
			BEGIN

				create table #temp_customer_id_table
				(
					customer_id varchar(50)
				)

				insert into #temp_customer_id_table
				SELECT P.customer_id FROM push_device_token P INNER JOIN CUSTOMER C
					ON P.customer_id = C.customer_id AND C.status = 'enable'
					WHERE P.customer_id IS NOT NULL AND P.device_token = @device_token AND P.active_status = 1
					ORDER BY P.created_at asc

				----Lock customer-------------------------------------------------------------------------------------------
				UPDATE customer SET status = 'disable', updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME) WHERE CUSTOMER_ID IN (SELECT customer_id FROM #temp_customer_id_table)

				UPDATE push_device_token SET active_status = 0, updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME) WHERE CUSTOMER_ID IN (SELECT customer_id FROM #temp_customer_id_table)
		

				----insert into system log table-----------------------------------------------------------------------------
				DECLARE temp_cursor CURSOR FOR
				SELECT customer_id FROM #temp_customer_id_table

				DECLARE @temp_customer_id varchar(50);

				OPEN temp_cursor;
				FETCH NEXT FROM temp_cursor INTO @temp_customer_id;

				WHILE @@FETCH_STATUS = 0

				BEGIN
					DECLARE @reason varchar(50);
						
					IF @temp_customer_id = (SELECT TOP 1 customer_id FROM push_device_token WHERE device_token = @device_token and customer_id is not null /*AND CUSTOMER_ID IN (SELECT CUSTOMER_ID FROM #temp_customer_id_table)*/ ORDER BY created_at ASC)
						SET @reason = 'Token'
					ELSE
						SET @reason = (SELECT TOP 1 WID FROM push_device_token WHERE device_token = @device_token AND customer_id is not null /*CUSTOMER_ID IN (SELECT CUSTOMER_ID FROM #temp_customer_id_table)*/ ORDER BY created_at ASC)


					INSERT INTO System_Log (customer_id,action_status,created_at,reason,enable_status,device_token,device_type)
					VALUES (@temp_customer_id,'disable',(select today from VW_CURRENT_SG_TIME),@reason,'No',@device_token,@device_id)

					FETCH NEXT FROM temp_cursor INTO @temp_customer_id;
				END;

				CLOSE temp_cursor;

				DEALLOCATE temp_cursor;


				drop table #temp_customer_id_table
				--UPDATE push_device_token SET active_staus = 0, updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME) WHERE device_token = @device_token

			END
		END
		
		*/


	END
	
END		