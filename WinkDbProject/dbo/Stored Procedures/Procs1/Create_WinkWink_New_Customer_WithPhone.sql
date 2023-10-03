CREATE Procedure [dbo].[Create_WinkWink_New_Customer_WithPhone]
(
@first_name varchar(150),
@last_name varchar(150),
@email varchar(150),
@password varchar(255),
@gender varchar (10),
@dob varchar(50),
@auth_token varchar(255),
@imob_customer_id int,
@created_at DateTime,
@updated_at DateTime,
@phone_no varchar(10)

)

AS 
BEGIN
DECLARE @customer_id int 
DECLARE @insert int 
-- Check already Not registered from iMOB
IF NOT EXISTS (SELECT * FROM customer WHERE LOWER(customer.email) = LOWER(@EMAIL))
	BEGIN
		IF NOT EXISTS (SELECT * FROM customer WHERE customer.phone_no= @phone_no)
			BEGIN
			INSERT INTO customer
           ([first_name]
           ,[last_name]
           ,[email]
           ,[password]
           ,[gender]
           ,[date_of_birth]
           ,[auth_token]
           ,[imob_customer_id]
           ,[created_at]
           ,[updated_at]
           ,[phone_no]
           )
			 VALUES
			 (
               
		@first_name ,
		@last_name ,
		@email ,
		@password ,
		@gender ,
		@dob ,
		@auth_token ,
		@imob_customer_id,
		@created_at ,
		@updated_at,
		@phone_no
		)
		

		SET @insert = @@ROWCOUNT
		PRINT(@INSERT)
		If @insert>0
			BEGIN
				SET @insert =0
				print('aaa')
				Set @customer_id = (Select SCOPE_IDENTITY())
				INSERT INTO master_user_group_relationship (master_group_id,email)
				VALUES (2, @email)
            SET @insert = @@ROWCOUNT
			IF @insert>0
			BEGIN
				print('bbb')

				SELECT '1' AS response_code , customer.auth_token, customer.customer_id from customer
				Where customer.customer_id =@customer_id
			
				RETURN
	
			END
			ELSE 
				BEGIN 
				SELECT '0' AS response_code, 'Insert Fail' As response_message
				RETURN
				END
			END
			ELSE 
			BEGIN
			
			SELECT '0' AS response_code, 'Insert Fail' As response_message
			RETURN
			END
			END
			ELSE
				BEGIN
				SELECT '0' AS response_code, 'Phone no already exists' As response_message
				RETURN
				END
					
	END 
-- Check already registerd from iMOB and Update phone no
ELSE IF EXISTS (SELECT * FROM customer WHERE LOWER(customer.email) = LOWER(@EMAIL) and customer.customer_id = @imob_customer_id) 
	
		BEGIN
		
		IF NOT EXISTS (Select * from customer where customer.phone_no = @phone_no)
		BEGIN
		Update customer set customer.phone_no = @phone_no WHERE LOWER(customer.email) = LOWER(@EMAIL) and customer.customer_id = @imob_customer_id
		/*SELECT '0' AS response_code, 'Email already exists' As response_message
			RETURN*/
			
		IF @@ROWCOUNT > 0
		
			BEGIN
				SELECT '1' AS response_code , customer.auth_token, customer.customer_id from customer customer WHERE LOWER(customer.email) = LOWER(@EMAIL) and customer.customer_id = @imob_customer_id
				return 		
			END
		ELSE
			BEGIN
				SELECT '0' AS response_code, 'Insert Phone No Fail' As response_message , '0' As auth_token
				RETURN
			END
		END
		ELSE 
			SELECT '0' AS response_code, 'Insert Phone No Fail' As response_message , '0' As auth_token
			RETURN
		END 
END




