CREATE PROCEDURE  [dbo].[CreateGateAssetLog] 
(
	@winkGateId int,
	@gate_id varchar(100),
	@desc varchar(250),
	@lat varchar(50),
	@lng varchar(50),
	@range int,
	--@points int,
	--@interval int,
	--@pushHeader varchar(250),
	--@pushMsg varchar(500),
	--@linkTo int,
	--@asset_status int,
	--@pin_img varchar(1000),
	--@bannerImg varchar(1000),
	--@bannerUrl varchar(1000),
	@admin_email varchar(100),
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
		IF(@winkGateId is not null and @winkGateId !=0 and @admin_email !='' and @admin_email is not null)
		BEGIN
			DECLARE @actionTableName varchar(100) = 'gate_asset_log';
			-- Get Log ID
			Set @log_id = 
			(select top 1 admin_log.id 
			from admin_log 
			where admin_log.user_id = 
			(select admin_user.admin_user_id from admin_user where admin_user.email = @admin_email) 
			order by admin_log.id desc);

			select @admin_username = (admin_user.first_name+' '+ admin_user.last_name) 
			from admin_user 
			where admin_user.email = @admin_email;

			update admin_log 
			set action_count = ISNULL(action_count,0)+1 
			where admin_log.id =@log_id;

			-- Check action type
			--- Edit Action 
			IF(@action_type ='Edit')
			Begin
				-- SET Link_url 
				Set @link_url = 'adminactiondetail/gateassetedit';
				-- Add Action 
				insert into action_log
				(log_id,action_object,action_table_name,
				action_time,action_type,admin_user_email,admin_user_name,link_url)
				values (@log_id,@action_object,@actionTableName,
				@CURRENT_DATETIME,@action_type,@admin_email,@admin_username,@link_url);
	
				-- Get Action ID
				Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc);

				-- Add Old Data Log before modify
				INSERT INTO [dbo].[gate_asset_old_data_log]
						   ([action_id]
						   ,[wink_gate_id]
						   ,[old_gate_id]
						   ,[old_desc]
						   ,[old_lat]
						   ,[old_lng]
						   ,[old_range]
						   --,[old_points]
						   --,[old_interval]
						   --,[old_push_header]
						   --,[old_push_msg]
						   --,[old_link_to]
						   --,[old_status]
						   --,[old_pin_img]
						   --,[old_banner_img]
						   --,[old_banner_url]
						   )
					 VALUES
						   (@action_id
						   ,@winkGateId
						   ,@gate_id
						   ,@desc
						   ,@lat
						   ,@lng
						   ,@range
						   --,@points
						   --,@interval
						   --,@pushHeader
						   --,@pushMsg
						   --,@linkTo
						   --,@asset_status
						   --,@pin_img
						   --,@bannerImg
						   --,@bannerUrl
						   );
           print('here old data')
				-- Add New Data Log 
				INSERT INTO [dbo].[gate_asset_new_data_log]
				   ([action_id]
				   ,[wink_gate_id]
				   ,[new_gate_id]
				   ,[new_desc]
				   ,[new_lat]
				   ,[new_lng]
				   ,[new_range]
				   --,[new_points]
				   --,[new_interval]
				   --,[new_push_header]
				   --,[new_push_msg]
				   --,[new_link_to]
				   --,[new_status]
				   --,[new_pin_img]
				   --,[new_banner_img]
				   --,[new_banner_url]
				   )
			
				SELECT @action_id
					,[id]
					,[gate_id]
					,[description]
					,[latitude]
					,[longitude]
					,[range]
					--,[points]
					--,[interval]
					--,[pushHeader]
					--,[pushMsg]
					--,[linkTo]
					--,[status]
					--,[pin_img]
					--,[banner_img]
					--,[banner_hyperlink]
				FROM [winkwink].[dbo].[wink_gate_asset]
				where id = @winkGateId;
			print('here new data')

			END
			ELSE 
			BEGIN 
				-- SET Link_url 
				SET @link_url = 'adminactiondetail/gateasset';
				-- Add Action 
				insert into action_log
				(log_id,action_object,action_table_name,
				action_time,action_type,admin_user_email,admin_user_name,link_url)
				values (@log_id,@action_object,@actionTableName,
				@CURRENT_DATETIME,@action_type,@admin_email,@admin_username,@link_url);
	
				-- Get Action ID
				SET @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc);	
	
				-- Add Old Data Log 
				INSERT INTO [dbo].[gate_asset_old_data_log]
						   ([action_id]
						   ,[wink_gate_id]
						   ,[old_gate_id]
						   ,[old_desc]
						   ,[old_lat]
						   ,[old_lng]
						   ,[old_range]
						   --,[old_points]
						   --,[old_interval]
						   --,[old_push_header]
						   --,[old_push_msg]
						   --,[old_link_to]
						   --,[old_status]
						   --,[old_pin_img]
						   --,[old_banner_img]
						   --,[old_banner_url]
						   )
           
				SELECT @action_id
					,[id]
					,[gate_id]
					,[description]
					,[latitude]
					,[longitude]
					,[range]
					--,[points]
					--,[interval]
					--,[pushHeader]
					--,[pushMsg]
					--,[linkTo]
					--,[status]
					--,[pin_img]
					--,[banner_img]
					--,[banner_hyperlink]
				FROM [winkwink].[dbo].[wink_gate_asset]
				where id = @winkGateId;
        
			END         
		END

		Set @result = 1;
	END TRY
	BEGIN CATCH
		Set @result =2
		return 
	END CATCH
END



