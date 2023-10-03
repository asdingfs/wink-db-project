Create PROCEDURE [dbo].[Update_CICAdminUser_LogOut_StatusbyEmail]
(
 @email varchar(150)
 
)
AS
BEGIN
 DECLARE @id int
 DECLARE @user_id int
 DECLARE @logout_time datetime
 EXEC GET_CURRENT_SINGAPORT_DATETIME @logout_time output
 
 IF EXISTS (SELECT 1 FROM admin_user where admin_user.email = @email and admin_role_id>=100)
	BEGIN
		SET @user_id = (SELECT admin_user.admin_user_id FROM admin_user WHERE admin_user.email = @email and admin_role_id>=100)
	END
 ELSE IF  EXISTS (SELECT 1 FROM thirdparty_staff where email = @email and parent_role_id>=100)
	BEGIN
	SET @user_id = (SELECT thirdparty_staff.staff_id FROM thirdparty_staff WHERE thirdparty_staff.email = @email and parent_role_id>=100)
	
	END	
	
	IF (@user_id is not null and @user_id !=0 and @user_id !='')
    BEGIN
    IF EXISTS (Select * from cic_admin_log where cic_admin_log.user_id = @user_id AND cic_admin_log.status = 1)
	BEGIN
		SET @id = (select Top 1 cic_admin_log.id from cic_admin_log where cic_admin_log.user_id = @user_id AND cic_admin_log.status= 1)
			IF @id != 0 AND @id IS NOT NULL
				BEGIN
				print('aaaaa')
				update cic_admin_log set cic_admin_log.status = 0 ,cic_admin_log.logout_time = @logout_time
				Where cic_admin_log.id = @id 
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
