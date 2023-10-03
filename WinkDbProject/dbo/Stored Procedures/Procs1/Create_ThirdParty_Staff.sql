CREATE procedure [dbo].[Create_ThirdParty_Staff]
(
 @email varchar(200),
 @auth_token varchar(200),
 @password varchar(250),
 @first_name varchar(50),
 @last_name varchar(50),
 @status varchar(10),
 @parent_role_id int,
 @parent_role_name varchar(20),
 @staff_role_id int
)
As 
BEGIN
Declare @current_date datetime
Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output
  IF NOT EXISTS (select 1 from thirdparty_staff where parent_role_id = @parent_role_id
  and email =@email)
  BEGIN
  
 INSERT INTO thirdparty_staff(email,password ,first_name,
 last_name,parent_role_id,parent_name,staff_role_id,auth_token,status,created_at)
 values
 (@email,@password,@first_name,@last_name,@parent_role_id,@parent_role_name,
 @staff_role_id,@auth_token,@status,@current_date)
 IF(@@ERROR=0)
 Begin
 select 1 as success , 'Successfully saved' as response_message
 
 END
 ELSE
 Begin
 select 0 as success , 'Fail to save' as response_message
 
 END
 END
 
   ELSE
 Begin
 select 0 as success , 'Email already in used' as response_message
 
 END
 
  
  
END



