CREATE PROCEDURE [dbo].[Update_AdminUser_LogIn_StatusbyEmail]
(
 @email varchar(150)
 
)
AS
BEGIN
 DECLARE @id int
 DECLARE @user_id int
 DECLARE @logout_time datetime
 EXEC GET_CURRENT_SINGAPORT_DATETIME @logout_time output
 
 IF EXISTS (SELECT * FROM admin_user where admin_user.email = @email)
	BEGIN
		SET @user_id = (SELECT admin_user.admin_user_id FROM admin_user WHERE admin_user.email = @email)
		IF EXISTS (Select * from admin_log where admin_log.user_id = @user_id AND admin_log.status = 1)
		BEGIN
			SET @id = (select Top 1 admin_log.id from admin_log where admin_log.user_id = @user_id AND admin_log.status= 1 order by id desc)
			IF @id != 0 AND @id IS NOT NULL
				BEGIN
				print('aaaaa')
				print(@id)
				update admin_log set admin_log.status = 1 ,admin_log.logout_time = NULL
				Where admin_log.id = @id 
				END
		
			--print(@@ROWCOUNT)
			IF @@ROWCOUNT > 0
			BEGIN
				--print('dkfjkdljf')
				SELECT '1' AS success 
			END
			ELSE 
			BEGIN
				--print('GGGG')
				SELECT '0' AS success
	
			END
			RETURN

		END
		ELSE 
		IF EXISTS (Select * from admin_log where admin_log.user_id = @user_id AND admin_log.status = 0)
		BEGIN
			SET @id = (select Top 1 admin_log.id from admin_log where admin_log.user_id = @user_id AND admin_log.status= 0 order by id desc)
			IF @id != 0 AND @id IS NOT NULL
				BEGIN
				print('aaaaa')
				print(@id)
				update admin_log set admin_log.status = 1 ,admin_log.logout_time = NULL
				Where admin_log.id = @id 
				END
		
			--print(@@ROWCOUNT)
			IF @@ROWCOUNT > 0
			BEGIN
				print('dkfjkdljf')
				SELECT '1' AS success 
				RETURN
			END
			ELSE
			BEGIN
				print('GGGG')
				SELECT '0' AS success
				RETURN
			END

		END
		ELSE 
			BEGIN
				SELECT '0' AS success
				RETURN
	
			END
	
	END
	
	ELSE 
		BEGIN
			SELECT '0' AS success
				RETURN
		END
 

END

--Select * from admin_log
