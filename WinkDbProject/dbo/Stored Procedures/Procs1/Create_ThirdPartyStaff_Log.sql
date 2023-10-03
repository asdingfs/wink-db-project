CREATE PROCEDURE  [dbo].[Create_ThirdPartyStaff_Log] 
(

 @staff_email varchar(200),
 @auth_token varchar(200),
 @password varchar(250),
 @first_name varchar(50),
 @last_name varchar(50),
 @status varchar(10),
 @parent_role_id int,
 @parent_role_name varchar(20),
 @staff_role_id int,
 @admin_email varchar(100),
 @action_object varchar(20),
 @action_type varchar(20),
 
 @old_staff_id int,
 @old_staff_email varchar(200),
 @old_password varchar(250),
 @old_first_name varchar(50),
 @old_last_name varchar(50),
 @old_status varchar(10),
 
 @old_staff_role_id int
    
)
AS
BEGIN 
Set @auth_token ='NA'
Declare @current_date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
Declare @log_id int 
Declare @admin_username varchar(10)
Declare @action_id int
Declare @link_url varchar(50)
Declare @user_id int
Declare @staff_id int

set @staff_id = (select staff_id from thirdparty_staff where email = @staff_email)



if(@staff_email is not null and @staff_email !='' and @admin_email !='' and @admin_email is not null)
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
IF(@action_type='Edit')
		Begin
		
    -- SET Link_url 
	Set @link_url = 'cicactiondetail/cicstaffeditlog'
-- Add Action 
	insert into cic_action_log
	(user_id,log_id,action_object,action_table_name,
	action_time,action_type,admin_user_email,admin_user_name,link_url)
	values (@user_id,@log_id,'Staff','thirdparty_staff_log',
	@current_date,@action_type,@admin_email,@admin_username,@link_url)
	
	-- Get Action ID

	Set @action_id = (select top 1 action_id from cic_action_log where admin_user_email = @admin_email order by action_id desc)

    -- Add Old Data Log before modify
 INSERT INTO thirdparty_staff_old_data(action_id,email,password ,first_name,
 last_name,parent_role_id,parent_name,staff_role_id,auth_token,status,created_at,staff_id)
 values
 (@action_id,@old_staff_email,@old_password,@old_first_name,@old_last_name,@parent_role_id,@parent_role_name,
 @old_staff_role_id,@auth_token,@old_status,@current_date,@staff_id)
 
 INSERT INTO thirdparty_staff_new_data(action_id,new_email,password ,new_first_name,
 new_last_name,parent_role_id,parent_name,new_staff_role_id,auth_token,status,created_at,staff_id)
 values
 (@action_id,@staff_email,@password,@first_name,@last_name,@parent_role_id,@parent_role_name,
 @staff_role_id,@auth_token,@status,@current_date,@staff_id)
          
 
END

ELSE IF (@action_type='New')
Begin
    -- SET Link_url 
	Set @link_url = 'cicactiondetail/cicstaffnewlog'
-- Add Action 
		insert into cic_action_log
	(user_id,log_id,action_object,action_table_name,
	action_time,action_type,admin_user_email,admin_user_name,link_url)
	values (@user_id,@log_id,'Staff','thirdparty_staff_log',
	@current_date,@action_type,@admin_email,@admin_username,@link_url)
	
	-- Get Action ID

   Set @action_id = (select top 1 action_id from cic_action_log where admin_user_email = @admin_email order by action_id desc)
    INSERT INTO thirdparty_staff_old_data(action_id,email,password ,first_name,
    last_name,parent_role_id,parent_name,staff_role_id,auth_token,status,created_at,staff_id)
    values
 (@action_id,@staff_email,@password,@first_name,@last_name,@parent_role_id,@parent_role_name,
 @staff_role_id,@auth_token,@status,@current_date,@staff_id)
          

END
ELSE
BEGIN
  -- SET Link_url 
	Set @link_url ='cicactiondetail/cicstaffnewlog'
-- Add Action 
		insert into cic_action_log
	(user_id,log_id,action_object,action_table_name,
	action_time,action_type,admin_user_email,admin_user_name,link_url)
	values (@user_id,@log_id,'Staff','thirdparty_staff_log',
	@current_date,@action_type,@admin_email,@admin_username,@link_url)
	
	-- Get Action ID

   Set @action_id = (select top 1 action_id from cic_action_log where admin_user_email = @admin_email order by action_id desc)
    INSERT INTO thirdparty_staff_old_data(action_id,email,password ,first_name,
    last_name,parent_role_id,parent_name,staff_role_id,auth_token,status,created_at,staff_id)
    values
 (@action_id,@staff_email,@password,@first_name,@last_name,@parent_role_id,@parent_role_name,
 @staff_role_id,@auth_token,@status,@current_date,@old_staff_id)

END


		If(@@ERROR =0)
		BEGIN
		select 1 as success , 'successfully saved' as reponse_message 
		return
		END
		Else 
		 BEGIN
		select 0 as success , 'Fail to save' as reponse_message 
		return
		END
END
Else 
BEGIN
select 0 as success , 'Invalid data' as reponse_message 
return
END


END

