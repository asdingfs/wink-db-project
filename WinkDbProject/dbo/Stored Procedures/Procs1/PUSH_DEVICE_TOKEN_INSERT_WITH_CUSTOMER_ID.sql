CREATE PROC [dbo].[PUSH_DEVICE_TOKEN_INSERT_WITH_CUSTOMER_ID]
@device_token varchar(500),
@device_id varchar(10),
@auth_token varchar(255),
@customer_action varchar(50),
@app_version varchar(50)
AS

BEGIN
	declare @dob varchar(100);
	declare @age int;
	DECLARE @locked_reason varchar(200)
	DECLARE @customer_id varchar(50);
	DECLARE @WID VARCHAR(50);
	DECLARE @to_lock_customer_id varchar(50);
	DECLARE @active_status varchar(10) = 0;
	DECLARE @multiple_token varchar(10) = 'Multiple';
	DECLARE @token_count int = 10;
	DECLARE @total_days int = 30;

	DECLARE @admin_user_email_for_lock_account varchar(255) = 'system@winkwink.sg'

	SET @customer_id = (SELECT customer_id FROM customer WHERE auth_token = @auth_token)

	if @device_token is null or @device_token = ''
		SET @device_token = NULL;

	IF(@app_version is null or @app_version = '')
	BEGIN
		SET @app_version = null;
	END

	---------------------set WID in customer table--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF @customer_id IS NOT NULL
	BEGIN

		SET @active_status = 1;

		IF EXISTS(SELECT * FROM customer WHERE customer_id = @customer_id AND WID IS NULL)
		BEGIN

			EXEC GET_WID @WID OUTPUT
				
			WHILE EXISTS(SELECT * FROM customer WHERE WID = @WID)
				EXEC GET_WID @WID OUTPUT

			UPDATE customer SET WID = @WID, updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME) WHERE CUSTOMER_ID = @customer_id;
			SET @dob = (SELECT date_of_birth from customer where customer_id = @customer_id);
			IF(@dob is not null)
				BEGIN
							
					set @age = (select floor(datediff(day,@dob, DATEADD(HOUR,8,GETDATE())) / 365.25));

					IF( @age <= 0 or @age > 90)
					BEGIN

						Update customer set customer.status = 'disable',
						customer.updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME) where customer.customer_id = @customer_id;

						IF (@@ROWCOUNT>0)
						BEGIN
									
							Set @locked_reason = 'Year of birth is '+SUBSTRING(@dob, 1, 4)+'.';

							Insert into System_Log (customer_id, action_status,created_at,reason)
							Select customer.customer_id,
							'disable',(SELECT TODAY FROM VW_CURRENT_SG_TIME) ,@locked_reason+'-push_device_token'
							from customer where customer.customer_id = @customer_id;

							-----INSERT INTO ACCOUNT FILTERING LOCK
							EXEC Create_WINK_Account_Filtering @customer_id,@locked_reason,@admin_user_email_for_lock_account;
						END
					END
				END

		END

		IF EXISTS(SELECT * FROM customer WHERE customer_id = @customer_id AND WID IS NOT NULL)
			SET @WID = (SELECT WID FROM customer WHERE customer_id = @customer_id)

	END
		
	IF @device_token IS NOT NULL
	BEGIN

		-----------------Check the customer ID is attached to other device----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		IF @customer_id IS NOT NULL
		BEGIN
			SET @dob = (SELECT date_of_birth from customer where customer_id = @customer_id);
			IF(@dob is not null)
			BEGIN
							
				set @age = (select floor(datediff(day,@dob, DATEADD(HOUR,8,GETDATE())) / 365.25));

				IF( @age <= 0 or @age > 90)
				BEGIN

					Update customer set customer.status = 'disable',
					customer.updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME) where customer.customer_id = @customer_id;

					IF (@@ROWCOUNT>0)
					BEGIN
									
						Set @locked_reason = 'Year of birth is '+SUBSTRING(@dob, 1, 4)+'.';

						Insert into System_Log (customer_id, action_status,created_at,reason)
						Select customer.customer_id,
						'disable',(SELECT TODAY FROM VW_CURRENT_SG_TIME) ,@locked_reason
						from customer where customer.customer_id = @customer_id;

						-----INSERT INTO ACCOUNT FILTERING LOCK
						EXEC Create_WINK_Account_Filtering @customer_id,@locked_reason,@admin_user_email_for_lock_account;
					END
				END
			END

			IF EXISTS (SELECT * FROM push_device_token WHERE customer_id = @customer_id AND device_token != @device_token)
				UPDATE push_device_token SET active_status = 0 WHERE customer_id = @customer_id
		END

		---------------------Insert into push log-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO [push_device_token_action_log]
			   ([CUSTOMER_ID]
			   ,[WID]
			   ,[device_token]
			   ,[device_type]
			   ,[app_version]
			   ,[customer_action]
			   ,[created_at]
			   ,[updated_at])
		 VALUES
			   (@customer_id
			   ,@WID
			   ,@device_token
			   ,@device_id
			   ,@app_version
			   ,@customer_action
			   ,(SELECT TODAY FROM VW_CURRENT_SG_TIME)
			   ,(SELECT TODAY FROM VW_CURRENT_SG_TIME))


		-----------------------Insert or update device token---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		IF EXISTS(SELECT * FROM push_device_token WHERE device_token = @device_token AND customer_id IS NULL)
		BEGIN

			UPDATE push_device_token set WID = @WID, updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME), active_status = @active_status, customer_id = @customer_id, app_version = @app_version
			WHERE customer_id IS NULL AND device_token = @device_token;

			GOTO Check_Hit_5Token

			return;
		END

		IF NOT EXISTS (SELECT * FROM push_device_token WHERE device_token = @device_token AND customer_id = @customer_id)
		BEGIN

			IF @customer_id IS NOT NULL AND EXISTS (SELECT * FROM push_device_token WHERE customer_id IS NULL AND device_token = @device_token)
			BEGIN

				UPDATE push_device_token set WID = @WID, updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME), active_status = @active_status, customer_id = @customer_id, app_version = @app_version
				WHERE customer_id IS NULL AND device_token = @device_token;

				GOTO Check_Hit_5Token

				return;
			END

			IF @customer_id IS NULL AND EXISTS (SELECT * FROM push_device_token WHERE customer_id IS NOT NULL AND device_token = @device_token)
			BEGIN

				UPDATE push_device_token set updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME), active_status = @active_status, app_version = @app_version
				WHERE device_token = @device_token AND customer_id = @customer_id;

				return;
			END

			IF NOT EXISTS(SELECT * FROM push_device_token WHERE customer_id IS NOT NULL AND device_token = @device_token AND customer_id != @customer_id)
			BEGIN

				INSERT INTO push_device_token
				([device_token]
				,[customer_id]
				,[WID]
				,[device_type]
				,[app_version]
				,[active_status]
				,[created_at]
				,[updated_at])
				VALUES
				(@device_token,@customer_id,@WID,@device_id,@app_version, @active_status,(SELECT TODAY FROM VW_CURRENT_SG_TIME),(SELECT TODAY FROM VW_CURRENT_SG_TIME))

				GOTO Check_Hit_5Token

				return;
			END

		END
		ELSE
		BEGIN
			
			UPDATE push_device_token set updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME), active_status = @active_status, app_version = @app_version
			WHERE device_token = @device_token AND customer_id = @customer_id;

			return;

		END	


		-----------------------Check customer login on same device or not--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		IF @customer_id IS NOT NULL
		BEGIN
			IF (SELECT COUNT(*) FROM push_device_token WHERE customer_id IS NOT NULL AND device_token = @device_token) >= 1
			BEGIN

				DECLARE @reason_primary VARCHAR(50);
				DECLARE @reason VARCHAR(50);
				DECLARE @primary_customer_id VARCHAR(50);
				SET @primary_customer_id = (SELECT TOP 1 customer_id FROM push_device_token WHERE customer_id IS NOT NULL AND device_token = @device_token)

				IF (@primary_customer_id IS NOT NULL AND @customer_id != @primary_customer_id)
				BEGIN

					----Lock customer-------------------------------------------------------------------------------------------

					SET @reason_primary = 'Token-'+ (SELECT WID FROM customer WHERE customer_id = @primary_customer_id)

					--1)Lock primary account
					IF EXISTS(SELECT * FROM customer WHERE customer_id = @primary_customer_id AND status = 'enable')
					BEGIN
						UPDATE customer SET status = 'disable', updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME) WHERE CUSTOMER_ID = @primary_customer_id

						INSERT INTO System_Log (customer_id,action_status,created_at,reason,device_token,device_type,locked_desc)
						VALUES (@primary_customer_id,'disable',(select today from VW_CURRENT_SG_TIME),'Token_M',@device_token,@device_id,@reason_primary)

						EXEC Create_WINK_Account_Filtering @primary_customer_id,@reason_primary,@admin_user_email_for_lock_account
					END
					ELSE
					BEGIN
						EXEC Create_WINK_Account_Filtering_For_TokenM @primary_customer_id,@reason_primary,@admin_user_email_for_lock_account
					END


					--2)Lock multiple account
					UPDATE customer SET status = 'disable', updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME) WHERE CUSTOMER_ID = @customer_id

					SET @reason = (SELECT WID FROM customer WHERE customer_id = @primary_customer_id)

					INSERT INTO System_Log (customer_id,action_status,created_at,reason,device_token,device_type,locked_desc)
					VALUES (@customer_id,'disable',(select today from VW_CURRENT_SG_TIME),'Token_M',@device_token,@device_id,@reason)

					EXEC Create_WINK_Account_Filtering @customer_id,@reason,@admin_user_email_for_lock_account

				END
			END

			RETURN;
		END

		Check_Hit_5Token:
		BEGIN
			IF @customer_id IS NOT NULL
			BEGIN
				IF EXISTS(SELECT * FROM customer WHERE customer_id = @customer_id AND status = 'enable')
				BEGIN
					IF (SELECT COUNT(DISTINCT device_token) from push_device_token where customer_id = @customer_id) >= @token_count
					BEGIN

						--account has been locked before with the reason 'Token M'
						IF EXISTS (SELECT * FROM System_Log WHERE locked_desc = @multiple_token AND CUSTOMER_ID = @customer_id)
						BEGIN
							DECLARE @last_locked_datetime DATETIME,@MIN_DATE DATETIME, @MAX_DATE DATETIME

							SET @last_locked_datetime = (select max(created_at) from system_log where customer_id = @customer_id and locked_desc = @multiple_token)

							IF (select count(distinct device_token) from push_device_token where customer_id = @customer_id AND created_at > @last_locked_datetime) >= @token_count
							BEGIN
								SET @MIN_DATE = (SELECT MIN(created_at) FROM push_device_token WHERE CUSTOMER_ID = @customer_id AND created_at > @last_locked_datetime)
								SET @MAX_DATE = (SELECT MAX(created_at) FROM push_device_token WHERE CUSTOMER_ID = @customer_id)

								--if it is between 30 days
								IF (SELECT DATEDIFF(DAY,@MIN_DATE,@MAX_DATE +1)) <=@total_days
								BEGIN		
									UPDATE customer SET status = 'disable', updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME) WHERE CUSTOMER_ID = @customer_id

									INSERT INTO System_Log (customer_id,action_status,created_at,reason,device_token,device_type,locked_desc)
									VALUES (@customer_id,'disable',(select today from VW_CURRENT_SG_TIME),'multipleinstalls',@device_token,@device_id,@multiple_token)

									EXEC Create_WINK_Account_Filtering @customer_id,@multiple_token,@admin_user_email_for_lock_account

									return;
								END
							END

						END

						--account has not been locked before with the reason 'Token M'
						ELSE
						BEGIN
							--if it is between 30 days
							IF (SELECT DATEDIFF(DAY,MIN(created_at),MAX(created_at) +1) FROM push_device_token WHERE CUSTOMER_ID = @customer_id) <=@total_days
							BEGIN
								
								UPDATE customer SET status = 'disable', updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME) WHERE CUSTOMER_ID = @customer_id

								INSERT INTO System_Log (customer_id,action_status,created_at,reason,device_token,device_type,locked_desc)
								VALUES (@customer_id,'disable',(select today from VW_CURRENT_SG_TIME),'multipleinstalls',@device_token,@device_id,@multiple_token)

								EXEC Create_WINK_Account_Filtering @customer_id,@multiple_token,@admin_user_email_for_lock_account

								return;

							END
						END

					END
				END
			END

		END
	END	
END		