CREATE PROCEDURE [dbo].[Create_Push_Notification_Log]
(
	@admin_email varchar(50),
	@push_id int,
	@action_type varchar(10),
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

		--1) Get Log ID
		Set @log_id = (select top 1 admin_log.id from admin_log where admin_log.user_id = (select admin_user.admin_user_id from admin_user where admin_user.email = @admin_email) 
					 order by admin_log.id desc)
		select @admin_username = (admin_user.first_name+' '+ admin_user.last_name) from admin_user where admin_user.email = @admin_email


		update admin_log set action_count = ISNULL(action_count,0)+1 where admin_log.id =@log_id


		if(@action_type ='New') 
		BEGIN 
			--1) SET Link_url 
			Set @link_url = 'adminactiondetail/pushnotificationdetail'

			--2) Add Action 
			insert into action_log
			(log_id,action_object,action_table_name,
			action_time,action_type,admin_user_email,admin_user_name,link_url)
			values (@log_id,'Push Notifications','push_log',
			@current_date,@action_type,@admin_email,@admin_username,@link_url)
	
			--3) Get Action ID
			 Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc)	
	
			--4) Add Old Data Log 
			INSERT INTO [winkwink].[dbo].push_olddata_log
			(
				action_id,
				push_id,
				notification_message,
				notification_title,
				created_at,
				updated_at
			)
           
			select      
			@action_id,
			@push_id,
			notification_message,
			notification_title,
			@current_date,
			@current_date
			from push_notification where id = @push_id      
		END         

		Set @result = 1
		return

	END TRY
	BEGIN CATCH
		Delete from push_notification where id = @push_id
		Set @result =2
		return 
	END CATCH
END