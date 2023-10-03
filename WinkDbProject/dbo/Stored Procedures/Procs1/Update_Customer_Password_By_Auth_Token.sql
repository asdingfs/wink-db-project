CREATE PROCEDURE [dbo].[Update_Customer_Password_By_Auth_Token]
	(@tonken_id varchar(100),
	 @password varchar(100)
	 )
AS
BEGIN

	IF EXISTS (SELECT * FROM customer WHERE customer.auth_token =@tonken_id)
	BEGIN
		Update customer 
		set password = @password 
		where auth_token = @tonken_id;

		IF(@@ROWCOUNT >0)
		BEGIN
			SELECT '1' AS RESPONSE_CODE , 'Your password has been reset successfully!' as response_message
			--CUSTOMER.email,CUSTOMER.imob_customer_id 
			--FROM customer
			--WHERE customer.auth_token = @tonken_id
		END
		ELSE 
		BEGIN
			SELECT '0' AS RESPONSE_CODE , 'An error occurred. Please try again!' as response_message
		END
		
	END
	ELSE 
	BEGIN
		SELECT '0' AS RESPONSE_CODE , 'This page has expired. If you still wish to reset your password, please request for password reset via WINK+ app -> Forgot Password.' as response_message
		
	END
END
