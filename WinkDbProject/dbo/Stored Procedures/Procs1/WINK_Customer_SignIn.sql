CREATE PROCEDURE [dbo].[WINK_Customer_SignIn] 
	(@email varchar(255),
	 @password varchar(255)
	 )
AS
BEGIN
DECLARE @currentDate Datetime
DECLARE @org_auth varchar(255)
DECLARE @login_datetime varchar(50)

IF EXISTS (Select * from customer where customer.email =@email)
BEGIN
	
	IF EXISTS ( Select * from customer where Lower(customer.email) = Lower(@email) and password = @password)
	BEGIN
	
	IF EXISTS ( Select * from customer where Lower(customer.email) = Lower(@email) and password = @password and status='enable')
	BEGIN
	-- Check customer authentication token
	Set @org_auth = (Select auth_token from customer_authentication_token where customer_id = 
	(select customer_id from customer where Lower(customer.email) = Lower(@email) and password = @password))
	
	IF @org_auth is not null and @org_auth !=''
		BEGIN
			-- Update Customer authentication 
			EXEC GET_CURRENT_SINGAPORT_DATETIME @currentDate output
			SET @login_datetime=Replace(Replace(Replace(CONVERT(VARCHAR(24), @currentDate, 121),' ',''),'.',''),':','')
			Update customer set customer.auth_token = concat(@org_auth,@login_datetime) 
			where customer.email = @email and password = @password
		END
	ELSE
	BEGIN
		-- Insert into customer orgin authen before update
			insert into customer_authentication_token  (auth_token, customer_id)
			select auth_token,customer_id from customer
			where Lower(customer.email) = Lower(@email) and password = @password
			
		-- Update Customer authentication 
			EXEC GET_CURRENT_SINGAPORT_DATETIME @currentDate output
			SET @login_datetime=Replace(Replace(Replace(CONVERT(VARCHAR(24), @currentDate, 121),' ',''),'.',''),':','')

			Update customer set customer.auth_token = concat(customer.auth_token,@login_datetime) 
			where customer.email = @email and password = @password
	END
	-- Insert into customer login action log
	Insert into customer_login_action_log (auth_token, customer_id, created_at)
	select auth_token,customer_id,@currentDate from customer
	where Lower(customer.email) = Lower(@email) and password = @password

		IF EXISTS (select 1 from customer where customer.email = @email and 
			group_id !=6 and group_id != 10 and group_id !=14 and group_id !=13 and group_id !=2)
				BEGIN

				update customer set group_id =14 where customer.email = @email

				END
	    
    Select customer_id , auth_token, email,status,phone_no, '1' as  response_code , 'Valid Login' as response_message from customer where Lower(customer.email) = Lower(@email) and password = @password
    
	--select concat(customer.auth_token,Replace(CONVERT(VARCHAR(24), GETDATE(), 121),' ','')) from customer where customer.email= 'nangnonkham@smrt.com.sg'

	END
	ELSE
	BEGIN
		Select '0' as  response_code , 'Your account is locked. Please contact customer service.' as response_message

	
	END
	
	END
	
	ELSE 
	BEGIN
	Select '0' as  response_code , 'Invalid Password' as response_message
	
	END
		
END
ELSE
BEGIN
	Select '2' as  response_code , 'Invalid Email' as response_message
END

	
END
 