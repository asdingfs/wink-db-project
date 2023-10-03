CREATE PROCEDURE [dbo].[Points_And_WINKs_Confiscation_With_AFM]
(
	@customer_id int,
	@confiscation_type varchar(50),
	@points_confiscation_status varchar(10),
	@winks_confiscation_status varchar(10),
	@account_filtering_id int,
	@admin_user_email varchar(100),
	@admin_user_id int
)
AS
BEGIN
	DECLARE @confiscate_wink int 
	DECLARE @intErrorCode INT
	DECLARE @current_date datetime
	DECLARE @campaign_id int
	DECLARE @merchant_id int
	DECLARE @confiscate_points int ,@balance_points int , @balance_winks int

	--SET @merchant_id = 248;
	--SET @campaign_id = 5; ---- Production 

	SET @merchant_id = 64;
	SET @campaign_id = 1; -----Testing

	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

	BEGIN Transaction 
		BEGIN TRY
			IF EXISTS (SELECT * from customer where customer.customer_id =@customer_id and customer.[status] = 'disable')
			BEGIN
				------CHECK CUSTOMER BALANCE 
				IF EXISTS (SELECT 1 FROM customer_balance WHERE customer_id = @customer_id)
				BEGIN
					----- CHECK BOTH POINTS AND WINKS CONFISCATION ?
					SET @balance_points = 0;
					SET @balance_winks = 0;
					SET @confiscate_points =0;
					SET @confiscate_wink =0;

					Select @balance_winks = (ISNULL(total_winks,0) - ISNULL(used_winks,0) - ISNULL(confiscated_winks,0)),
					@balance_points = (ISNULL(total_points,0) - ISNULL(used_points,0) - ISNULL(confiscated_points,0))
					from customer_balance 
					where customer_balance.customer_id = @customer_id;

					SET @balance_points = ISNULL(@balance_points,0);
					SET @balance_winks = ISNULL (@balance_winks,0);

					IF (@confiscation_type ='5050_approve')
					BEGIN
						SET @confiscate_points = FLOOR(ISNULL (@balance_points,0)/2);
						SET @confiscate_wink = @balance_winks;
					END
					ELSE 
					BEGIN
						SET @confiscate_points = @balance_points;
						SET @confiscate_wink =   @balance_winks;
					END
					IF ( @winks_confiscation_status = 'No')
					BEGIN
						SET @confiscate_wink =  0;
					END
					IF ( @points_confiscation_status = 'No')
					BEGIN
						SET @confiscate_points =  0;
					END
				END
		
				IF (@confiscate_wink > 0 OR @confiscate_points>0)
				BEGIN
					DECLARE @log_id int;
					DECLARE @admin_username_tmp varchar(255);
					DECLARE @unlock_action_id int;
					DECLARE @name varchar(255)
					DECLARE @email varchar(255)
					DECLARE @customersince varchar(50)
					DECLARE @gender varchar(255)
					DECLARE @dob varchar(50)
					DECLARE @card_id_1 varchar(50)
					DECLARE @card_id_2 varchar(50)         
					DECLARE @card_id_3 varchar(50)
					DECLARE @old_wink_confis_status varchar(10)
					DECLARE @old_point_confis_status varchar(10)

					SET @log_id  = (SELECT TOP 1 admin_log.id FROM admin_log WHERE [user_id] = @admin_user_id order by id desc);
				
					Set @admin_username_tmp = (SELECT [user_name] FROM admin_log WHERE admin_log.id = @log_id);
					
					INSERT INTO action_log
						([log_id]
						,[action_time]
						,[admin_user_name]
						,[admin_user_email]
						,[action_object]
						,[action_type]
						,[action_table_name]
						,[link_url]
						)
					VALUES
						(@log_id
						,@current_date
						,@admin_username_tmp
						,@admin_user_email
						,'Account Filtering'
						,'Confiscate'
						,'custmer_deletion_log'
						,'adminactiondetail/customerediteddetail'
						);

					IF ((SELECT @@IDENTITY) > 0)
					BEGIN
						SET @unlock_action_id = (SELECT SCOPE_IDENTITY());
						update admin_log 
						set action_count = (select action_count from admin_log where admin_log.id = @log_id) + 1 
						where admin_log.id = @log_id;

						declare @tempCustomerSince datetime;

						SELECT @name = first_name+' '+last_name, @email = email, @tempCustomerSince = created_at, @gender = gender, @dob = date_of_birth,
						@old_point_confis_status = confiscated_points_status, @old_wink_confis_status = confiscated_wink_status
						from customer where customer_id = @customer_id;

						set @customersince =  (select  CONVERT(varchar,@tempCustomerSince,100));

						WITH T AS
						(
							SELECT customer_canid,
							ROW_NUMBER() OVER (ORDER BY created_at) RN
							FROM can_id where customer_id = @customer_id
						)
						SELECT @card_id_1 = MAX(CASE WHEN RN = 1 THEN customer_canid END),
						@card_id_2 = MAX(CASE WHEN RN = 2 THEN customer_canid END),
						@card_id_3 = MAX(CASE WHEN RN = 3 THEN customer_canid END)
						FROM T 
						WHERE RN <= 3;

						if(@card_id_1 is null)
						BEGIN
							set @card_id_1 = '';
						END

						if(@card_id_2 is null)
						BEGIN
							set @card_id_2 = '';
						END
							
						if(@card_id_3 is null)
						BEGIN
							set @card_id_3 = '';
						END

						INSERT INTO custmer_deletion_log
							([action_id]
							,[customer_id]
							,[Name]
							,[Email]
							,[CustomerSince]
							,[Gender]
							,[Dob]
							,[Card_ID_1]
							,[Card_ID_2]
							,[Card_ID_3]
							,[Status]
							,[confiscated_wink_status]
							,[confiscated_points_status])
						VALUES
							(@unlock_action_id
							,@customer_id
							,@name
							,@email
							,@customersince
							,@gender
							,@dob
							,@card_id_1
							,@card_id_2         
							,@card_id_3
							,'enable'
							,@confiscate_wink
							,@confiscate_points
							);

						INSERT INTO custmer_old_detail_log
							([action_id]
							,[customer_id]
							,[Name]
							,[Email]
							,[CustomerSince]
							,[Gender]
							,[Dob]
							,[Card_ID_1]
							,[Card_ID_2]
							,[Card_ID_3]
							,[Status]
							,[confiscated_wink_status]
							,[confiscated_points_status])
						VALUES
							(@unlock_action_id
							,@customer_id
							,@name
							,@email
							,@customersince
							,@gender
							,@dob
							,@card_id_1
							,@card_id_2         
							,@card_id_3
							,'disable'
							,@old_wink_confis_status
							,@old_point_confis_status
							);			
							 
					END  
					IF (@confiscate_wink >0)
					BEGIN
						--1. Insert into WINK Confiscate Detail
						INSERT INTO wink_confiscated_detail (customer_id , merchant_id , created_at, updated_at, total_winks)
						values (@customer_id,@merchant_id,@current_date,@current_date,@confiscate_wink);
					END

					SELECT @intErrorCode = @@ERROR
					IF (@intErrorCode <> 0) 
					BEGIN
						GOTO ERROR;
					END

					---2. Insert into points_confiscated_detail
					INSERT INTO points_confiscated_detail
					([customer_id]
      				,[created_at]
					,[updated_at]
					,[confiscated_points])
					VALUES(@customer_id,
					@current_date,
					@current_date, 
					@confiscate_points);

					SELECT @intErrorCode = @@ERROR
					IF (@intErrorCode <> 0) 
					BEGIN
						GOTO ERROR;
					END
					ELSE
					BEGIN
						
						--2. Update Customer Balance 
						Update customer_balance 
						set confiscated_winks = ISNULL(@confiscate_wink,0)+ISNULL(confiscated_winks,0),
						confiscated_points = ISNULL(@confiscate_points,0)+ ISNULL(confiscated_points,0)
						where customer_balance.customer_id =@customer_id;

						SELECT @intErrorCode = @@ERROR
						IF (@intErrorCode <> 0) 
						BEGIN
							GOTO ERROR;
						END
						ELSE
						BEGIN
							-----INSERT INTO GLOBAL
							IF (@campaign_id != 0)
							BEGIN
								Update campaign 
								set total_wink_confiscated = @confiscate_wink + total_wink_confiscated 
								where campaign.campaign_id = @campaign_id;
										
								SELECT @intErrorCode = @@ERROR;
								IF (@intErrorCode <> 0) 
									GOTO ERROR;
							END

							SELECT @intErrorCode = @@ERROR;
							IF (@intErrorCode <> 0) 
							BEGIN
								GOTO ERROR;
							END

							INSERT INTO [dbo].[points_and_winks_confiscation_detail]
								([customer_id]
								,[confiscated_points]
								,[confiscated_winks]
								,[total_winks]
								,[total_points]
								,[account_filtering_id]
								,confiscation_type
								,[created_at]
								,[updated_at])
							VALUES
								(@customer_id,@confiscate_points,@confiscate_wink,@balance_winks,
								@balance_points,@account_filtering_id,@confiscation_type,@current_date ,@current_date);	
						END	
					END
						
					-- Commit Trans
					IF(@intErrorCode=0)
					BEGIN
						SELECT '1' as response_code, 'User is successfully updated' As response_message;
						COMMIT TRAN
					END
				END
				ELSE
				BEGIN
					ROLLBACK TRAN
					Select '0' as response_code , '0 WINK to confisccate' as response_message
					RETURN
				END
			END
			ELSE
			BEGIN
				SELECT '0' as response_code, 'User does not exists' As response_message
		
				END	
		END TRY
		BEGIN CATCH 
			GOTO ERROR
		END CATCH

		ERROR:
		IF (@intErrorCode <> 0) 
		BEGIN
			ROLLBACK TRAN
			Select '0' as response_code , 'Failed to confiscate WINK(s)' as response_message;
		RETURN
    
	END
		
END

