CREATE Procedure [dbo].[UpdateAdminUserWithPassword]
(
@admin_user_id int,
@email varchar(150),
@password varchar(150),
@first_name varchar (100),
@last_name varchar (100),
@admin_role_id int
)

AS 
BEGIN
DECLARE @merchant_id int 
DECLARE @max_id int 
DECLARE @current_date datetime
Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output
SET @merchant_id =0

IF EXISTS (select 1 from admin_user where admin_user_id = @admin_user_id)

BEGIN
IF NOT EXISTS (select 1 from admin_user_password where admin_user_id =@admin_user_id and @password = admin_password)
BEGIN
Update admin_user SET email = @email,password = @password,first_name = @first_name,last_name =@last_name,admin_role_id =@admin_role_id 
Where admin_user.admin_user_id= @admin_user_id
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
