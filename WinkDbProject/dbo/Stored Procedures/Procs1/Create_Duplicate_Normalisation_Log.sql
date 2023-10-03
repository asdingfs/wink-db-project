CREATE PROCEDURE [dbo].[Create_Duplicate_Normalisation_Log]
(
	@adminEmail varchar(50),
	@targetDate datetime,
	@action_object varchar(100),
	@result int output
)

AS

BEGIN
	Declare @current_date datetime
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
	Declare @log_id int 
	Declare @admin_username varchar(50)
	Declare @action_id int
	Declare @link_url varchar(50)

	BEGIN TRY
		DECLARE @actionTableName varchar(100) = 'normalisation_log';
		DECLARE @actionType varchar(50) = 'Normalisation';
		--1) Get Log ID
		Set @log_id = (select top 1 admin_log.id from admin_log where admin_log.[user_id] = (select admin_user.admin_user_id from admin_user where admin_user.email = @adminEmail) 
					 order by admin_log.id desc);
		select @admin_username = (admin_user.first_name+' '+ admin_user.last_name) from admin_user where admin_user.email = @adminEmail;

		update admin_log set action_count = ISNULL(action_count,0)+1 where admin_log.id =@log_id;


		IF(@action_object like 'Duplicate QR Scans') 
		BEGIN 
			--1) SET Link_url 
			Set @link_url = 'adminactiondetail/qrnormalisation'

			--2) Add Action 
			insert into action_log
			(log_id,action_object,action_table_name,
			action_time,action_type,admin_user_email,admin_user_name,link_url)
			values (@log_id,@action_object,@actionTableName,
			@current_date,@actionType,@adminEmail,@admin_username,@link_url)
	
			--3) Get Action ID
			 Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @adminEmail order by action_id desc)	
	
			--4) Add Old Data Log 
			INSERT INTO [dbo].[duplicate_normalisation_log]
			   ([action_id]
			   ,[targetDate]
			   ,[createdAt])
			VALUES(     
				@action_id,
				@targetDate,
				@current_date)
		END         
		
		Set @result = 1;
		return

	END TRY
	BEGIN CATCH
		Set @result =2
		return 
	END CATCH
END