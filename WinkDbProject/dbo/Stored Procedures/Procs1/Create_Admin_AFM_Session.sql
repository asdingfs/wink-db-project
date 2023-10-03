CREATE PROCEDURE [dbo].[Create_Admin_AFM_Session]
(
 @email varchar(100)
)
AS
BEGIN
 DECLARE @id int
 DECLARE @user_id int
 DECLARE @current_datetime datetime
 EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime output
 
 IF EXISTS (SELECT * FROM admin_user where admin_user.email = @email and status = '1')
	BEGIN
		SET @user_id = (SELECT admin_user.admin_user_id FROM admin_user WHERE admin_user.email = @email)
		--IF EXISTS (Select * from admin_log where admin_log.user_id = @user_id AND admin_log.status = 1)
		--BEGIN
			--SET @id = (select Top 1 admin_log.id from admin_log where admin_log.user_id = @user_id AND admin_log.status= 1)
			--IF @id != 0 AND @id IS NOT NULL
			--BEGIN
				
				IF NOT EXISTS(SELECT id from admin_mfa_session where status = 0 and @current_datetime <= expired_at and admin_id = @user_id)
				BEGIN
					declare @random int;
					declare @lower int;
					declare @upper int;
					declare @sessionId int;
					declare @expired_at datetime;

					set @lower  = 1000; --The lowest random number
					set @upper  = 9999; --The highest random number
					SELECT @random = ROUND(((@upper - @lower -1) * RAND() + @lower), 0)

					WHILE  EXISTS (SELECT * FROM admin_mfa_session WHERE session_code = @random and expired_at >= @current_datetime)
					BEGIN
						SELECT @random = ROUND(((@upper - @lower -1) * RAND() + @lower), 0)
					END

					SELECT @expired_at = DATEADD(MINUTE,system_value,@current_datetime)FROM system_key_value WHERE system_key = 'admin_session_validity'
				
				

					INSERT INTO [dbo].[admin_mfa_session]
						   ([admin_log_id]
						   ,[admin_id]
						   ,[admin_email]
						   ,[session_code]
						   ,[created_at]
						   ,[expired_at]
						   ,[status])
					 VALUES
						   (0
						   ,@user_id
						   ,@email
						   ,@random
						   ,@current_datetime
						   ,@expired_at
						   ,0)
	
					set @sessionId = SCOPE_IDENTITY();
					IF @@ROWCOUNT > 0
					BEGIN
			
					
						SELECT '1' AS success, 'A verification code has been sent to your registered email.' as msg, @random as code, (select first_name+' '+last_name from admin_user where admin_user_id = @user_id ) as adminName;
						RETURN
					END
				END
				ELSE
				BEGIN
					
					SELECT '2' AS success, 'We have already sent you a verification code.' as msg, '' as code, '' as adminName;
					RETURN
				END
				
			--END
		
		--END
		--ELSE 
		--BEGIN
		--	SELECT '0' AS success, 'Your session has expired. Please login again.' as msg, '' as code, '' as adminName;
		--	RETURN
		--END
	
	END
	ELSE 
	BEGIN
		SELECT '0' AS success, 'Please enter a valid email.' as msg, '' as code, '' as adminName;
		RETURN
	END
 

END