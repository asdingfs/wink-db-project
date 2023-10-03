CREATE PROCEDURE [dbo].[Create_Lock_IP_Log]
(
	@adminEmail varchar(50),
	@ip varchar(50),
	@index int,
	@action_object varchar(100),
	@action_type varchar(10),
	@result int output
)

AS

BEGIN
	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT

	Declare @log_id int 
	Declare @admin_username varchar(10)
	Declare @action_id int
	Declare @link_url varchar(50)

	BEGIN TRY
		DECLARE @actionTableName varchar(100) = 'mousetrap_ip_locking_log';
		
		-- Get Log ID
		Set @log_id = 
		(select top 1 admin_log.id 
		from admin_log 
		where admin_log.user_id = 
		(select admin_user.admin_user_id from admin_user where admin_user.email = @adminEmail) 
		order by admin_log.id desc);

		select @admin_username = (admin_user.first_name+' '+ admin_user.last_name) 
		from admin_user 
		where admin_user.email = @adminEmail;

		IF(@index = 1)
		BEGIN
			update admin_log 
			set action_count = ISNULL(action_count,0)+1 
			where admin_log.id =@log_id;
		END


		-- Check action type
		--- Edit Action 
		IF(@action_type ='IP(/32)')
		BEGIN
			-- SET Link_url 
			Set @link_url = 'adminactiondetail/mousetraplog';

			-- Add Action 
			IF(@index = 1)
			BEGIN
				insert into action_log
				(log_id,action_object,action_table_name,
				action_time,action_type,admin_user_email,admin_user_name,link_url)
				values (@log_id,@action_object,@actionTableName,
				@CURRENT_DATETIME,@action_type,@adminEmail,@admin_username,@link_url);
			END

			-- Get Action ID
			Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @adminEmail order by action_id desc);
	
			--4) Add Old Data Log 
			IF(@index = 1)
			BEGIN
				INSERT INTO [dbo].[lock_ip32_log]
					([action_id]
					,[ipList]
					,[createdAt]
					,[updatedAt]
					)
				VALUES
					(@action_id
					,@ip
					,@CURRENT_DATETIME
					,@CURRENT_DATETIME
					);
			END
			ELSE
			BEGIN
				UPDATE [dbo].[lock_ip32_log]
				SET ipList +=(','+@ip), updatedAt = @CURRENT_DATETIME
				WHERE action_id = @action_id;
			END
		END         
		ELSE IF(@action_type ='IP(/16)')
		BEGIN
			-- SET Link_url 
			Set @link_url = 'adminactiondetail/mousetraplog';

			-- Add Action 
			IF(@index = 1)
			BEGIN
				insert into action_log
				(log_id,action_object,action_table_name,
				action_time,action_type,admin_user_email,admin_user_name,link_url)
				values (@log_id,@action_object,@actionTableName,
				@CURRENT_DATETIME,@action_type,@adminEmail,@admin_username,@link_url);
			END

			-- Get Action ID
			Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @adminEmail order by action_id desc);
	
			--4) Add Old Data Log 
			IF(@index = 1)
			BEGIN
				INSERT INTO [dbo].[lock_ip16_log]
					([action_id]
					,[ipList]
					,[createdAt]
					,[updatedAt]
					)
				VALUES
					(@action_id
					,@ip
					,@CURRENT_DATETIME
					,@CURRENT_DATETIME
					);
			END
			ELSE
			BEGIN
				UPDATE [dbo].[lock_ip16_log]
				SET ipList +=(','+@ip), updatedAt = @CURRENT_DATETIME
				WHERE action_id = @action_id;
			END
		END
		Set @result = 1;
		return

	END TRY
	BEGIN CATCH
		Set @result =2
		return 
	END CATCH
END