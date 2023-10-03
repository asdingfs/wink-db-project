CREATE Procedure [dbo].[Create_WinkWink_New_Customer_With_GroupId]
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
@group_id int

)

AS 
BEGIN
DECLARE @customer_id int 
DECLARE @insert int 

If (@dob is null or @dob ='')
Set @dob =null

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
           ,[updated_at]
		   ,group_id
		   ,customer_unique_id)
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
		@group_id,
		@auth_token
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

				--SELECT '1' AS response_code , @customer_id AS customer_id
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
				  ,'1' AS response_code
			  FROM [dbo].[customer]
			  where email =@email


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
