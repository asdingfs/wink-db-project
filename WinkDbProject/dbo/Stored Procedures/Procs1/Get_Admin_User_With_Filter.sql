

CREATE PROCEDURE [dbo].[Get_Admin_User_With_Filter]
	(
	
	 @user_email varchar(100),
	 @user_status varchar(100)
 )
AS
BEGIN






IF (@user_email is null or @user_email = '')
 BEGIN
 SET @user_email = NULL;
 
 END
 
 IF (@user_status is null or @user_status = '')
 BEGIN
 SET @user_status = NULL;
 
 END


 select * from admin_user where (
 (@user_email IS NULL OR  UPPER(email) like '%' + UPPER(@user_email) +'%')
 AND (@user_status IS NULL OR  status = @user_status)
 )
 order by admin_user.admin_user_id desc
 


END
