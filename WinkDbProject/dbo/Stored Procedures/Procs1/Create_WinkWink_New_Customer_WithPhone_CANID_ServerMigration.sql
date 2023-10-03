﻿CREATE Procedure [dbo].[Create_WinkWink_New_Customer_WithPhone_CANID_ServerMigration]
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
@phone_no varchar(10),
@can_id varchar(20),
@status varchar(10),
@group_id varchar(10),
@subscribe_status varchar(5),
@customer_password varchar(50)
)

AS 
BEGIN
DECLARE @customer_id int 
DECLARE @insert int 
DECLARE @intErrorCode INT
DECLARE @RETURN_NO VARCHAR(10)
	BEGIN TRAN
	TRY
		
-- Check already Not registered from iMOB
IF NOT EXISTS (SELECT * FROM customer WHERE LOWER(customer.email) = LOWER(@EMAIL))
	BEGIN
		IF NOT EXISTS (SELECT * FROM customer WHERE customer.phone_no= @phone_no)
			BEGIN
					INSERT INTO customer
				   ([first_name] ,[last_name],[email],[password] ,[gender] ,[date_of_birth] ,[auth_token]
				     ,[imob_customer_id],[created_at],[updated_at],[phone_no]  ,[status],group_id,subscribe_status,
				     customer_password)
				 	VALUES
					(@first_name,@last_name ,@email ,@password ,@gender ,@dob,@auth_token ,@imob_customer_id,@created_at ,
		             @updated_at,@phone_no,@status,@group_id,@subscribe_status,@customer_password)
				

					-- GET Customer ID to get the info
					 SELECT @intErrorCode = @@ERROR 
					 IF (@intErrorCode <> 0)
					 BEGIN
					 Print('Insert Customer Error')
					 SET @RETURN_NO ='000'
					 GOTO ERROR
					 END
					 ELSE
					 BEGIN
					 Set @customer_id = (Select SCOPE_IDENTITY())
					 Update customer set customer.auth_token =CONCAT(auth_token,@customer_id)
					 where customer.customer_id = @customer_id
					 END
		 		 
				--Check And INSERT CAN ID
		 			
				IF @can_id IS NOT NULL AND @can_id !='' AND @customer_id !=0
				BEGIN
					IF NOT EXISTS (SELECT * from can_id where can_id.customer_canid = @can_id)
						BEGIN
						
							Insert into can_id (customer_canid,can_id_key,created_at,customer_id,status,updated_at)
							Values (@can_id,@can_id,@created_at,@customer_id,@status,@created_at)
							
							SELECT @intErrorCode = @@ERROR
						
							 IF (@intErrorCode <> 0)
								 BEGIN
								 SET @RETURN_NO ='000'
								 Print('Insert CAN ID Fail')
								 GOTO ERROR
								 END
									
						END
					ELSE 
						BEGIN
						SET @RETURN_NO ='003'
							GOTO ERROR
							RETURN
						END
								
				END
					
			END
		ELSE
			BEGIN
			    PRINT('GoTo ERROR1')
				SET @RETURN_NO ='002'
				GOTO ERROR
				RETURN
			END
			
	
	  -- Commit Transaction
	  
	  	IF(@intErrorCode=0)
			BEGIN
		
				SELECT '1' AS success , customer.auth_token, customer.customer_id 
				,'Successfully Registerd' as response_message
				from customer
				Where customer.customer_id =@customer_id
				
				COMMIT TRAN
			
			END
			
					
	END 
	/* Already Registered */
ELSE IF EXISTS(SELECT * FROM customer WHERE LOWER(customer.email) = LOWER(@EMAIL) AND customer.imob_customer_id = @imob_customer_id)
	BEGIN
		IF NOT EXISTS (SELECT * FROM customer WHERE customer.phone_no= @phone_no)
			BEGIN
					Update customer set customer.phone_no = @phone_no,
					 customer.subscribe_status = @subscribe_status,
					 customer.customer_password = @customer_password
					 WHERE LOWER(customer.email) = LOWER(@EMAIL) AND customer.imob_customer_id = @imob_customer_id
					
	
					-- GET Customer ID to get the info
					 SELECT @intErrorCode = @@ERROR 
					 IF (@intErrorCode <> 0)
					 BEGIN
					 Print('Insert Customer Error')
					 SET @RETURN_NO ='000'
					 GOTO ERROR
					 END
					 ELSE
					 Set @customer_id = (Select customer.customer_id FROM customer  WHERE LOWER(customer.email) = LOWER(@EMAIL) AND customer.imob_customer_id = @imob_customer_id)
		 		 
				--Check And INSERT CAN ID
		 			
				IF @can_id IS NOT NULL AND @can_id !='' AND @customer_id !=0
				BEGIN
					IF NOT EXISTS (SELECT * from can_id where can_id.customer_canid = @can_id)
						BEGIN
						
							Insert into can_id (customer_canid,can_id_key,created_at,customer_id,status,updated_at)
							Values (@can_id,@can_id,@created_at,@customer_id,@status,@created_at)
							
							SELECT @intErrorCode = @@ERROR
						
							 IF (@intErrorCode <> 0)
								 BEGIN
								 SET @RETURN_NO ='000'
								 Print('Insert CAN ID Fail')
								 GOTO ERROR
								 END
									
						END
					ELSE 
						BEGIN
						SET @RETURN_NO ='003'
							GOTO ERROR
							RETURN
						END
								
				END
					
			END
		ELSE
			BEGIN
			    PRINT('GoTo ERROR1')
				SET @RETURN_NO ='002'
				GOTO ERROR
				RETURN
			END
			
	
	  -- Commit Transaction
	  
	  	IF(@intErrorCode=0)
			BEGIN
		
				SELECT '1' AS success , customer.auth_token, customer.customer_id 
				,'Successfully Registerd' as response_message
				from customer
				Where customer.customer_id =@customer_id
				
				COMMIT TRAN
			
			END
			
					
	END 
	
	ELSE 
		BEGIN
		SET @RETURN_NO ='001'
		GOTO ERROR
		RETURN
		END	
	
-- Check already registerd from iMOB and Update phone no
     /*   ELSE IF EXISTS (SELECT * FROM customer WHERE LOWER(customer.email) = LOWER(@EMAIL) and customer.imob_customer_id = @imob_customer_id) 
		BEGIN
		
		IF NOT EXISTS (Select * from customer where customer.phone_no = @phone_no)
		BEGIN
		Update customer set customer.phone_no = @phone_no WHERE LOWER(customer.email) = LOWER(@EMAIL) and customer.imob_customer_id= @imob_customer_id
		
		-- Check ERROR
		
		 SELECT @intErrorCode = @@ERROR 
		 IF (@intErrorCode <> 0) GOTO ERROR
		 ELSE
		 SET @customer_id = (SELECT customer.customer_id FROM customer WHERE LOWER(customer.email) = LOWER(@EMAIL) and customer.imob_customer_id= @imob_customer_id)
		 		 
		  --Check And INSERT CAN ID
		 			
				IF @can_id IS NOT NULL AND @can_id !='' AND @customer_id !=0
			
				BEGIN
				IF NOT EXISTS (SELECT * from can_id where can_id.customer_canid = @can_id )
					BEGIN
					
					Insert into can_id (customer_canid,can_id_key,created_at,customer_id,status,updated_at)
					Values (@can_id,@can_id,@created_at,@customer_id,@status,@created_at)
					SELECT @intErrorCode = @@ERROR
					IF (@intErrorCode <> 0) GOTO ERROR
										
					END
					BEGIN
						GOTO ERROR2
					END
								
				END
					
			END
		ELSE
			BEGIN
				GoTo ERROR1
				
				RETURN
			END
			
	
	  -- Commit Transaction
	  
	  	IF(@intErrorCode=0)
			BEGIN
		
				SELECT '1' AS success , customer.auth_token, customer.customer_id 
				,'Successfully Registerd' as response_message
				from customer
				Where customer.customer_id =@customer_id
				
			COMMIT TRAN
			
			END
			
		END
				*/


	                      
ERROR:
	IF(@RETURN_NO='000')
	BEGIN
	IF (@intErrorCode <> 0) 
	BEGIN
	ROLLBACK TRAN
	Select '0' as success , 'Fail to insert' as response_message
	RETURN
    
    END
    END
	ELSE IF (@RETURN_NO ='003')
	
	BEGIN
	ROLLBACK TRAN
	SELECT '0' AS success, 'CARD No. already in use' As response_message
	RETURN
    
	END
	ELSE IF (@RETURN_NO ='002')
	
	BEGIN
	ROLLBACK TRAN
	SELECT '0' AS success, 'Mobile no. already in use' As response_message
	RETURN
    
	END
	ELSE IF (@RETURN_NO ='001')
	BEGIN
	--ROLLBACK TRAN
	SELECT '0' AS success, 'Email is already in use.Please key in a new email!' As response_message
	RETURN
	END
	
END




