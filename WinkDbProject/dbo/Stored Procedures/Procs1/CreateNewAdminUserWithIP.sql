

CREATE Procedure [dbo].[CreateNewAdminUserWithIP] 
(

@email varchar(100),
@password varchar(100),
@first_name varchar(100),
@last_name varchar(100),
@admin_role_id int,
@auth_token varchar(100),
@home_ip varchar(100),
@mobile_ip varchar(100),
@responsible_person varchar(100)


)
As
Begin

Declare @m_ip varchar(100)
set @m_ip = ''


Declare @h_ip varchar(100)
set @h_ip = ''



Declare @current_datetime datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output


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
		'create'
		
		)


INSERT INTO admin_user(

email,
password,
first_name,
last_name,
admin_role_id,
auth_token,
home_ip,
mobile_ip,
created_at,
updated_at

)
VALUES (

@email,
@password,
@first_name,
@last_name,
@admin_role_id,
@auth_token,
@home_ip,
@mobile_ip,
@current_datetime,
@current_datetime

)







End

