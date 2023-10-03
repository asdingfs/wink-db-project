
CREATE Procedure [dbo].[UpdateAdminUserWithIP] 
(

@email varchar(100),
@password  varchar(100),
@first_name varchar(100),
@last_name varchar(100),
@home_ip  varchar(100),
@mobile_ip  varchar(100),
@admin_role_id int,
@responsible_person varchar(100),
@id int


)
As
Begin

Declare @m_ip varchar(100)
set @m_ip = (select mobile_ip from admin_user Where admin_user.admin_user_id= @id)


Declare @h_ip varchar(100)
set @h_ip = (select home_ip from admin_user Where admin_user.admin_user_id= @id)



Declare @current_datetime datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

print 'insert white_list_IP_log'

INSERT INTO White_list_IP_Log(
       email
      ,home_ip
      ,mobile_ip
      ,updated
      ,old_home_ip
      ,old_mobile_ip
      ,responsible_person
	  ,action_type

)
VALUES (

		@email,
		@home_ip,
		@mobile_ip,
		@current_datetime,
		@h_ip, 
		@m_ip,
		@responsible_person,
		'edit'
		
		)


IF (@password IS NOT NULL AND @password!='')

begin
Update admin_user 
SET email = @email,
password = @password,
first_name = @first_name,
last_name =@last_name,
admin_role_id =@admin_role_id,
mobile_ip =@mobile_ip,
home_ip =@home_ip,
updated_at = @current_datetime
Where admin_user.admin_user_id= @id

end

else
begin
print 'here to update'
Update admin_user 
SET email = @email,
first_name = @first_name,
last_name =@last_name,
admin_role_id =@admin_role_id,
mobile_ip =@mobile_ip,
home_ip =@home_ip,
updated_at = @current_datetime
Where admin_user.admin_user_id= @id

end



End
