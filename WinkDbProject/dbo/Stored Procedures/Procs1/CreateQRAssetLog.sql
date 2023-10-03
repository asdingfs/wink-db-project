CREATE PROCEDURE  [dbo].[CreateQRAssetLog] 
(
     @asset_type_management_id int,
	 @special_campaign varchar(10),
	 @scan_value int,
	 @interval decimal(10, 2),
	 @scan_startdate datetime,
	 @scan_enddate datetime,
	 @wink_asset_category varchar(10),
     @admin_email varchar(100),
     @action_object varchar(10),
     @action_type varchar(10),
     @result int output
)
AS
BEGIN 
	Declare @current_datetime datetime
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime OUTPUT
	Declare @log_id int 
	Declare @admin_username varchar(10)
	Declare @action_id int
	Declare @campaign_status varchar(10)
	Declare @link_url varchar(50)
	BEGIN TRY
		IF(@asset_type_management_id is not null and @asset_type_management_id !=0 and @admin_email !='' and @admin_email is not null)
		BEGIN
			-- Get Log ID
			Set @log_id = (select top 1 admin_log.id from admin_log where admin_log.user_id = (select admin_user.admin_user_id from admin_user where admin_user.email = @admin_email) 
						 order by admin_log.id desc)
			select @admin_username = (admin_user.first_name+' '+ admin_user.last_name) from admin_user where admin_user.email = @admin_email

			update admin_log set action_count = ISNULL(action_count,0)+1 where admin_log.id =@log_id;


			--IF(@scan_startdate IS NULL)
			--BEGIN
			--	SET @scan_startdate = '';
			--END
			--IF(@scan_enddate IS NULL)
			--BEGIN
			--	SET @scan_enddate = '';
			--END
			IF(@wink_asset_category IS NULL)
			BEGIN
				SET @wink_asset_category = '';
			END
			-- Check action type
			--- Edit Action 
			IF(@action_type ='Edit')
			BEGIN
				-- SET Link_url 
				Set @link_url = 'adminactiondetail/qrassetedit'
				-- Add Action 
				insert into action_log
				(log_id,action_object,action_table_name,
				action_time,action_type,admin_user_email,admin_user_name,link_url)
				values (@log_id,@action_object,'qr_asset_log',
				@current_datetime,@action_type,@admin_email,@admin_username,@link_url)
	
				-- Get Action ID
				Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc)

				-- Add Old Data Log before modify
				INSERT INTO [dbo].[qr_asset_olddata_log]
			   ([action_id]
			   ,[asset_type_management_id]
			   ,[old_special_campaign]
			   ,[old_scan_value]
			   ,[old_interval]
			   ,[old_scan_startdate]
			   ,[old_scan_enddate]
			   ,[old_wink_asset_category]
			   ,[created_at])
				VALUES
				(
				@action_id,
				@asset_type_management_id,
				@special_campaign,
				@scan_value,
				@interval,
				@scan_startdate,
				@scan_enddate,
				@wink_asset_category,
				@current_datetime
				)
           
				-- Add New Data Log 
				INSERT INTO [dbo].[qr_asset_newdata_log]
			   ([action_id]
			   ,[asset_type_management_id]
			   ,[new_special_campaign]
			   ,[new_scan_value]
			   ,[new_interval]
			   ,[new_scan_startdate]
			   ,[new_scan_enddate]
			   ,[new_wink_asset_category]
			   ,[created_at])
				select  @action_id,
				[asset_type_management_id]
				,[special_campaign]
				,[scan_value]
				,[scan_interval]
				,[scan_start_date]
				,[scan_end_date]
				,[wink_asset_category]
				,@current_datetime
				from asset_type_management where asset_type_management.asset_type_management_id =@asset_type_management_id
			END
		--ELSE 
		--BEGIN 
		---- SET Link_url 
		--	Set @link_url = 'adminactiondetail/campaigndetail'
		---- Add Action 
		--	insert into action_log
		--	(log_id,action_object,action_table_name,
		--	action_time,action_type,admin_user_email,admin_user_name,link_url)
		--	values (@log_id,'Campaign','campaign_log',
		--	@current_date,@action_type,@admin_email,@admin_username,@link_url)
	
		--	-- Get Action ID

		--	 Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc)	
	
	
		-- -- Add Old Data Log 
		--			INSERT INTO [winkwink].[dbo].campaign_olddata_log
		--		   (
		--			[action_id]
		--		   ,[campaign_id]
		--		   ,[old_merchant_id]
		--		   ,[old_campaign_name]
		--		   ,[old_campaign_code]
		--		   ,[old_campaign_amount]
		--		   ,[old_sales_code]
		--		   ,[old_sales_commission]
		--		   ,[old_total_winks]
		--		   ,[old_total_winks_amount]
		--		   ,[old_agency]
		--		   ,[old_created_at]
		--		   ,[old_updated_at]
		--		   ,[old_cents_per_wink]
		--		   ,[old_percent_for_wink]
		--		   ,[old_campaign_start_date]
		--		   ,[old_campaign_end_date]
		--		   ,[old_agency_name]
		--		   ,[old_wink_purchase_only]
		--		   ,[old_wink_purchase_status]
		--		   ,[old_campaign_status])
           
		--select      @action_id,
		--			[campaign_id]
		--		   ,[merchant_id]
		--		   ,[campaign_name]
		--		   ,[campaign_code]
		--		   ,[campaign_amount]
		--		   ,[sales_code]
		--		   ,[sales_commission]
		--		   ,[total_winks]
		--		   ,[total_winks_amount]
		--		   ,[agency]
		--		   ,[created_at]
		--		   ,[updated_at]
		--		   ,[cents_per_wink]
		--		   ,[percent_for_wink]
		--		   ,[campaign_start_date]
		--		   ,[campaign_end_date]
		--		   ,[agency_name]
		--		   ,[wink_purchase_only]
		--		   ,[wink_purchase_status]
		--		   ,[campaign_status]
           
		--		   from campaign where campaign.campaign_id =@campaign_id      
        
           
		-- END         

		END

		Set @result = 1

	END TRY
	BEGIN CATCH
		Set @result =2
		return 
	END CATCH

END



