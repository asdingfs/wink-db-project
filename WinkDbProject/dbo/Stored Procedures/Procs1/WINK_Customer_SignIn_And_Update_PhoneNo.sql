CREATE PROCEDURE [dbo].[WINK_Customer_SignIn_And_Update_PhoneNo] 
	(@email varchar(255),
	 @password varchar(255),
	  @phone_no varchar(10)
	 )
AS
BEGIN
DECLARE @currentDate Datetime
DECLARE @org_auth varchar(255)
DECLARE @login_datetime varchar(50)
-- Check Customer Phone No

IF EXISTS (Select * from customer where customer.email=@email and customer.phone_no is not null and customer.phone_no !='')
BEGIN
Print('001')
Select '0' as  response_code , 'Your mobile no. is already registered.' as response_message
END
ELSE
BEGIN
IF EXISTS (Select * from customer where customer.email =@email)
BEGIN
	Print('002')
	IF EXISTS ( Select * from customer where Lower(customer.email) = Lower(@email) and password = @password)
	BEGIN
	Print('003')
	IF EXISTS ( Select * from customer where Lower(customer.email) = Lower(@email) and password = @password and status='enable')
	
	BEGIN
	Print('004')
		-- Check Mobile No
		-- Check Phone No.
		IF NOT EXISTS (Select * from customer where customer.phone_no =@phone_no)
		BEGIN
		Print('005')
	-- Check customer authentication token
	Set @org_auth = (Select auth_token from customer_authentication_token where customer_id = 
	(select customer_id from customer where Lower(customer.email) = Lower(@email) and password = @password))
	
	IF @org_auth is not null and @org_auth !=''
		BEGIN
		Print('006')
			-- Update Customer authentication 
			EXEC GET_CURRENT_SINGAPORT_DATETIME @currentDate output
			SET @login_datetime=Replace(Replace(Replace(CONVERT(VARCHAR(24), @currentDate, 121),' ',''),'.',''),':','')
			Update customer set customer.auth_token = concat(@org_auth,@login_datetime),
			phone_no =@phone_no 
			where customer.email = @email and password = @password
		END
	ELSE
	BEGIN
	Print('007')
		-- Insert into customer orgin authen before update
			insert into customer_authentication_token  (auth_token, customer_id)
			select auth_token,customer_id from customer
			where Lower(customer.email) = Lower(@email) and password = @password
			
		-- Update Customer authentication 
			EXEC GET_CURRENT_SINGAPORT_DATETIME @currentDate output
			SET @login_datetime=Replace(Replace(Replace(CONVERT(VARCHAR(24), @currentDate, 121),' ',''),'.',''),':','')

			Update customer set customer.auth_token = concat(customer.auth_token,@login_datetime),
			phone_no =@phone_no  
			where customer.email = @email and password = @password
	END
	-- insert into customer sub activation status 
	insert into customer_login_withPasswordAndPhone(customer_id,created_at)
	select customer.customer_id,GETDATE() from customer where Lower(customer.email) = Lower(@email) and password = @password and status='enable'
	-- Insert into customer login action log
	Insert into customer_login_action_log (auth_token, customer_id, created_at)
	select auth_token,customer_id,@currentDate from customer
	where Lower(customer.email) = Lower(@email) and password = @password
	    
    Select customer_id , auth_token, email,status,phone_no, '1' as  response_code , 'Valid Login' as response_message from customer where Lower(customer.email) = Lower(@email) and password = @password
    
	--select concat(customer.auth_token,Replace(CONVERT(VARCHAR(24), GETDATE(), 121),' ','')) from customer where customer.email= 'nangnonkham@smrt.com.sg'
		END
		
		ELSE
		BEGIN
			Select '0' as  response_code , 'Mobile No. already in use' as response_message
		END
		
		
		
	END
	
	
	ELSE
	BEGIN
		Select '0' as  response_code , 'Your account is locked.Contact customer service' as response_message

	
	END
	
	END
	
	ELSE 
	BEGIN
	Select '0' as  response_code , 'Invalid Password' as response_message
	
	END
		
END
ELSE
BEGIN
	Select '2' as  response_code , 'Email does not exist' as response_message
END

END
	
END

--update customer set customer.phone_no='' where customer.email='nnk005@gmail.com'
 

--select * from customer where customer.email='nnk005@gmail.com'