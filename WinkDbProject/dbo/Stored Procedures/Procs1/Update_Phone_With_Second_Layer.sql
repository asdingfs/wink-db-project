CREATE PROCEDURE [dbo].[Update_Phone_With_Second_Layer]
	(@auth_token varchar(100),
	 @phone_no varchar(10),
	 @subscribe_status varchar(5)
	 )
AS	
Begin
IF EXISTS ( select * from customer where auth_token = @auth_token)
BEGIN
IF EXISTS (Select * from customer where phone_no = @phone_no ) 

BEGIN
Select '0' as success ,'Mobile number already in use' as response_message 
END

ELSE
BEGIN

Update customer 

Set phone_no = @phone_no,
subscribe_status = @subscribe_status

where auth_token = @auth_token

IF (@@ROWCOUNT > 0)
     
	 BEGIN
		Select '1' as success ,'Your mobile number has been registered successfully' as response_message 
     END  
 Else 
	
	 BEGIN
		Select '0' as success ,'Update Connection Error' as response_message 
     END  

END
END
ELSE
BEGIN
	Select '2' as success , 'Multiple login not allowed' as response_message
END
END
