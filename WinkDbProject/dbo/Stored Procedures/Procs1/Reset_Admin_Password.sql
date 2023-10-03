
CREATE ProcEDURE [dbo].[Reset_Admin_Password] 
	(@admin_email varchar(100),
	 @current_password varchar(100),
	 @ip_address varchar(150),
	 @new_password varchar(100)
	 )
AS
BEGIN
	Declare @login_times int
	Declare @current_date datetime
	Declare @admin_user_id int 
	Declare @response_code int

	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	IF (@current_password = @new_password)
	BEGIN
		Set @response_code = 2
		GOTO Result

	END

	-- Check Block IP
	IF NOT EXISTS (Select wink_customer_block_ip.ip_address from wink_customer_block_ip
	where wink_customer_block_ip.ip_address = @ip_address)
	BEGIN
		-- Check Correct User	
		SET @admin_user_id = ISNULL((select admin_user_id from admin_user where admin_user.email = @admin_email and admin_user.status =1),0)
		print(@admin_user_id)
		IF (@admin_user_id !='' and @admin_user_id !=0)
		BEGIN
			IF ( lower(@current_password) != Lower((select password from admin_user where admin_user.email= @admin_email)) )
			BEGIN
				-- Insert Login Fail Log
				insert into wink_adminuser_login_log (admin_id,admin_email,created_at,admin_action,ip_address)
				Values (@admin_user_id,@admin_email,@current_date,'Resetloginfail',@ip_address);
	   
				Set @login_times = (select COUNT(*) from wink_adminuser_login_log where @admin_email = admin_email and CAST(created_at as DATE) = CAST (@current_date as date)
				and admin_action ='Resetloginfail');
		
				print (@login_times)
				-- Block if equal and More than 5
				IF(@login_times>=5)
				BEGIN
					Update admin_user set status = 0 where admin_user.email = @admin_email
					Set @response_code = 3
					GOTO Result
				END

				Set @response_code = 4
				GOTO Result
			END
			ELSE
			BEGIN
				--- Check password 
				IF EXISTs (select 1 From admin_user_password where admin_password = @new_password and admin_user_id =@admin_user_id)
				BEGIN
					Set @response_code = 2
					GOTO Result
				END
				ELSE -- Update Password
				BEGIN
					insert into admin_user_password (admin_user_id , admin_password,created_at, updated_at)
					values (@admin_user_id , @new_password, @current_date,@current_date);
					IF (@@ERROR =0)
					BEGIN
						update admin_user set password = @new_password where admin_user_id = @admin_user_id;
						IF(@@ROWCOUNT>0)
						BEGIN
							Set @response_code = 1
							GOTO Result
						END
					END
				END
			END
		END
		Else
		Begin 
			Set @response_code = 0
			GOTO Result
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
		select 0 as response_code , 'Invalid admin user.' as response_message
	END
	else if (@response_code =2)
	BEGIN
		select 0 as response_code , 'Same password reuse prevention. Please enter a new password.' as response_message;
		Return
	END
	else if (@response_code =3)
	BEGIN
		select 0 as response_code , 'Your accout is locked. Please contact the WINK+ Team.' as response_message
		Return
	END
	else if (@response_code =4)
	BEGIN
		select 0 as response_code , 'Invalid email or password.' as response_message
		Return
	END
	ELSE 
	BEGIN
		-- Insert ----------------------------
		insert into wink_adminuser_login_log (admin_id,admin_email,created_at,admin_action,ip_address)
			   Values (@admin_user_id,@admin_email,@current_date,'login',@ip_address);
	   	
		select * from 
			((select * from admin_user where admin_user.email = @admin_email and password = @new_password and status =1)A
			join (select 1 as response_code ,'You have successfully updated your password.' as response_message, @admin_email as admin_email)T
			ON A.email = T.admin_email);
	END

END


