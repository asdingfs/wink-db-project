CREATE PROCEDURE [dbo].[Update_Customer_By_CustomerId]
	(@customer_id varchar(100),
	 @first_name varchar(50),
	 @last_name varchar(50),
	 @email varchar(50),
	 @date_of_birth date,
	 @password varchar(100),
	 @gender varchar(10),
	 @updated_at datetime
	 )
AS
BEGIN
	IF EXISTS (SELECT customer.customer_id FROM CUSTOMER WHERE customer.customer_id = @customer_id)
		BEGIN
		DECLARE @OLD_EMAIL VARCHAR(50)
	
		IF (@password IS NOT NULL AND @password !='')
		
			BEGIN
				UPDATE customer SET 
				first_name =@first_name ,
                last_name=@last_name,
                email=@email,
                customer.password=@password,
                gender=@gender,
                date_of_birth=@date_of_birth,
                updated_at=@updated_at
                Where customer.customer_id = @customer_id
			
			END
			ELSE
				BEGIN
				
				UPDATE customer SET 
				first_name =@first_name ,
                last_name=@last_name,
                email=@email,
                gender=@gender,
                date_of_birth=@date_of_birth,
                updated_at=@updated_at
                Where customer.customer_id = @customer_id
				
				END
			IF(@@ROWCOUNT>0)
				BEGIN
					 IF(LTRIM(RTRIM(@email))!=LTRIM(RTRIM(@old_email)))
						BEGIN
							UPDATE master_user_group_relationship SET email = @email WHERE email = @old_email
						END
					SELECT '1' AS response_code , 'User data is successfully updated!' As response_message
				END
			ELSE
			
				BEGIN
					SELECT '1' AS response_code , 'Fail to update user data!' As response_message
				
				END
			
			
		
		END
		ELSE 
			BEGIN
				SELECT '0' as response_code, 'User is not authorized!' As response_message
		
			END
	
END
