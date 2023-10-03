CREATE PROCEDURE [dbo].[Create_CIC_Admin_Log]
(
 @user_id int,
 @user_name varchar(100),
 @login_time datetime,
 @admin_email varchar(100)
 
)
AS
BEGIN
 IF NOT EXISTS (SELECT * from cic_admin_log where user_id = @user_id and logout_time IS NULL)
 BEGIN
 Insert into cic_admin_log (cic_admin_log.user_id,
 cic_admin_log.user_name,
 login_time,
 status,email)
 Values (@user_id,@user_name,@login_time,1,@admin_email)
 END
END



