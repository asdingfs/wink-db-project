

CREATE PROCEDURE [dbo].[Update_Customer_By_CustomerId_With_Points_WINK_Confiscated]
	(@customer_id varchar(100),
	 @first_name varchar(50),
	 @last_name varchar(50),
	 @nickname varchar(30),
	 @email varchar(100),
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
	 @status varchar(50),
	 @group_id varchar(10),
	 @confiscate_wink_Status varchar(10),
	 @phone_no varchar(100),
	 @confiscate_points varchar(10)
	 )
AS
BEGIN
DECLARE @intErrorCode INT
DECLARE @existingEmail int
DECLARE @error_code int

If (@date_of_birth is null or @date_of_birth ='')
Set @date_of_birth =null

	BEGIN TRAN
	TRY
		
	IF EXISTS (SELECT customer.customer_id FROM CUSTOMER WHERE customer.customer_id = @customer_id)
		BEGIN
		
		--Check Existing Email
	IF NOT EXISTS (SELECT * FROM customer WHERE customer.email = @email and customer.customer_id !=@customer_id) 
		BEGIN 
		-- Check Phone Number
		IF (@phone_no IS NOT NULL and @phone_no !='')
			IF EXISTS (SELECT * FROM customer WHERE customer.phone_no = @phone_no and customer.customer_id !=@customer_id) 
			BEGIN
			SET @error_code = 1
			GOTO ERROR 
			
			END
		
		DECLARE @OLD_EMAIL VARCHAR(50)
	
		IF (@password IS NOT NULL AND @password !='')
		
			BEGIN
				UPDATE customer SET 
				first_name =@first_name ,
                last_name=@last_name,
				nick_name = @nickname,
                email=@email,
                customer.password=@password,
                gender=@gender,
                date_of_birth=@date_of_birth,
                updated_at=@updated_at,
                status= @status,
                --group_id = @group_id,
                confiscated_wink_status = @confiscate_wink_Status,
				confiscated_points_status = @confiscate_points
                ,phone_no =@phone_no
                
                Where customer.customer_id = @customer_id
                
                SELECT @intErrorCode = @@ERROR
				IF (@intErrorCode <> 0) GOTO ERROR
			
			END
			ELSE
				BEGIN
				
				UPDATE customer SET 
				first_name =@first_name ,
                last_name=@last_name,
				nick_name = @nickname,
                email=@email,
                gender=@gender,
                date_of_birth=@date_of_birth,
                updated_at=@updated_at,
                status= @status,
               -- group_id = @group_id,
                confiscated_wink_status = @confiscate_wink_Status,
				confiscated_points_status = @confiscate_points,
                phone_no =@phone_no
                Where customer.customer_id = @customer_id
                SELECT @intErrorCode = @@ERROR
				IF (@intErrorCode <> 0) GOTO ERROR
				
				END
			
			-- Update CAN ID 1
			
				IF (@can_id1_key IS NOT NULL AND @can_id1_key !='')
				-- Check CAN ID
				BEGIN
					IF (@can_id1!='' AND @can_id1_key!='')
					BEGIN
						IF NOT EXISTS(SELECT * from can_id where can_id.customer_canid = @can_id1 and can_id.can_id_key !=@can_id1_key)
							BEGIN
							 UPDATE can_id SET customer_canid=@can_id1 , can_id_key = @can_id1 , updated_at = @updated_at ,status =@status WHERE can_id_key = @can_id1_key
							 and can_id.customer_id = @customer_id	
								SELECT @intErrorCode = @@ERROR
								IF (@intErrorCode <> 0) GOTO ERROR
							END
					END
					ELSE IF @can_id1 ='' AND @can_id1_key!=''
					BEGIN
						DELETE From can_id where can_id_key=@can_id1_key and can_id.customer_id =@customer_id
						SELECT @intErrorCode = @@ERROR
						IF (@intErrorCode <> 0) GOTO ERROR
					END
				END
				
				IF @can_id2_key IS NOT NULL AND @can_id2_key !=''
				-- Check CAN ID
				BEGIN
				IF @can_id2!='' AND @can_id2_key!=''
					BEGIN
				IF NOT EXISTS(SELECT * from can_id where can_id.customer_canid = @can_id2 and can_id.can_id_key !=@can_id2_key)
					BEGIN
					 UPDATE can_id SET customer_canid=@can_id2 , can_id_key = @can_id2 , updated_at = @updated_at ,status =@status WHERE can_id_key = @can_id2_key
					 and can_id.customer_id = @customer_id	
						SELECT @intErrorCode = @@ERROR
						IF (@intErrorCode <> 0) GOTO ERROR
					END
					END
				ELSE IF @can_id2 ='' AND @can_id2_key!=''
					BEGIN
					DELETE From can_id where can_id_key=@can_id2_key and can_id.customer_id =@customer_id
					SELECT @intErrorCode = @@ERROR
					IF (@intErrorCode <> 0) GOTO ERROR
					END
				END
			
				IF @can_id3_key IS NOT NULL AND @can_id3_key !=''
				-- Check CAN ID
				BEGIN
				IF @can_id3!='' AND @can_id3_key!=''
					BEGIN
				IF NOT EXISTS(SELECT * from can_id where can_id.customer_canid = @can_id3 and can_id.can_id_key !=@can_id3_key)
					BEGIN
					 UPDATE can_id SET customer_canid=@can_id3 , can_id_key = @can_id3 , updated_at = @updated_at ,status =@status WHERE can_id_key = @can_id3_key
					 and can_id.customer_id = @customer_id	
						SELECT @intErrorCode = @@ERROR
						IF (@intErrorCode <> 0) GOTO ERROR
					END
					END
				ELSE IF @can_id3 ='' AND @can_id3_key!=''
					BEGIN
					DELETE From can_id where can_id_key=@can_id3_key and can_id.customer_id =@customer_id
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
			BEGIN
			SELECT '1' as response_code, 'User is successfully updated' As response_message
			COMMIT TRAN
			END
			
		END
		ELSE 
			BEGIN
				SELECT '0' as response_code, 'Email already exists!' As response_message
				ROLLBACK TRAN
		
			END
		END
		ELSE 
			BEGIN
			SELECT '0' as response_code, 'User is not authorized!' As response_message
			ROLLBACK TRAN
			
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
    ELSE IF (@error_code=1)
    BEGIN
	ROLLBACK TRAN
	Select '0' as success , 'Phone No. already in use' as response_message
	RETURN 
    
    END
	
	
END




