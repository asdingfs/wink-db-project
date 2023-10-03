CREATE PROCEDURE  [dbo].[CreateWinkGoAssetLog] 
(
	 @asset_id int,
     @campaign_id int,
	 @campaign_name varchar(255),

	 @campaign_start_date datetime,
	 @campaign_end_date  datetime,
	 @image varchar(255),
	 @url varchar(255),
	 @points int,
	 @interval int,
	 @status varchar(10),
	 @created_at DateTime,
	 @updated_at DateTime,
     @admin_email varchar(100),
     @action_object varchar(50),
     @action_type varchar(50),
	
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
	Set @link_url = 'adminactiondetail/winkgoassetediteddetail'
-- Add Action 
	insert into action_log
	(log_id,action_object,action_table_name,
	action_time,action_type,admin_user_email,admin_user_name,link_url)
	values (@log_id,'winkgoasset','winkgoasset_log',
	@current_date,@action_type,@admin_email,@admin_username,@link_url)
	
	-- Get Action ID

	Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc)

	
	
    -- Add Old Data Log before modify
			INSERT INTO [winkwink].[dbo].assetwinkgo_olddata_log
           (
            [action_id]
		   ,[campaign_id]
           ,[name]
           ,[image]
           ,[url]
           ,[points]
           ,[interval]
           ,[status]
           ,[created_at]
		   ,[updated_at]
           ,[from_date]
           ,[to_date]
		  )
           
     VALUES
     
           (
            @action_id
           ,@campaign_id
           ,@campaign_name
		   ,@image
		   ,@url
		   ,@points
		   ,@interval
		   ,@status
           ,@created_at
           ,@updated_at
           ,@campaign_start_date
           ,@campaign_end_date
      
           )
           
 -- Add New Data Log 
			INSERT INTO [winkwink].[dbo].assetwinkgo_newdata_log
           (
             [action_id]
		   ,[new_campaign_id]
           ,[new_name]
           ,[new_image]
           ,[new_url]
           ,[new_points]
           ,[new_interval]
           ,[new_status]
           ,[new_created_at]
		   ,[new_updated_at]
           ,[new_from_date]
           ,[new_to_date]
		   )
           
		select   @action_id
           ,[campaign_id]
           ,[name]
           ,[image]
           ,[url]     
           ,[points]
           ,[interval]
           ,[status]
           ,[created_at]
		   ,[updated_at]
           ,[from_date]
           ,[to_date]
           
           from asset_winkgo where asset_winkgo.id = @asset_id
              
          
           

END
ELSE 
BEGIN 
-- SET Link_url 
	Set @link_url = 'adminactiondetail/winkgoassetdetail'
-- Add Action 
	insert into action_log
	(log_id,action_object,action_table_name,
	action_time,action_type,admin_user_email,admin_user_name,link_url)
	values (@log_id,'winkgoasset','assetwinkgo_log',
	@current_date,@action_type,@admin_email,@admin_username,@link_url)
	
	-- Get Action ID

     Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc)	
	
	
 -- Add Old Data Log 
			INSERT INTO [winkwink].[dbo].assetwinkgo_olddata_log
           (
            [action_id]
            ,[campaign_id]
           ,[name]
           ,[image]
           ,[url]      
           ,[points]
           ,[interval]
           ,[status]
           ,[created_at]
		   ,[updated_at]
           ,[from_date]
           ,[to_date]
		   
		   )
           
select      TOP 1 
			@action_id
            ,[campaign_id]
           ,[name]
           ,[image]
           ,[url]
          
           ,[points]
           ,[interval]
           ,[status]
           ,[created_at]
		   ,[updated_at]
           ,[from_date]
           ,[to_date]
           
           from asset_winkgo where asset_winkgo.campaign_id =@campaign_id order by id desc    
        
           
 END         

END

Set @result = 1

END TRY
BEGIN CATCH

print( ERROR_MESSAGE())


Set @result =2
return 
END CATCH

END
