
Create Procedure [dbo].[UpdateAdminUserNoPassword] 
(

@email varchar(100),
@password  varchar(100),
@first_name varchar(100),
@last_name varchar(100),
@admin_role_id int,
@id int


)
As
Begin
    
Declare @current_datetime datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

Update admin_user 
SET email = @email,
password = @password,
first_name = @first_name,
last_name =@last_name,
admin_role_id =@admin_role_id,
updated_at = @current_datetime
Where admin_user.admin_user_id= @id


IF (@@ROWCOUNT > 0)
Begin

SELECT '1' AS response_code, 'Success' as response_message
		return

end
else
begin

SELECT '0' AS response_code, 'Fail' as response_message
		return

end



End
