Create PROCEDURE [dbo].[Create_WINK_App_Customer_Action_Log]
	(@customer_id int,
	 @ip_address varchar(20),
	 @customer_action varchar(50),
	 @token_id varchar(100)
	 )
AS
BEGIN
    Declare @current_datetime datetime
    Declare @email varchar(100)
    
    IF (@token_id !='' and @token_id IS NOT NULL)
    BEGIN
     Set @email = (Select customer.email from customer where customer.auth_token =@token_id)
     Set @customer_id = (Select customer.customer_id from customer where customer.auth_token =@token_id)
    END
    ELSE IF(@customer_id !=0 and @customer_id !='' and @customer_id IS NOT NULL)
    BEGIN
    Set @email = (Select customer.email from customer where customer.customer_id =@customer_id)
    
    END
    
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime Output
	Insert into wink_app_customer_action_log (customer_id, email ,ip_address, customer_action,token_id,created_at)
	Values (@customer_id,@email,@ip_address,@customer_action,@token_id,@current_datetime)

	

END








	