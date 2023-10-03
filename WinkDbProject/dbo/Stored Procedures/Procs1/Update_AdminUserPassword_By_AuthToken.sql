CREATE Procedure [dbo].[Update_AdminUserPassword_By_AuthToken]
(
@auth_token varchar(150),
@password varchar(100)
)

AS 
BEGIN
Declare @admin_user_id int
DECLARE @current_date datetime
Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output
IF EXISTS (select 1 from admin_user where admin_user.auth_token = @auth_token and  status =1)

BEGIN

SET @admin_user_id = (select admin_user_id from admin_user where admin_user.auth_token = @auth_token and  status =1)
IF NOT EXISTS (select 1 from admin_user_password where admin_user_id =@admin_user_id and @password = admin_password)
BEGIN
Update admin_user SET password = @password where admin_user_id =@admin_user_id
		IF(@@ROWCOUNT>0)
		BEGIN
			insert into admin_user_password (admin_user_id , admin_password,created_at, updated_at)
				values (@admin_user_id , @password, @current_date,@current_date)

			IF(@@ERROR =0)
			BEGIN
			Select 1 as response_code , 'Successfully saved.' as response_message 
			RETURN
			END

		END

END
ELSE 
BEGIN
select 0 as response_code , 'Same password reuse prevention. Please enter new password' as response_message

END
END

ELSE

BEGIN

select 0 as response_code , 'Invalid request data' as response_message
END

END


