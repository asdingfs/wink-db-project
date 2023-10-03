CREATE PROCEDURE  [dbo].[CreateGateDelinkLog] 
(
	@bookingId int,
	@winkGateCampaignId int,
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
		IF(@bookingId is not null and @bookingId !=0 and @admin_email !='' and @admin_email is not null)
		BEGIN
			DECLARE @actionTableName varchar(100) = 'gate_delink_log';
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

			DECLARE
			@points int,
			@interval int,
			@push_header varchar(250),
			@push_msg varchar(500),
			@linktTo int,
			@campaignName varchar(500),
			@assetId int,
			@gate_id varchar(100),
			@pin_desc varchar(250),
			@pin_img varchar(1000),
			@bannerImg varchar(1000),
			@bannerUrl varchar(1000);

			SELECT @assetId = wink_gate_asset_id,
			@points = points, @interval = interval, @push_header = pushHeader, @push_msg = pushMsg, @linktTo = linkTo
			FROM wink_gate_booking
			WHERE id = @bookingId;

			SELECT @gate_id = gate_id
			FROM wink_gate_asset
			WHERE id = @assetId;

			SELECT @campaignName = c.campaign_name
			FROM wink_gate_campaign as w, campaign as c
			where w.id = @winkGateCampaignId
			AND w.campaign_id = c.campaign_id;

			SELECT @bannerImg = image_url, @bannerUrl = hyperlink 
			FROM wink_gate_banner
			where wink_gate_booking_id = @bookingId;

			SELECT @pin_img = image_url, @pin_desc = [description]
			from wink_gate_pin 
			where wink_gate_booking_id = @bookingId;

		
			-- SET Link_url 
			SET @link_url = 'adminactiondetail/gatedelink';
			-- Add Action 
			insert into action_log
			(log_id,action_object,action_table_name,
			action_time,action_type,admin_user_email,admin_user_name,link_url)
			values (@log_id,@action_object,@actionTableName,
			@CURRENT_DATETIME,@action_type,@admin_email,@admin_username,@link_url);
	
			-- Get Action ID
			SET @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc);	
	
			-- Add Data Log 
			INSERT INTO [dbo].[gate_booking_delink_data_log]
				   ([action_id]
				   ,[wink_gate_campaign_id]
				   ,[campaign_name]
				   ,[gate_id]
				   ,[points]
				   ,[interval]
				   ,[push_header]
				   ,[push_msg]
				   ,[link_to]
				   ,[pin_desc]
				   ,[pin_img]
				   ,[banner_img]
				   ,[banner_hyperlink])
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
		END
		Set @result = 1;
	END TRY
	BEGIN CATCH
		Set @result =2;
		return 
	END CATCH
END



