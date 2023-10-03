CREATE PROCEDURE [dbo].[Create_News_Log]
(
	@admin_email varchar(50),
	@news_id int,
	@news_title varchar(100),
	@news varchar(2000),
	@news_status varchar(10),
	@action_type varchar(10),
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
		DECLARE @actionTableName varchar(100) = 'news_log';
		--1) Get Log ID
		Set @log_id = (select top 1 admin_log.id from admin_log where admin_log.[user_id] = (select admin_user.admin_user_id from admin_user where admin_user.email = @admin_email) 
					 order by admin_log.id desc);
		select @admin_username = (admin_user.first_name+' '+ admin_user.last_name) from admin_user where admin_user.email = @admin_email;

		update admin_log set action_count = ISNULL(action_count,0)+1 where admin_log.id =@log_id;


		IF(@action_type ='New') 
		BEGIN 
			--1) SET Link_url 
			Set @link_url = 'adminactiondetail/newsdetail'

			--2) Add Action 
			insert into action_log
			(log_id,action_object,action_table_name,
			action_time,action_type,admin_user_email,admin_user_name,link_url)
			values (@log_id,@action_object,@actionTableName,
			@current_date,@action_type,@admin_email,@admin_username,@link_url)
	
			--3) Get Action ID
			 Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc)	
	
			--4) Add Old Data Log 
			INSERT INTO [winkwink].[dbo].news_olddata_log
			(
				action_id,
				news_id,
				title,
				news,
				news_status,
				created_at
			)
			select      
			@action_id,
			@news_id,
			title,
			news,
			news_status,
			@current_date
			from wink_news where id = @news_id      
		END         
		ELSE IF(@action_type ='Edit')
		Begin
			-- SET Link_url 
			Set @link_url = 'adminactiondetail/newsedit';
			-- Add Action 
			insert into action_log
			(log_id,action_object,action_table_name,
			action_time,action_type,admin_user_email,admin_user_name,link_url)
			values (@log_id,@action_object,@actionTableName,
			@current_date,@action_type,@admin_email,@admin_username,@link_url);
	
			-- Get Action ID
			Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc);

			-- Add Old Data Log before modify
			INSERT INTO [dbo].[news_olddata_log]
           ([action_id]
           ,[news_id]
           ,[title]
           ,[news]
           ,[news_status]
           ,[created_at])
			VALUES
			(@action_id
			,@news_id
			,@news_title
			,@news
			,@news_status
			,@current_date
			);
			print('here old data')
			-- Add New Data Log 
			INSERT INTO [dbo].[news_newdata_log]
			([action_id]
           ,[new_news_id]
           ,[new_title]
           ,[new_news]
           ,[new_news_status]
           ,[created_at])
			
			SELECT @action_id
			,[id]
			,[title]
			,[news]
			,[news_status]
			,@current_date
			from wink_news where id = @news_id      
			print('here new data')

		END
		Set @result = 1;
		return

	END TRY
	BEGIN CATCH
		Delete from wink_news where id = @news_id
		Set @result =2
		return 
	END CATCH
END