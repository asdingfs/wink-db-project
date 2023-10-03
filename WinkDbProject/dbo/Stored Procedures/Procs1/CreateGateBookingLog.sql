CREATE PROCEDURE  [dbo].[CreateGateBookingLog] 
(
	@bookingId int,
	@winkGateCampaignId int,
	@gate_id varchar(100),
	@points int,
	@interval int,
	@push_header varchar(250),
	@push_msg varchar(500),
	@linktTo int,
	@pin_desc varchar(250),
	@pin_img varchar(1000),
	@bannerImg varchar(1000),
	@bannerUrl varchar(1000),
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
		IF(@winkGateCampaignId is not null and @winkGateCampaignId !=0 and @admin_email !='' and @admin_email is not null)
		BEGIN
			DECLARE @actionTableName varchar(100) = 'gate_booking_log';
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

			DECLARE @campaignName varchar(500);
			SELECT @campaignName = c.campaign_name
			FROM wink_gate_campaign as w, campaign as c
			where w.id = @winkGateCampaignId
			AND w.campaign_id = c.campaign_id;

			DECLARE @newBannerImg varchar(1000),
			@newBannerUrl varchar(1000);
			SELECT @newBannerImg = image_url, @newBannerUrl = hyperlink 
			FROM wink_gate_banner
			where wink_gate_booking_id = @bookingId;

			DECLARE @newPinImg varchar(1000),
			@newPinDesc varchar(250);
			SELECT @newPinImg = image_url, @newPinDesc = [description]
			from wink_gate_pin 
			where wink_gate_booking_id = @bookingId

			-- Check action type
			--- Edit Action 
			IF(@action_type ='Edit')
			Begin
				-- SET Link_url 
				Set @link_url = 'adminactiondetail/gatebookingedit';
				-- Add Action 
				insert into action_log
				(log_id,action_object,action_table_name,
				action_time,action_type,admin_user_email,admin_user_name,link_url)
				values (@log_id,@action_object,@actionTableName,
				@CURRENT_DATETIME,@action_type,@admin_email,@admin_username,@link_url);
	
				-- Get Action ID
				Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc);

				-- Add Old Data Log before modify
				INSERT INTO [dbo].[gate_booking_old_data_log]
						   ([action_id]
						   ,[wink_gate_campaign_id]
						   ,[campaign_name]
						   ,[old_gate_id]
						   ,[old_points]
						   ,[old_interval]
						   ,[old_push_header]
						   ,[old_push_msg]
						   ,[old_link_to]
						   ,[old_pin_desc]
						   ,[old_pin_img]
						   ,[old_banner_img]
						   ,[old_banner_hyperlink])
					 VALUES
						   (@action_id
						   ,@winkGateCampaignId
						   ,@campaignName
						   ,@gate_id
						   ,@points
						   ,@interval
						   ,@push_header
						   ,@push_msg
						   ,@linktTo
						   ,@pin_desc
						   ,@pin_img
						   ,@bannerImg
						   ,@bannerUrl);
           
				

				-- Add New Data Log 
				INSERT INTO [dbo].[gate_booking_new_data_log]
				   ([action_id]
				   ,[wink_gate_campaign_id]
				   ,[campaign_name]
				   ,[new_gate_id]
				   ,[new_points]
				   ,[new_interval]
				   ,[new_push_header]
				   ,[new_push_msg]
				   ,[new_link_to]
				   ,[new_pin_desc]
				   ,[new_pin_img]
				   ,[new_banner_img]
				   ,[new_banner_hyperlink])
			
				SELECT @action_id
					,@winkGateCampaignId
					,@campaignName
					,@gate_id
					,b.[points]
					,b.[interval]
					,b.[pushHeader]
					,b.[pushMsg]
					,b.[linkTo]
					,@newPinDesc
					,@newPinImg
					,@newBannerImg
					,@newBannerUrl
				FROM [winkwink].[dbo].[wink_gate_booking] as b
				WHERE b.id = @bookingId;
			

			END
			ELSE 
			BEGIN 
				-- SET Link_url 
				SET @link_url = 'adminactiondetail/gatebooking';
				-- Add Action 
				insert into action_log
				(log_id,action_object,action_table_name,
				action_time,action_type,admin_user_email,admin_user_name,link_url)
				values (@log_id,@action_object,@actionTableName,
				@CURRENT_DATETIME,@action_type,@admin_email,@admin_username,@link_url);
	
				-- Get Action ID
				SET @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc);	
	
				-- Add Old Data Log 
				INSERT INTO [dbo].[gate_booking_old_data_log]
						   ([action_id]
						   ,[wink_gate_campaign_id]
						   ,[campaign_name]
						   ,[old_gate_id]
						   ,[old_points]
						   ,[old_interval]
						   ,[old_push_header]
						   ,[old_push_msg]
						   ,[old_link_to]
						   ,[old_pin_desc]
						   ,[old_pin_img]
						   ,[old_banner_img]
						   ,[old_banner_hyperlink])
           
				SELECT @action_id
					,[wink_gate_campaign_id]
					,@campaignName
					,@gate_id
					,[points]
					,[interval]
					,[pushHeader]
					,[pushMsg]
					,[linkTo]
					,@newPinDesc
					,@newPinImg
					,@newBannerImg
					,@newBannerUrl
				FROM [winkwink].[dbo].[wink_gate_booking]
				where id = @bookingId;
        
			END         
		END

		Set @result = 1;
	END TRY
	BEGIN CATCH
		Set @result =2
		return 
	END CATCH
END



