CREATE PROCEDURE [dbo].[User_SignIn_With_Phone]
	(@email varchar(100),
	 @password varchar(150),
	 @phone_no varchar(10)
	 )
AS	 
BEGIN

DECLARE @existing_mobile int

IF EXISTS (Select * from customer where customer.email =@email and password =@password )
BEGIN

IF EXISTS (Select * from customer where customer.email =@email and password =@password and customer.status='enable')
	BEGIN
Print('Account Exists')
SET @existing_mobile = ISNULL((Select customer.phone_no from customer where customer.email = @email),0)

	-- Check already have phone number
	
	IF (@existing_mobile !=0)
		BEGIN
		Print('Mobile Exists')
	IF EXISTS (Select * from customer where customer.email= @email and customer.password = @password and customer.phone_no= @phone_no and customer.status='enable')
		BEGIN
			Select customer.customer_id,customer.auth_token,'1' as success ,'Valid User' as response_message from customer where customer.email= @email and customer.password = @password and customer.phone_no= @phone_no
			and customer.status='enable'
			
		END
	
	ELSE 
		BEGIN
			Select '0' as success ,'Invalid phone no' as response_message 
		END
		END
	ELSE IF (@existing_mobile =0)
	Print('Mobile Not Exists')
	-- EXISTS (Select * from customer where customer.email= @email and customer.password = @password and customer.phone_no='' and customer.status='enable')
		BEGIN
		
			IF NOT EXISTS (select * from customer where customer.phone_no =@phone_no)
				BEGIN
			Print('Mobile NOT Already Used')
			Update customer set phone_no = @phone_no where customer.email= @email and customer.password = @password 
		    IF(@@ROWCOUNT>0)
		    Select customer.customer_id,customer.auth_token,'1' as success ,'Valid User' as response_message from customer where customer.email= @email and customer.password = @password and customer.phone_no= @phone_no and customer.status='enable'
				END
			ELSE 
				BEGIN
					Select '0' as success ,'Phone No already in use' as response_message 
				END
		END
	END
	ELSE 
	BEGIN
			--Select * from customer where customer.email =@email and password =@password
			Select '0' as success ,'Your account has been locked ' as response_message 
	END
		
	END
	ELSE
	BEGIN
			--Select * from customer where customer.email =@email and password =@password
			Select '0' as success ,'Invalid email or password ' as response_message 
	END
		
	
	/*ELSE IF EXISTS (Select * from customer where customer.email != @email  and customer.phone_no=@phone_no)
		BEGIN
			Select '0' as success ,'Phone No already in use' as response_message 
		END
	ELSE
		BEGIN
			Select * from customer where customer.email= @email and customer.password = @password and customer.phone_no=@phone_no and customer.status='enable'
		END*/
		
	END


--select * from customer where customer.email like 'popo'+'%'