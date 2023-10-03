CREATE PROCEDURE [dbo].[User_SignIn_With_Phone_With_Second_Layer]
	(@auth_token varchar(100),
	 @phone_no varchar(10)
	 )
AS	

IF EXISTS (Select * from customer where phone_no = @phone_no ) 

BEGIN
Select '0' as success ,'Phone No already in use' as response_message 
END

ELSE
BEGIN

Update customer 

Set phone_no = @phone_no

where auth_token = @auth_token

IF ((SELECT @@IDENTITY) > 0)
     
	 BEGIN
		Select '1' as success ,'Success' as response_message 
     END  
 Else 
	
	 BEGIN
		Select '0' as success ,'Update Connection Error' as response_message 
     END  

END


