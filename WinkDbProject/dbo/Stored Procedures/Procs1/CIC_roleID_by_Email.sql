CREATE PROCEDURE [dbo].[CIC_roleID_by_Email] 
	(@admin_email varchar(100)
	 )
AS
BEGIN
Declare @login_times int
Declare @current_date datetime
Declare @admin_user_id int 
Declare @response_code int

Declare @staff_id int 

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	   
IF Exists( Select 1 from admin_user where admin_user.email = @admin_email and status =1)
BEGIN	
select * from 
	(select * from admin_user where admin_user.email = @admin_email and status =1)A
	join (select 1 as response_code , @admin_email as admin_email)T
	ON A.email = T.admin_email
END
ELSE IF EXISTS( Select 1 from thirdparty_staff where email = @admin_email and status ='enable')
BEGIN
select * from 
	(select first_name,last_name,email,staff_role_id as admin_role_id ,
	 staff_id as admin_user_id ,e.auth_token
	
	from thirdparty_staff as e where email = @admin_email and status ='enable')A
	join (select 1 as response_code , @admin_email as admin_email)T
	ON A.email = T.admin_email
END


END




