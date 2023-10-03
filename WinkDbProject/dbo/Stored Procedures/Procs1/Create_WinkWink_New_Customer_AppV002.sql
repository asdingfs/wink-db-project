CREATE Procedure [dbo].[Create_WinkWink_New_Customer_AppV002]
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
    @phone_no varchar(11),
    @can_id varchar(20),
    @status varchar(10),
    @group_id varchar(10),
    @subscribe_status varchar(5),
    @referral_code varchar(50)
)

AS 
BEGIN
    DECLARE @customer_id int 
    DECLARE @insert int 
    DECLARE @intErrorCode INT
    DECLARE @RETURN_NO VARCHAR(10)
    declare @age int
    DECLARE @locked_reason varchar(200)
    DECLARE @admin_user_email_for_lock_account  varchar(255) 
    SET @admin_user_email_for_lock_account = 'system@winkwink.sg';

    DECLARE @current_datetime datetime
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime OUTPUT


    IF (@dob is null or @dob ='')
    BEGIN
        SET @dob =null;
    END

    DECLARE @acqQualifier int = 0, @acqPts int = 300, @acqEntryId int = 31, @acqInventory int = 500;
    IF( 
        (cast(@created_at as datetime) between '2022-03-30 12:00:00.000' and '2022-04-05 23:59:59.000')
        AND
        (
            (SELECT COUNT(customer_id) FROM winners_points WHERE entry_id = @acqEntryId) < @acqInventory
        )
    )
    BEGIN
        SET @acqQualifier = 1;
    END

    -- By default, isEmptyReferralCode is TRUE
    DECLARE @isEmptyReferralCode INT = 1
    DECLARE @referral_program_status INT;
    
    BEGIN TRAN TRY
        -- Check already Not registered from iMOB
        IF NOT EXISTS (SELECT * FROM customer WHERE LOWER(customer.email) = LOWER(@EMAIL))
        BEGIN
            IF (@phone_no !='' and @phone_no is not null)
            BEGIN
                IF NOT EXISTS (SELECT * FROM customer WHERE customer.phone_no= @phone_no)
                BEGIN
                    IF (@referral_code !='' and @referral_code is not null)
                    BEGIN
                        -- Receive the status of the program with reward_type of 'WID',
                        -- 1: program is in an active state; 
                        -- 2: program is in an inactive state;
                        SELECT @referral_program_status = [status] FROM referral_program_config WHERE reward_type = 'WID'
                        
                        IF (@referral_program_status = 1)
                        BEGIN
                            IF EXISTS (SELECT * FROM customer WHERE customer.WID = @referral_code)
                            BEGIN
                                -- SET isEmptyReferralCode to FALSE if referral code is exist
                                SET @isEmptyReferralCode = 0
                            END
                            ELSE
                            BEGIN
                                SET @RETURN_NO = '004'
                                GOTO ERROR
                            END
                        END
                        ELSE
                        -- Referral program is in an inactive state, return error message
                        BEGIN
                            SET @RETURN_NO = '004'
                            GOTO ERROR
                        END
                    END
                    
                    INSERT INTO customer
                    ([first_name] ,[last_name],[email],[password] ,[gender] ,[date_of_birth] ,[auth_token]
                        ,[imob_customer_id],[created_at],[updated_at],[phone_no]  ,[status],group_id,subscribe_status)
                    VALUES
                    (@first_name,@last_name ,@email ,@password ,@gender ,@dob,@auth_token ,@imob_customer_id,@created_at ,
                        @updated_at,@phone_no,@status,@group_id,@subscribe_status)

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
                        where customer.customer_id = @customer_id;

                        --credit xx points instantly into user's account
                        IF(@acqQualifier = 1)
                        BEGIN
                            EXEC SocialMediaAcquisition @customer_id,@acqEntryId,@acqPts;
                        END
                        IF(@dob is not null)
                        BEGIN
                            
                            set @age = (select floor(datediff(day,@dob, DATEADD(HOUR,8,GETDATE())) / 365.25));

                            IF( @age <= 0 or @age > 90)
                            BEGIN

                                Update customer set customer.status = 'disable',
                                customer.updated_at = @CURRENT_DATETIME where customer.customer_id = @customer_id;

                                IF (@@ROWCOUNT>0)
                                BEGIN
                                    
                                    Set @locked_reason = 'Year of birth is '+SUBSTRING(@dob, 1, 4)+'.';

                                    Insert into System_Log (customer_id, action_status,created_at,reason)
                                    Select customer.customer_id,
                                    'disable',@CURRENT_DATETIME,@locked_reason
                                    from customer where customer.customer_id = @customer_id;

                                    -----INSERT INTO ACCOUNT FILTERING LOCK
                                    EXEC Create_WINK_Account_Filtering @customer_id,@locked_reason,@admin_user_email_for_lock_account;
                                END
                            END
                        END              
                    END
                 
                    --Check And INSERT CAN ID
                    
                    IF @can_id IS NOT NULL AND @can_id !='' AND @customer_id !=0
                    BEGIN
                        IF NOT EXISTS (SELECT * from can_id where can_id.customer_canid = @can_id)
                        BEGIN
                            Insert into can_id (customer_canid,can_id_key,created_at,customer_id,[status],updated_at)
                            Values (@can_id,@can_id,@created_at,@customer_id,@status,@created_at)
                            
                            SELECT @intErrorCode = @@ERROR
                        
                            IF (@intErrorCode <> 0)
                            BEGIN
                                SET @RETURN_NO ='000'
                                Print('Insert CAN ID Fail')
                                GOTO ERROR
                            END
                                --          IF(@intErrorCode = 0)
                                --BEGIN

                                --if(SUBSTRING(@can_id,1,6) = '111179')
                                --BEGIN

                        
                                --IF(cast(@current_datetime as Date) >= cast('2018-05-01' as Date) AND 
                                --  cast(@current_datetime as Date) <= cast('2018-07-31' as Date) )
                                --  BEGIN

                                --  IF ((SELECT count(*) from Authen_NETS_Contactless_Cashcard where MONTH(created_at) = MONTH(cast(@current_datetime as Date)) ) < 10000 )
                                --  BEGIN

                                --  IF NOT EXISTS (SELECT 1 from Authen_NETS_Contactless_Cashcard where customer_id = @customer_id )
                                --  BEGIN

                                --  IF NOT EXISTS (SELECT 1 from Authen_NETS_Contactless_Cashcard where nets_card = @can_id )
                                --  BEGIN

                                --  Insert into Authen_NETS_Contactless_Cashcard (customer_id, nets_card, created_at, updated_at)
                                --Values (@customer_id, @can_id ,@created_at, @created_at)

                                --END

                                --    END
                                --  END

                                --  END

                                --END


                                --END
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
            END
            ELSE  --- No Phone No.
            BEGIN
                IF (@referral_code !='' and @referral_code is not null)
                BEGIN
                    -- Receive the status of the program with reward_type of 'WID',
                    -- 1: program is in an active state; 
                    -- 2: program is in an inactive state;
                    SELECT @referral_program_status = [status] FROM referral_program_config WHERE reward_type = 'WID'
                        
                    IF (@referral_program_status = 1)
                    BEGIN
                        IF EXISTS (SELECT * FROM customer WHERE customer.WID = @referral_code)
                        BEGIN
                            -- SET isEmptyReferralCode to FALSE if referral code is exist
                            SET @isEmptyReferralCode = 0
                        END
                        ELSE
                        BEGIN
                            SET @RETURN_NO = '004'
                            GOTO ERROR
                        END
                    END
                    ELSE
                    -- Referral program is in an inactive state, return error message
                    BEGIN
                        SET @RETURN_NO = '004'
                        GOTO ERROR
                    END
                END

                INSERT INTO customer
                ([first_name] ,[last_name],[email],[password] ,[gender] ,[date_of_birth] ,[auth_token]
                    ,[imob_customer_id],[created_at],[updated_at],[phone_no]  ,[status],group_id,subscribe_status)
                VALUES
                (@first_name,@last_name ,@email ,@password ,@gender ,@dob,@auth_token ,@imob_customer_id,@created_at ,
                    @updated_at,@phone_no,@status,@group_id,@subscribe_status)
                

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
                    where customer.customer_id = @customer_id;
                    --credit xx points instantly into user's account
                    IF(@acqQualifier = 1)
                    BEGIN
                        EXEC SocialMediaAcquisition @customer_id,@acqEntryId,@acqPts;
                    END

                    IF(@dob is not null)
                    BEGIN
                        set @age = (select floor(datediff(day,@dob, DATEADD(HOUR,8,GETDATE())) / 365.25));

                        IF( @age <= 0 or @age > 90)
                        BEGIN
                            Update customer set customer.status = 'disable',
                            customer.updated_at = @CURRENT_DATETIME where customer.customer_id = @customer_id;

                            IF (@@ROWCOUNT>0)
                            BEGIN
                                    
                                Set @locked_reason = 'Year of birth is '+SUBSTRING(@dob, 1, 4)+'.';

                                Insert into System_Log (customer_id, action_status,created_at,reason)
                                Select customer.customer_id,
                                'disable',@CURRENT_DATETIME,@locked_reason
                                from customer where customer.customer_id = @customer_id;

                                -----INSERT INTO ACCOUNT FILTERING LOCK
                                EXEC Create_WINK_Account_Filtering @customer_id,@locked_reason,@admin_user_email_for_lock_account;
                            END
                        END
                    END
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
                            --          IF(@intErrorCode = 0)
                            --BEGIN

                            --if(SUBSTRING(@can_id,1,6) = '111179')
                            --BEGIN

                        
                            --IF(cast(@current_datetime as Date) >= cast('2018-05-01' as Date) AND 
                            --  cast(@current_datetime as Date) <= cast('2018-07-31' as Date) )
                            --  BEGIN

                            --  IF ((SELECT count(*) from Authen_NETS_Contactless_Cashcard where MONTH(created_at) = MONTH(cast(@current_datetime as Date)) ) < 10000 )
                            --  BEGIN

                            --  IF NOT EXISTS (SELECT 1 from Authen_NETS_Contactless_Cashcard where customer_id = @customer_id )
                            --  BEGIN

                            --  IF NOT EXISTS (SELECT 1 from Authen_NETS_Contactless_Cashcard where nets_card = @can_id )
                            --  BEGIN

                            --  Insert into Authen_NETS_Contactless_Cashcard (customer_id, nets_card, created_at, updated_at)
                            --Values (@customer_id, @can_id ,@created_at, @created_at)

                            --END
                            --    END


                            --  END

                            --  END

                            --END


                            --END
                    END
                    ELSE 
                    BEGIN
                        SET @RETURN_NO ='003'
                        GOTO ERROR
                        RETURN
                    END
                END
            END
            
            -- Commit Transaction
            IF(@intErrorCode=0)
            BEGIN
                IF (@isEmptyReferralCode = 0) 
                BEGIN
                    DECLARE @program_id INT = (SELECT program_id FROM referral_program_config WHERE reward_type = 'WID')
                    DECLARE @referrer_customer_id INT = (SELECT customer_id FROM customer WHERE customer.WID = @referral_code);
                    DECLARE @success_issuance INT;
                    DECLARE @response_message_issuance VARCHAR(255);
                    DECLARE @TEMP_TBL_RESULT_ISSUANCE TABLE (
                                success INT,
                                response_message VARCHAR(255)
                            );
                    
                    INSERT INTO @TEMP_TBL_RESULT_ISSUANCE (success, response_message)
                    EXEC SP_Referral_Points_Issuance @program_id, @referrer_customer_id, @customer_id, @referral_code;

                    SELECT @success_issuance = success, @response_message_issuance = response_message FROM @TEMP_TBL_RESULT_ISSUANCE
                    
                    -- Check if the points issuance was successful
                    IF (@success_issuance = 0)
                    BEGIN
                        SET @RETURN_NO = '005';
                        GOTO ERROR;
                        RETURN;
                    END
                END
                
                SELECT '1' AS success , customer.auth_token, customer.customer_id 
                ,'Successfully Registered' as response_message
                from customer
                Where customer.customer_id =@customer_id
                
                COMMIT TRAN
            END 
        END 
        /* Already Registered */
        ELSE IF EXISTS(SELECT * FROM customer WHERE LOWER(customer.email) = LOWER(@EMAIL) AND customer.imob_customer_id = @imob_customer_id)
        BEGIN
            IF (@phone_no !='' and @phone_no is not null)
            BEGIN
                IF NOT EXISTS (SELECT * FROM customer WHERE customer.phone_no= @phone_no)
                BEGIN
                    Update customer set customer.phone_no = @phone_no,
                    customer.subscribe_status = @subscribe_status,
                    customer.group_id = @group_id
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
                        Set @customer_id = (Select customer.customer_id FROM customer  WHERE LOWER(customer.email) = LOWER(@EMAIL) AND customer.imob_customer_id = @imob_customer_id);
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
                                    --       IF(@intErrorCode = 0)
                                    --BEGIN

                                    --if(SUBSTRING(@can_id,1,6) = '111179')
                                    --BEGIN

                        
                                    --IF(cast(@current_datetime as Date) >= cast('2018-05-01' as Date) AND 
                                    --  cast(@current_datetime as Date) <= cast('2018-07-31' as Date) )
                                    --  BEGIN

                                    --  IF ((SELECT count(*) from Authen_NETS_Contactless_Cashcard where MONTH(created_at) = MONTH(cast(@current_datetime as Date)) ) < 10000 )
                                    --  BEGIN

                                    --  IF NOT EXISTS (SELECT 1 from Authen_NETS_Contactless_Cashcard where customer_id = @customer_id )
                                    --  BEGIN

                                    --  IF NOT EXISTS (SELECT 1 from Authen_NETS_Contactless_Cashcard where nets_card = @can_id )
                                    --  BEGIN

                                    --  Insert into Authen_NETS_Contactless_Cashcard (customer_id, nets_card, created_at, updated_at)
                                    --Values (@customer_id, @can_id ,@created_at, @created_at)

                                    --END
                                    --    END


                                    --  END

                                    --  END

                                    --END


                                    --END
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
            END
            ELSE
            BEGIN
                Update customer set customer.phone_no = @phone_no,
                customer.subscribe_status = @subscribe_status,
                customer.group_id = @group_id
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
                    Set @customer_id = (Select customer.customer_id FROM customer  WHERE LOWER(customer.email) = LOWER(@EMAIL) AND customer.imob_customer_id = @imob_customer_id);
                 
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
                            --IF(@intErrorCode = 0)
                            --BEGIN

                            --if(SUBSTRING(@can_id,1,6) = '111179')
                            --BEGIN

                        
                            --IF(cast(@current_datetime as Date) >= cast('2018-05-01' as Date) AND 
                            --  cast(@current_datetime as Date) <= cast('2018-07-31' as Date) )
                            --  BEGIN

                            --  IF ((SELECT count(*) from Authen_NETS_Contactless_Cashcard where MONTH(created_at) = MONTH(cast(@current_datetime as Date)) ) < 10000 )
                            --  BEGIN

                            --  IF NOT EXISTS (SELECT 1 from Authen_NETS_Contactless_Cashcard where customer_id = @customer_id )
                            --  BEGIN

                            --  IF NOT EXISTS (SELECT 1 from Authen_NETS_Contactless_Cashcard where nets_card = @can_id )
                            --  BEGIN
                                
                            --  Insert into Authen_NETS_Contactless_Cashcard (customer_id, nets_card, created_at, updated_at)
                            --Values (@customer_id, @can_id ,@created_at, @created_at)
                                
                            --  END
                            --    END

                            --  END

                            --  END

                            --END


                            --END
                    END
                    ELSE 
                    BEGIN
                        SET @RETURN_NO ='003'
                        GOTO ERROR
                        RETURN
                    END     
                END
            END
            -- Commit Transaction
      
            IF(@intErrorCode=0)
            BEGIN
                SELECT '1' AS success , customer.auth_token, customer.customer_id 
                ,'Successfully Registered' as response_message
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
    ERROR:
        IF(@RETURN_NO='000')
        BEGIN
            IF (@intErrorCode <> 0) 
            BEGIN
                ROLLBACK TRAN
                Select '0' as success , 'Failed to insert' AS response_message
                RETURN
            END
        END
        ELSE IF (@RETURN_NO ='005')
        BEGIN
            -- Rollback the transaction so no data will be inserted into the table
            ROLLBACK TRAN
            -- Return the error message if maximum size reached, current datetime not between from_date and to_date, and unexpected error
            SELECT '0' AS success, @response_message_issuance AS response_message
            RETURN
        END
        ELSE IF (@RETURN_NO ='004')
        BEGIN
            ROLLBACK TRAN
            SELECT '0' AS success, 'The referral code is invalid' AS response_message
            RETURN
        END
        ELSE IF (@RETURN_NO ='003')
        BEGIN
            ROLLBACK TRAN
            SELECT '0' AS success, 'Travel card/membership ID already exists' AS response_message
            RETURN
        END
        ELSE IF (@RETURN_NO ='002')
        BEGIN
            ROLLBACK TRAN
            SELECT '0' AS success, 'Phone no already exists' AS response_message
            RETURN
        END
        ELSE IF (@RETURN_NO ='001')
        BEGIN
            SELECT '0' AS success, 'The email address is already in use. Please key in a new address!' AS response_message
            RETURN
        END
END
