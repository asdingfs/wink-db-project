CREATE PROCEDURE [dbo].[AdminUserLoginAndBlockIp_ResetPassword] 
	(@admin_email varchar(100),
	 @password varchar(100),
	 @ip_address varchar(150),
	 @session_code int
	 )
AS
BEGIN
	Declare @login_times int
	Declare @verifyCount int
	Declare @current_date datetime
	Declare @admin_user_id int 
	Declare @response_code int

	
	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	IF EXISTS (select 1 from admin_user as u where u.email = @admin_email and status = 0)
	BEGIN
		select 0 as response_code , 'Account is locked. Please contact customer service.' as response_message
		RETURN
	END

	-- Check Block IP
	IF NOT EXISTS (Select wink_customer_block_ip.ip_address from wink_customer_block_ip
	where wink_customer_block_ip.ip_address = @ip_address)
	BEGIN
		-- Check Correct User	
		SET @admin_user_id = ISNULL((select admin_user_id from admin_user where admin_user.email = @admin_email and admin_user.status =1),0);
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
				if(@login_times>=5)
				BEGIN
					Update admin_user set status = 0 where admin_user.email = @admin_email
				END
				Set @response_code = 0
				GOTO Result
			END
			ELSE
			BEGIN
				-- Check password 
				IF NOT Exists (select 1 from admin_user_password where admin_user_id =@admin_user_id)
				BEGIN

					Set @response_code = 2
					GOTO Result

				END
				ELSE --IF EXISTS (select 1 from admin_user_password where admin_user_id =@admin_user_id)
				BEGIN
	  
					Declare @last_password_updated_at datetime
					set @last_password_updated_at = (select top 1 created_at from admin_user_password where admin_user_id =@admin_user_id order by created_at desc) 
		
				--IF(@admin_user_id =75)
					BEGIN
					IF(cast(@current_date as date) > DATEADD(MONTH,3,@last_password_updated_at))
						Set @response_code = 2
						GOTO Result 

					END
					Set @response_code = 1
					GOTO Result
				END

	
			--select * from admin_user where admin_user.email = @admin_email and password = @password and status =1
	 
				return
			END
			
		END
		Else
		Begin 
			Set @response_code = 0
			GOTO Result
		END
	END

	Result:
	if(@response_code = 0)
	BEGIN
		select @response_code as response_code , 'Invalid Email Or Password!' as response_message;
		return
	END
	else if(@response_code =2)
	BEGIN
		select @response_code as response_code , 'Please change your password.' as response_message;
		RETURN
	END
	else
	BEGIN
		declare @adminLogId int	 
		declare @sessionId int	 
		-- Insert ----------------------------
		insert into wink_adminuser_login_log (admin_id,admin_email,created_at,admin_action,ip_address)
			   Values (@admin_user_id,@admin_email,@current_date,'login',@ip_address);
  
		set @adminLogId = SCOPE_IDENTITY();
		IF @@ROWCOUNT > 0
		BEGIN
		
			SELECT TOP(1) @sessionId = id from admin_mfa_session 
			where status = 0 
			and @current_date <= expired_at 
			and admin_id = @admin_user_id 
			and admin_log_id = 0
			and session_code = @session_code
			order by created_at desc;

			IF(@sessionId is null or @sessionId = 0)
			BEGIN

				declare @correctSessionId int	 

				SELECT TOP(1) @correctSessionId = id from admin_mfa_session 
				where status = 0 
				and @current_date <= expired_at 
				and admin_id = @admin_user_id 
				and admin_log_id = 0
				order by created_at desc;


				--Insert failed authentication of session code into the log table
				insert into admin_user_session_log (session_id, admin_email, admin_id,admin_action,ip_address,created_at)
				Values (ISNULL(@correctSessionId,0), @admin_email,@admin_user_id,'invalid',@ip_address, @current_date);
	   
				
				Set @verifyCount = (
				select COUNT(*) from admin_user_session_log where @admin_email = admin_email and CAST(created_at as DATE) = CAST (@current_date as date)
				and session_id = ISNULL(@correctSessionId,0)
				and admin_action ='invalid'
				);
		
			
				---- Block if equal and More than 3
				if(@verifyCount>=3)
				BEGIN
					Update admin_user set status = 0 where admin_user.email = @admin_email
				END

				select 3 as response_code , 'Invalid verification code.' as response_message;
				return
			END
			ELSE
			BEGIN
				UPDATE admin_mfa_session
				SET admin_log_id = @adminLogId, status = 1
				WHERE id = @sessionId;
			END
		
		END
			
		select * from 
			(select * from admin_user where admin_user.email = @admin_email and password = @password and status =1)A
			join (select 1 as response_code , @admin_email as admin_email)T
			ON A.email = T.admin_email
	END

END

/*
select * from admin_user_password where admin_user_id = 95 order by created_at desc
*/

/*select p.created_at,a.email from admin_user_password as p,admin_user as a where 
a.admin_user_id = p.admin_user_id
order by p.created_at desc*/

