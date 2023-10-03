CREATE PROCEDURE [dbo].[Update_Customer_Password_By_Auth_Token_NewserverMigration]
	(@tonken_id varchar(100),
	 @password varchar(100),
	 @customer_password varchar(100)
	 )
AS
BEGIN

	IF EXISTS (SELECT * FROM customer WHERE customer.auth_token =@tonken_id)
		BEGIN
			Update customer set password = @password,customer_password =@customer_password where auth_token = @tonken_id
		IF(@@ROWCOUNT >0)
		BEGIN
		    
			SELECT '1' AS RESPONSE_CODE , 'Your password have been saved!' as response_message,
			CUSTOMER.email,CUSTOMER.imob_customer_id 
			FROM customer
			WHERE customer.auth_token = @tonken_id
		END
		ELSE 
		BEGIN
		
			SELECT '0' AS RESPONSE_CODE , 'Fail to save password!' as response_message
		END
		
		END
		
		
	ELSE 
		BEGIN
			SELECT '0' AS RESPONSE_CODE , 'User is not authorized!' as response_message
		
		END
		
		
		
		
END
