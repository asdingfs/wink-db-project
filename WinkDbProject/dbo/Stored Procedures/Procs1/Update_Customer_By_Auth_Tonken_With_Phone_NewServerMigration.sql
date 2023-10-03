CREATE PROCEDURE [dbo].[Update_Customer_By_Auth_Tonken_With_Phone_NewServerMigration]
	(@token_id varchar(255),
	 @first_name varchar(50),
	 @last_name varchar(50),
	 @email varchar(50),
	 @date_of_birth date,
	 @password varchar(100),
	 @gender varchar(10),
	 @updated_at datetime,
	 @phone_no varchar(15),
	 @customer_password varchar(50)
	 )
AS
BEGIN
DECLARE @CUSTOMER_ID INT 
DECLARE @OLD_EMAIL VARCHAR(50)
	IF EXISTS (SELECT customer.customer_id FROM CUSTOMER WHERE LTRIM(RTRIM(customer.auth_token)) = @token_id)
		BEGIN
		
		--Check Existing Email 
		
		--SET @OLD_EMAIL = (SELECT CUSTOMER.email FROM customer WHERE LTRIM(RTRIM(customer.auth_token)) = @token_id)	
		IF NOT EXISTS (Select * from customer where customer.email = @email and LTRIM(RTRIM(customer.auth_token)) 
		!= @token_id)
		BEGIN
		
		
			-- Check Phone No
			IF NOT EXISTS (Select * from customer where customer.phone_no = @phone_no and LTRIM(RTRIM(customer.auth_token)) != @token_id)
				BEGIN
				IF (@password IS NOT NULL AND @password !='')
				
					BEGIN
						UPDATE customer SET 
						first_name =@first_name ,
						last_name=@last_name,
						email=@email,
						customer.password=@password,
						gender=@gender,
						date_of_birth=@date_of_birth,
						updated_at=@updated_at,
						phone_no = @phone_no,
						customer_password =@customer_password
						Where LTRIM(RTRIM(customer.auth_token)) = @token_id
					
					END
					ELSE
						BEGIN
						
						UPDATE customer SET 
						first_name =@first_name ,
						last_name=@last_name,
						email=@email,
						gender=@gender,
						date_of_birth=@date_of_birth,
						updated_at=@updated_at,phone_no = @phone_no
						Where LTRIM(RTRIM(customer.auth_token)) = @token_id
						
						END
						
						IF (@@ROWCOUNT>0)
						SELECT '1' as response_code, 'Successfully saved' As response_message
						else 
						SELECT '0' as response_code, 'Fail to save' As response_message
						
				END
			ELSE
				BEGIN
				
					SELECT '0' as response_code, 'Mobile no. already in use' As response_message
				
				END
			
		END
			Else
			
			BEGIN
				SELECT '0' as response_code, 'Email already in use' As response_message
			
			END
					
		END
		ELSE 
			BEGIN
				--SELECT '0' as response_code, 'User is not authorized!' As response_message
				SELECT '2' as response_code, 'Multiple Logins not allowed.' As response_message
		
			END
	
END

