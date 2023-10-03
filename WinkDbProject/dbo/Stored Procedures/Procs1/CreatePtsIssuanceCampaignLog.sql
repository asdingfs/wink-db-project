CREATE PROCEDURE  [dbo].[CreatePtsIssuanceCampaignLog] 
(
	@campaignId int,
	@campaignName varchar(250),
	@points int,
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
		IF((@campaignId is not null and @campaignId !=0) 
		and (@campaignName is not null and @campaignName !='')
		and (@admin_email !='' and @admin_email is not null))
		BEGIN
			DECLARE @actionTableName varchar(100) = 'campaign_pts_issuance_log';
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
			IF(@action_type ='New')
			Begin
				-- SET Link_url 
				Set @link_url = 'adminactiondetail/ptsissuancecampaign';
				-- Add Action 
				insert into action_log
				(log_id,action_object,action_table_name,
				action_time,action_type,admin_user_email,admin_user_name,link_url)
				values (@log_id,@action_object,@actionTableName,
				@CURRENT_DATETIME,@action_type,@admin_email,@admin_username,@link_url);
	
				-- Get Action ID
				Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc);

				-- Add Old Data Log 
				INSERT INTO [dbo].[pts_issuance_campaign_old_data_log]
					   ([action_id]
					   ,[campaign_id]
					   ,[old_campaign_name]
					   ,[old_points])
				 VALUES
					   (@action_id
					   ,@campaignId
					   ,@campaignName
					   ,@points)
			END
		END

		Set @result = 1;
	END TRY
	BEGIN CATCH
		Set @result =2
		return 
	END CATCH
END



