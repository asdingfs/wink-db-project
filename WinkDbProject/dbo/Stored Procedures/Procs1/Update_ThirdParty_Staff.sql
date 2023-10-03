CREATE procedure [dbo].[Update_ThirdParty_Staff]
(
 @email varchar(200),
 @password varchar(250),
 @first_name varchar(50),
 @last_name varchar(50),
 @status varchar(10),
 @parent_role_id int,
 @parent_role_name varchar(20),
 @staff_role_id int,
 @staff_id int 
)
As 
BEGIN
Declare @current_date datetime
Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

  IF EXISTS (select 1 from thirdparty_staff where parent_role_id = @parent_role_id
  and parent_name =@parent_role_name
  and email=@email and staff_id != @staff_id)
  BEGIN
   select 0 as success , 'Email already in used' as response_message

  END 
  ELSE
  BEGIN
	--- Not saving password
	IF(@password !='' and @password is not null)
	 BEGIN
	 Update thirdparty_staff SET email = @email,first_name = @first_name,last_name =@last_name,
	 staff_role_id = @staff_role_id,
	 password=@password,status = @status 
     Where staff_id= @staff_id 
	 END
	 else
	 BEGIN
	 Update thirdparty_staff SET email = @email,first_name = @first_name,last_name =@last_name,
	  staff_role_id = @staff_role_id
	 ,status = @status 
     Where staff_id= @staff_id 
	 END
	IF(@@ERROR=0)
	Begin
	 select 1 as success , 'Successfully saved' as response_message
 
	 END
	ELSE
	Begin
	select 0 as success , 'Fail to save' as response_message
 
	END
 END
 
 
  
  
END


