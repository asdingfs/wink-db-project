CREATE PROCEDURE  [dbo].[CreateCampaigLog_01] 
(
     @campaign_id int,
	 @merchant_id int,
	 @campaign_name varchar(255),
     @campaign_code varchar(255),
	 @campaign_amount Decimal(10,2),
	 @cents_per_wink Decimal(10,2),
	 @percent_for_wink Decimal(10,2),
     @sales_code varchar(255),
	 @sales_commission Decimal(10,2),
	 @total_winks int,
	 @total_winks_amount Decimal(10,2),
	 @agency bit,
	 @agency_name varchar(255),
	 @wink_purchase_only int ,
	 @wink_purchase_status varchar(50),
	 @campaign_start_date varchar(50),
	 @campaign_end_date varchar(50),
	 @updated_at DateTime,
     @admin_email varchar(100),
     @action_object varchar(10),
     @action_type varchar(10),
	 @scan_limit int,
     @result int output
    
)
AS
BEGIN 
Declare @current_date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
Declare @log_id int 
Declare @admin_username varchar(10)
Declare @action_id int
Declare @campaign_status varchar(10)
Declare @link_url varchar(50)
BEGIN TRY
if(@campaign_id is not null and @campaign_id !=0 and @admin_email !='' and @admin_email is not null)

BEGIN
-- Get Log ID
	Set @log_id = (select top 1 admin_log.id from admin_log where admin_log.user_id = (select admin_user.admin_user_id from admin_user where admin_user.email = @admin_email) 
                 order by admin_log.id desc)
    select @admin_username = (admin_user.first_name+' '+ admin_user.last_name) from admin_user where admin_user.email = @admin_email

--IF(@log_id IS NOT NULL and @log_id !='' and @log_id !=0)
-- Update action Count

	update admin_log set action_count = ISNULL(action_count,0)+1 where admin_log.id =@log_id


-- Check action type
--- Edit Action 
if(@action_type ='Edit')
		Begin
    -- SET Link_url 
	Set @link_url = 'adminactiondetail/campaignediteddetail'
-- Add Action 
	insert into action_log
	(log_id,action_object,action_table_name,
	action_time,action_type,admin_user_email,admin_user_name,link_url)
	values (@log_id,'Campaign','campaign_log',
	@current_date,@action_type,@admin_email,@admin_username,@link_url)
	
	-- Get Action ID

	Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc)

	
    -- Add Old Data Log before modify
			INSERT INTO [winkwink].[dbo].campaign_olddata_log
           (
            [action_id]
           ,[campaign_id]
           ,[old_merchant_id]
           ,[old_campaign_name]
           ,[old_campaign_code]
           ,[old_campaign_amount]
           ,[old_sales_code]
           ,[old_sales_commission]
           ,[old_total_winks]
           ,[old_total_winks_amount]
           ,[old_agency]
           ,[old_created_at]
           ,[old_updated_at]
           ,[old_cents_per_wink]
           ,[old_percent_for_wink]
           ,[old_campaign_start_date]
           ,[old_campaign_end_date]
           ,[old_agency_name]
           ,[old_wink_purchase_only]
           ,[old_wink_purchase_status]
           ,[old_campaign_status]
		   ,scan_limit
		   )
           
     VALUES
     
           (
            @action_id,
            @campaign_id,
            @merchant_id
           ,@campaign_name
           ,@campaign_code
           ,@campaign_amount
           ,@sales_code
           ,@sales_commission
           ,@total_winks
           ,@total_winks_amount
           ,@agency
           ,@current_date
           ,@current_date
           ,@cents_per_wink
           ,@percent_for_wink
           ,@campaign_start_date
           ,@campaign_end_date
           ,@agency_name
           ,@wink_purchase_only
           ,@wink_purchase_status
           ,(select campaign.campaign_status from campaign where campaign.campaign_id = @campaign_id)
		   ,@scan_limit
           )
           
 -- Add New Data Log 
			INSERT INTO [winkwink].[dbo].campaign_newdata_log
           (
            [action_id]
           ,[campaign_id]
           ,[new_merchant_id]
           ,[new_campaign_name]
           ,[new_campaign_code]
           ,[new_campaign_amount]
           ,[new_sales_code]
           ,[new_sales_commission]
           ,[new_total_winks]
           ,[new_total_winks_amount]
           ,[new_agency]
           ,[new_created_at]
           ,[new_updated_at]
           ,[new_cents_per_wink]
           ,[new_percent_for_wink]
           ,[new_campaign_start_date]
           ,[new_campaign_end_date]
           ,[new_agency_name]
           ,[new_wink_purchase_only]
           ,[new_wink_purchase_status]
           ,[new_campaign_status]
		   ,scan_limit
		   )
           
		select  @action_id,
            [campaign_id]
           ,[merchant_id]
           ,[campaign_name]
           ,[campaign_code]
           ,[campaign_amount]
           ,[sales_code]
           ,[sales_commission]
           ,[total_winks]
           ,[total_winks_amount]
           ,[agency]
           ,[created_at]
           ,[updated_at]
           ,[cents_per_wink]
           ,[percent_for_wink]
           ,[campaign_start_date]
           ,[campaign_end_date]
           ,[agency_name]
           ,[wink_purchase_only]
           ,[wink_purchase_status]
           ,[campaign_status]
		   ,scan_limit
           
           from campaign where campaign.campaign_id =@campaign_id
              
          
           

END
ELSE 
BEGIN 
-- SET Link_url 
	Set @link_url = 'adminactiondetail/campaigndetail'
-- Add Action 
	insert into action_log
	(log_id,action_object,action_table_name,
	action_time,action_type,admin_user_email,admin_user_name,link_url)
	values (@log_id,'Campaign','campaign_log',
	@current_date,@action_type,@admin_email,@admin_username,@link_url)
	
	-- Get Action ID

     Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc)	
	
	
 -- Add Old Data Log 
			INSERT INTO [winkwink].[dbo].campaign_olddata_log
           (
            [action_id]
           ,[campaign_id]
           ,[old_merchant_id]
           ,[old_campaign_name]
           ,[old_campaign_code]
           ,[old_campaign_amount]
           ,[old_sales_code]
           ,[old_sales_commission]
           ,[old_total_winks]
           ,[old_total_winks_amount]
           ,[old_agency]
           ,[old_created_at]
           ,[old_updated_at]
           ,[old_cents_per_wink]
           ,[old_percent_for_wink]
           ,[old_campaign_start_date]
           ,[old_campaign_end_date]
           ,[old_agency_name]
           ,[old_wink_purchase_only]
           ,[old_wink_purchase_status]
           ,[old_campaign_status]
		   ,scan_limit
		   
		   )
           
select      @action_id,
            [campaign_id]
           ,[merchant_id]
           ,[campaign_name]
           ,[campaign_code]
           ,[campaign_amount]
           ,[sales_code]
           ,[sales_commission]
           ,[total_winks]
           ,[total_winks_amount]
           ,[agency]
           ,[created_at]
           ,[updated_at]
           ,[cents_per_wink]
           ,[percent_for_wink]
           ,[campaign_start_date]
           ,[campaign_end_date]
           ,[agency_name]
           ,[wink_purchase_only]
           ,[wink_purchase_status]
           ,[campaign_status]
		   ,scan_limit
           
           from campaign where campaign.campaign_id =@campaign_id      
        
           
 END         

END

Set @result = 1

END TRY
BEGIN CATCH

Set @result =2
return 
END CATCH

END





