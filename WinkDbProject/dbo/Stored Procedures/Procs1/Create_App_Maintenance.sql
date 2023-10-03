CREATE PROCEDURE [dbo].[Create_App_Maintenance]
(	@action varchar(50),
	@adminEmail varchar(50)
)
AS
BEGIN
	--check admin_email is null or not
	IF(@adminEmail = '' OR @adminEmail is null)
	BEGIN
		SELECT '0' as response_code,'You are not authorised to perform this function' as response_message
		RETURN
	END

	IF NOT EXISTS(SELECT * FROM admin_user where email = @adminEmail)
	BEGIN
		SELECT '0' as response_code,'You are not authorised to perform this function' as response_message
		RETURN
	END

	IF(
		(SELECT TOP(1) [action]
		FROM app_maintenance
		ORDER BY created_at desc)
		like @action
	)
	BEGIN
		IF(@action like 'on')
		BEGIN
			SELECT '0' as response_code,'You have already turned on the app maintenance page' as response_message
			RETURN
		END
		ELSE IF(@action like 'off')
		BEGIN
			SELECT '0' as response_code,'You have already turned off the app maintenance page' as response_message
			RETURN
		END
	END

	DECLARE @CURRENT_DATETIME datetime;
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME output
	INSERT INTO [dbo].[app_maintenance]
           ([action]
           ,[created_at])
     VALUES
           (@action
           ,@CURRENT_DATETIME);

	DECLARE @maxID int
	DECLARE @action_id int
	SET @maxID = (SELECT @@IDENTITY);
	IF (@maxID > 0)
    BEGIN
		SET @action_id  =  (SELECT SCOPE_IDENTITY());

		if(@action_id is null or @action_id = 0)
		BEGIN
			Delete from [dbo].[app_maintenance] where id = @action_id;
			SELECT '0' as response_code,'Please try again later' as response_message
			RETURN
		END

		---Start Create Log 
		Declare @result int

		IF(@action like 'on')
		BEGIN
			---Call Push Log Storeprocedure Function 
			EXEC Create_App_Maintenance_Log
			@adminEmail,@action_id,'On',@result output;
		END
		ELSE
		BEGIN
			---Call Push Log Storeprocedure Function 
			EXEC Create_App_Maintenance_Log
			@adminEmail,@action_id,'Off',@result output;
		END
		
			
		--print (@result)
		if(@result=2)
		BEGIN
			Delete from [dbo].[app_maintenance] where id = @action_id
			SELECT '0' as response_code,'Please try again later' as response_message
			RETURN
		END
		ELSE
		BEGIN
			IF(@action like 'on')
			BEGIN
				SELECT '1' as response_code,'You have successfully turned on the app maintenance page' as response_message
				RETURN
			END
			ELSE IF(@action like 'off')
			BEGIN
				SELECT '1' as response_code,'You have successfully turned off the app maintenance page' as response_message
				RETURN
			END
		END
	END
	ELSE
	BEGIN
		SELECT '0' as response_code,'Please try again later' as response_message
		RETURN
	END
END