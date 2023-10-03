CREATE PROCEDURE [dbo].[AdminUserLogin] 
	(@admin_email varchar(100),
	 @password varchar(100),
	 @ip_address varchar(150)
	 )
AS
BEGIN
Declare @login_times int
Declare @current_date datetime
Declare @admin_user_id int 
Declare @response_code int

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

-- Check Block IP
	IF NOT EXISTS (Select wink_customer_block_ip.ip_address from wink_customer_block_ip
	where wink_customer_block_ip.ip_address = @ip_address)
	BEGIN
	-- Check Correct User	
	SET @admin_user_id = ISNULL((select admin_user_id from admin_user where admin_user.email = @admin_email and admin_user.status =1),0)
	print(@admin_user_id)
	IF (@admin_user_id !='' and @admin_user_id !=0)
	BEGIN		
	IF ( lower(@password) != Lower((select password from admin_user where admin_user.email= @admin_email)) )
	BEGIN
	   -- Insert Login Fail Log
	   insert into wink_adminuser_login_log (admin_id,admin_email,created_at,admin_action,ip_address)
	   Values (@admin_user_id,@admin_email,@current_date,'loginfail',@ip_address)
	   
		Set @login_times = (select COUNT(*) from wink_adminuser_login_log where @admin_email = admin_email and CAST(created_at as DATE) = CAST (@current_date as date)
		and admin_action ='loginfail'
		)
		
		print (@login_times)
	    -- Block if equal and More than 5
		if(@login_times>=100)
		BEGIN
	      Update admin_user set status = 0 where admin_user.email = @admin_email
		END
		Set @response_code = 0
	    GOTO Result
	END
	ELSE
	BEGIN
	Set @response_code = 1
	GOTO Result
	--select * from admin_user where admin_user.email = @admin_email and password = @password and status =1
	 
	return
	 END
	END
	END
	Else
	Begin 
	Set @response_code = 0
	GOTO Result
	END
	
Result:
if(@response_code =0)
    BEGIN
	select @response_code as response_code , 'Invalid admin user' as response_message
	END
else 
BEGIN
-- Insert ----------------------------
insert into wink_adminuser_login_log (admin_id,admin_email,created_at,admin_action,ip_address)
	   Values (@admin_user_id,@admin_email,@current_date,'login',@ip_address)
	   
		
select * from 
	(select * from admin_user where admin_user.email = @admin_email and password = @password and status =1)A
	join (select 1 as response_code , @admin_email as admin_email)T
	ON A.email = T.admin_email
END

END

