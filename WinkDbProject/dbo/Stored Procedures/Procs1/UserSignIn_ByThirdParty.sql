CREATE PROCEDURE [dbo].[UserSignIn_ByThirdParty] 
	(@email varchar(255),
	 @password varchar(255),
	 @ip_address varchar(20)
	 )
AS
BEGIN
DECLARE @currentDate Datetime
DECLARE @org_auth varchar(255)
DECLARE @login_datetime varchar(50)
DECLARE @customer_id int

EXEC GET_CURRENT_SINGAPORT_DATETIME @currentDate output
 IF EXISTS (Select 1 from wink_customer_block_ip where ip_address= @ip_address)
    BEGIN
		SELECT 'blockip' as response_code , 'Fail to sign in' as response_message
		
		Return
    END
    -- Check Number of Login with invalid password
 ELSE IF EXISTS ( Select 1 from customer where Lower(customer.email) = Lower(@email) and password != @password)
     BEGIN
    
          SET @customer_id = (Select c.customer_id from customer as c where c.email = @email)
                            
          -- Insert into log 
          Insert into wink_customer_login_log (created_at,customer_action,customer_id,ip_address,login_from)
          values (@currentDate,'Invalid Login',@customer_id,@ip_address,'Connect')
          -- Check Invalid Time
          IF EXISTS (Select 1 from wink_customer_login_log as a  where CAST(a.created_at as DATE)= 
			CAST(@currentDate as date) and a.customer_id = @customer_id
			group by customer_id having COUNT(*)>=6)
 			
					BEGIN
				   /*  Insert into wink_customer_login_log (created_at,customer_action,customer_id,ip_address)
					  values (@currentDate,'Disable',@customer_id,@ip_address)*/
					-- Disable the customer account 
	    
					Update customer set customer.status = 'disable',updated_at=@currentDate where customer.customer_id = @customer_id
					Insert into System_Log (customer_id, action_status,created_at,reason)
					Select @customer_id,'disable',@currentDate,'invalid_login'
			    
					SELECT '0' as response_code , 'Your account has been locked' as response_message
		
					Return
					END
		  ELSE
		  BEGIN
		  SELECT '0' as response_code , 'Invalid email or password' as response_message
		  Return
		  END
    END
    
 ELSE
 BEGIN

	IF EXISTS (Select 1 from customer where customer.email =@email)
    BEGIN
	
	IF EXISTS ( Select 1 from customer where Lower(customer.email) = Lower(@email) and password = @password)
	BEGIN
	
	IF EXISTS ( Select 1 from customer where Lower(customer.email) = Lower(@email) and password = @password and status='enable')
	BEGIN
  -- Check customer authentication token

  	EXEC GET_CURRENT_SINGAPORT_DATETIME @currentDate output
	SET @login_datetime=Replace(Replace(Replace(CONVERT(VARCHAR(24), @currentDate, 121),' ',''),'.',''),':','')
	
	-- Insert into customer login action log
	Insert into customer_login_action_log (auth_token, customer_id, created_at)
	select concat(customer.auth_token,@login_datetime,'_Connect') ,customer_id,@currentDate from customer
	where Lower(customer.email) = Lower(@email) and password = @password


	SELECT [customer_id]
      ,[first_name]
      ,[last_name]
      ,[email]
      ,[password]
      ,[gender]
      ,[date_of_birth]
      ,[auth_token]
      ,[created_at]
      ,[updated_at]
      ,[imob_customer_id]
      ,[phone_no]
      ,[status]
      ,[group_id]
      ,[confiscated_wink_status]
      ,[subscribe_status]
      ,[confiscated_points_status]
      ,[sign_in_status]
      ,[customer_password]
      ,[avatar_id]
      ,[avatar_image]
      ,[ip_address]
      ,[ip_scanned]
      ,[skin_name]
      ,[team_id]
      ,[nick_name]
      ,[updated_password_date]
      ,[customer_unique_id]
      , '1' as  response_code , 'Valid Login' as response_message from customer where Lower(customer.email) = Lower(@email) and password = @password
    
	

	END
	ELSE
	BEGIN
		Select '0' as  response_code , 'Your account is locked.Contact WINK customer service' as response_message

	
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
	
END



