CREATE Procedure [dbo].[Create_WinkWink_New_Customer]
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
@updated_at DateTime

)

AS 
BEGIN
DECLARE @customer_id int 
DECLARE @insert int 
IF NOT EXISTS (SELECT * FROM customer WHERE LOWER(customer.email) = LOWER(@EMAIL))
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
           ,[updated_at])
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
		@updated_at 
		)
		
		
		
		--SELECT '1' AS response_code, 'Insert Fail' As response_message

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

				SELECT '1' AS response_code , @customer_id AS customer_id
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
		SELECT '0' AS response_code, 'Email already exists' As response_message
			RETURN
			
		
		END 
END
