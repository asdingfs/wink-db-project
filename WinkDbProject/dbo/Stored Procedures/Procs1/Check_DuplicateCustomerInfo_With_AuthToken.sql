CREATE PROCEDURE [dbo].[Check_DuplicateCustomerInfo_With_AuthToken]
	(@auth_token varchar(255),
	 @email varchar(150),
	 @phone_no varchar(10)
	
	)
AS
BEGIN
     
    IF EXISTS (SELECT * FROM customer WHERE customer.phone_no = @phone_no and customer.auth_token != @auth_token)
    BEGIN
		SELECT '0' as success , 'Mobile number already in use' as response_message
    END
    ELSE IF EXISTS (SELECT * FROM customer where customer.email = @email and customer.auth_token != @auth_token)
	BEGIN
		SELECT '0' as success , 'Email is already in use.Please key in new email.' as response_message
    END
   
    ELSE
    BEGIN
		SELECT '1' as success , 'Valid Data' as response_message
    END
    
	
END

