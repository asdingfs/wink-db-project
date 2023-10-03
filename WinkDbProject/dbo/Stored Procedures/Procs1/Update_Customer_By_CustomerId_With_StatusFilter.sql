CREATE PROCEDURE [dbo].[Update_Customer_By_CustomerId_With_StatusFilter]
	(@customer_id varchar(100),
	 @first_name varchar(50),
	 @last_name varchar(50),
	 @email varchar(50),
	 @date_of_birth date,
	 @password varchar(100),
	 @gender varchar(10),
	 @updated_at datetime,
	 @can_id1 varchar(50),
	 @can_id2 varchar(50),
	 @can_id3 varchar(50),
	 @can_id1_key varchar(50),
	 @can_id2_key varchar(50),
	 @can_id3_key varchar(50),
	 @status varchar(50)
	 )
AS
BEGIN
DECLARE @intErrorCode INT
	
	BEGIN TRAN
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
                updated_at=@updated_at,
                status= @status
                Where customer.customer_id = @customer_id
                
                SELECT @intErrorCode = @@ERROR
				IF (@intErrorCode <> 0) GOTO ERROR
			
			END
			ELSE
				BEGIN
				
				UPDATE customer SET 
				first_name =@first_name ,
                last_name=@last_name,
                email=@email,
                gender=@gender,
                date_of_birth=@date_of_birth,
                updated_at=@updated_at,
                status= @status 
                Where customer.customer_id = @customer_id
                SELECT @intErrorCode = @@ERROR
				IF (@intErrorCode <> 0) GOTO ERROR
				
				END
			
			-- Update CAN ID 1
			
				IF @can_id1_key IS NOT NULL AND @can_id1_key !=''
				-- Check CAN ID
				BEGIN
				IF NOT EXISTS(SELECT * from can_id where can_id.customer_canid = @can_id1 and can_id.can_id_key !=@can_id1_key)
					BEGIN
					 UPDATE can_id SET customer_canid=@can_id1 , can_id_key = @can_id1 , updated_at = @updated_at WHERE can_id_key = @can_id1_key
						SELECT @intErrorCode = @@ERROR
						IF (@intErrorCode <> 0) GOTO ERROR
					END
				END
				
				IF @can_id2_key IS NOT NULL AND @can_id2_key !=''
				-- Check CAN ID 2
				BEGIN
				IF NOT EXISTS(SELECT * from can_id where can_id.customer_canid = @can_id2 and can_id.can_id_key !=@can_id2_key)
					BEGIN
					 UPDATE can_id SET customer_canid=@can_id2 , can_id_key = @can_id2 , updated_at = @updated_at WHERE can_id_key = @can_id2_key
						SELECT @intErrorCode = @@ERROR
						IF (@intErrorCode <> 0) GOTO ERROR
					END
				END
			
	
				IF @can_id3_key IS NOT NULL AND @can_id3_key !=''
				-- Check CAN ID 3
				BEGIN
				IF NOT EXISTS(SELECT * from can_id where can_id.customer_canid = @can_id3 and can_id.can_id_key !=@can_id3_key)
					BEGIN
					 UPDATE can_id SET customer_canid=@can_id3 , can_id_key = @can_id3 , updated_at = @updated_at WHERE can_id_key = @can_id3_key
						SELECT @intErrorCode = @@ERROR
						IF (@intErrorCode <> 0) GOTO ERROR
					END
				END
			
					
			/*IF(@@ROWCOUNT>0)
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
				
				END*/
			IF(@intErrorCode=0)
			COMMIT TRAN
			SELECT '1' as response_code, 'User is successfully updated' As response_message
			
		
		END
		ELSE 
			BEGIN
				SELECT '0' as response_code, 'User is not authorized!' As response_message
		
			END
	
	/*IF(@intErrorCode=0)
	BEGIN
	
	COMMIT TRAN
	
	END*/
	
	ERROR:
	IF (@intErrorCode <> 0) 
	BEGIN
	ROLLBACK TRAN
	Select '0' as success , 'Fail to update' as response_message
	RETURN
    
    END
	
	
END

