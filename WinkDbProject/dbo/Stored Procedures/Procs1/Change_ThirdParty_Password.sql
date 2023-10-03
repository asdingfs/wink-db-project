Create PROCEDURE [dbo].[Change_ThirdParty_Password] 
	(
	 @auth_token varchar(100),
	 @password varchar(200)
	 )
AS
BEGIN

Declare @current_date datetime
Declare @success int 
set @success = 0

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output
IF Exists (Select 1 from admin_user where auth_token= @auth_token and admin_role_id>=100)
BEGIN
update admin_user set password = @password where auth_token =@auth_token
IF(@@ERROR =0)
BEGIN
Set @success =1
Goto Result;
END
END
ELSE IF Exists (Select 1 from thirdparty_staff as a where auth_token= @auth_token and a.staff_role_id>=200)
BEGIN
update thirdparty_staff set password = @password where auth_token =@auth_token
IF(@@ERROR =0)
BEGIN
Set @success =1
Goto Result;
END
END
ELSE
BEGIN
Set @success =2
Goto Result;
END

Result:
IF(@success =1)
BEGIN
select 1 as success , 'Successfully saved' as response_message
Return
END 
ELSE IF(@success =0)
BEGIN
select 0 as success , 'Fail to save' as response_message
Return
END
ELSE
BEGIN
select 0 as success , 'Invalid user' as response_message

END

END

