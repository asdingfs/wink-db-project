CREATE PROCEDURE [dbo].[Create_Admin_Log]
(
 @user_id int,
 @user_name varchar(100),
 @login_time datetime
 

)
AS
BEGIN
 IF NOT EXISTS (SELECT * from admin_log where admin_log.user_id = @user_id and admin_log.status='1')
 BEGIN
 Insert into admin_log (admin_log.user_id,
 admin_log.user_name,
 login_time,
 status)
 Values (@user_id,@user_name,@login_time,1)
 END
END

--Select * from admin_log
