CREATE PROCEDURE  [dbo].[Create_CIC_Log] 
(
     @can_id varchar(50),
	-- @dob varchar(150),
	 @nric varchar(50),
	 @amount decimal (10,2),
     @admin_email varchar(100),
     @action_object varchar(10),
     @action_type varchar(10),
     @cic_action_type varchar(10),
     @file_name varchar(100),
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
Declare @user_id int
Declare @total_points decimal(10,2)
Declare @transaction_fees decimal(10,2)
Declare @point_per_cents int
Declare @amount_log decimal(10,2)
Set @transaction_fees = 0.20
set @amount_log = @amount*100
set @point_per_cents = 1
set @total_points = @point_per_cents * @amount_log
set @result =0

if(@admin_email !='' and @admin_email is not null)
BEGIN
  -- Get user id 
  If exists (select 1 from admin_user where email = @admin_email)
  BEGIN
  set @user_id = (select a.admin_user_id from admin_user as a where email = @admin_email) 
  select @admin_username = (admin_user.first_name+' '+ admin_user.last_name) from admin_user where admin_user.email = @admin_email

  END
  ELSE
  BEGIN
  set @user_id = (select a.staff_id from thirdparty_staff as a where email = @admin_email)
      select @admin_username = (first_name+' '+ last_name) from thirdparty_staff where email = @admin_email

  END
  
-- Get Log ID
	Set @log_id =(select top 1 cic_admin_log.id from cic_admin_log where cic_admin_log.user_id = @user_id)

--IF(@log_id IS NOT NULL and @log_id !='' and @log_id !=0)
-- Update action Count

	update cic_admin_log set action_count = ISNULL(action_count,0)+1 where id =@log_id


-- Check action type
--- Edit Action 
		Begin
    -- SET Link_url 
	Set @link_url = 'cicactiondetail/cicdetail'
-- Add Action 
	insert into cic_action_log
	(user_id,log_id,action_object,action_table_name,
	action_time,action_type,admin_user_email,admin_user_name,link_url)
	values (@user_id,@log_id,'Customer Insight','CIC_Create_Log',
	@current_date,'New',@admin_email,@admin_username,@link_url)
	
	-- Get Action ID

	Set @action_id = (select top 1 action_id from cic_action_log where admin_user_email = @admin_email order by action_id desc)

    -- Add Old Data Log before modify
			INSERT INTO [winkwink].[dbo].cic_old_data
           (action_id,
            [customer_id]
           ,[can_id]
           ,[nric]
           ,[amount]
           ,[total_points]
           ,[transaction_fees]
           ,[created_at]
           ,[cic_file_name]
           ,[cic_action_type]
           ,action_email
           
           )
           
     VALUES
     
           (
            @action_id,
            (select customer_id from can_id where can_id.customer_canid=@can_id),
            @can_id
           ,@nric
           ,@amount
           ,@total_points
           ,@transaction_fees
           ,@current_date
           ,@file_name
           ,@cic_action_type
           ,@admin_email
           )
          
         

END

if(@@ERROR =0)
Begin

set @result=1
print ('@result')
print (@result)
Return
END

END


END