CREATE PROCEDURE [dbo].[Answer_CNY_2018_Campaign]
	(@customer_id int,
	 --@auth_token varchar(100),
	 @answer varchar(100),
	 @location varchar(150),
	 @ip_address varchar(25),
	 @campaign_id int
	 
	 )
AS
BEGIN

DECLARE @correct_answer varchar(100)
--DECLARE @campaign_id int
DECLARE @current_datetime datetime

DECLARE @campaign_start_date datetime
DECLARE @total_new_customers int
DECLARE @total_old_customers int
DECLARE @total_points_for_oldcustomer int
DECLARE @total_points_for_newcustomer int
DECLARE @total_points_rewards int

DECLARE @new_user_status int

DECLARE @customer_answer varchar(50)

set @campaign_start_date = CAST('2018-02-15' AS DATE)




EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime OUTPUT

--SET @campaign_id = 25

SET @correct_answer = '28'

SET @new_user_status =0
SET @total_new_customers = 10
SET @total_old_customers =10


SET @total_points_for_oldcustomer = 200

SET @total_points_for_newcustomer = 800

SET @total_points_rewards =0



	---- CHECK ANSWER 
	IF (@answer IS NOT NULL AND @answer !='')
	IF EXISTS (SELECT 1 FROM winktag_survey_option AS A WHERE A.option_id = @answer)
	BEGIN

		SELECT @customer_answer = O.option_answer FROM  winktag_survey_option AS O WHERE O.option_id = @answer

	END





-- CHECK ACCOUNT LOCKED
--IF EXISTS (select 1 from customer where customer.auth_token = @auth_token and status ='disable')
--     BEGIN
   
--	 SELECT '0' as response_code, 'Your account is locked. Please contact customer service.' as response_message 
	
--		RETURN 
--	END-- END


	IF EXISTS (select 1 from customer where customer.customer_id = @customer_id and status ='disable')
     BEGIN
   
	 SELECT '0' as response_code, 'Your account is locked. Please contact customer service.' as response_message 
	
		RETURN 
	END

    --SELECT @customer_id=customer.customer_id FROM customer WHERE customer.status='enable' and
	
	IF (@customer_id IS NOT NULL AND @customer_id !=0 AND @customer_id !='')
		BEGIN
		    ----CHECK NEW USER

			IF EXISTS (SELECT 1 FROM CUSTOMER WHERE CAST(created_at AS DATE)
			>= CAST(@campaign_start_date AS DATE ) AND customer.customer_id = @customer_id)
				BEGIN
						SET @new_user_status =1
 
				END

			---CHECK CUSTOMER INCORRECT ANSWER TIMES
			IF  ((SELECT count(*) FROM CNY_2018_Campaign as c where c.correct_answer_status = 'No'  and customer_id =@customer_id)>=3)
			BEGIN

						
				SELECT 0 AS response_code , 'Oh well! Better luck next time! Thanks for playing!' as response_message
				RETURN

						

			END --- Already participated ???
			ELSE IF EXISTS (SELECT 1 FROM CNY_2018_Campaign as c where c.correct_answer_status = 'Yes' and customer_id =@customer_id)
			BEGIN 
					SELECT 0 AS response_code , 'You have already participated in this contest.' as response_message
					RETURN 

			END
			
			
			ELSE
			BEGIN
				 
				 ----CHECK FULLY REDEEMED


				 IF (@new_user_status =1) --- NEW USER
					BEGIN

						SET @total_points_rewards = @total_points_for_newcustomer

						IF( (SELECT COUNT(*) FROM CNY_2018_Campaign WHERE new_user_status = 1 and correct_answer_status ='Yes') >= @total_new_customers)

							BEGIN
							SELECT 0 AS response_code , 'Sorry! Contest has ended.' as response_message
					        RETURN 

							END 
					END
				ELSE 
					BEGIN

						SET @total_points_rewards = @total_points_for_oldcustomer

						IF( (SELECT COUNT(*) FROM CNY_2018_Campaign WHERE new_user_status = 0 and correct_answer_status='Yes') >= @total_old_customers)

							BEGIN
							SELECT 0 AS response_code , 'Sorry! Contest has ended.' as response_message
					        RETURN 

							END 

					END




				  ---CHECK THE CORRECT ANSWER
				 IF ( LOWER(LTRIM(RTRIM(@customer_answer))) = LOWER(LTRIM(RTRIM(@correct_answer))) )
				  BEGIN
					

					INSERT INTO [dbo].[CNY_2018_Campaign]
						   ([campaign_id]
						   ,[customer_id]
						   ,[answer]
						   ,[correct_answer_status]
						   ,[created_at]
						   ,[updated_at]
						   ,location
						   ,ip_address
						   ,new_user_status
						   ,points_rewards
						   )
					 VALUES
					 (@campaign_id,
					  @customer_id,
					  @customer_answer,
					  'Yes',
					  @current_datetime,
					  @current_datetime,
					  @location,
					  @ip_address,
					  @new_user_status,
					  @total_points_rewards
					 )

					 IF(@@ROWCOUNT>0)
						BEGIN
						------- INSERT INTO WINKTAG POINTS 
							INSERT INTO [dbo].[winktag_customer_earned_points]
							   ([campaign_id]
							   ,[question_id]
							   ,[customer_id]
							   ,[points]
							   ,[GPS_location]
							   ,[ip_address]
							   ,[created_at]
							   ,[row_count]
							   ,[additional_point_status])
							   VALUES 
							   (@campaign_id,
							    0,
								@customer_id,
								@total_points_rewards,
								@location,
								@ip_address,
								@current_datetime,
								0,
								0)
								
								
					    ---- INSERT INTO CUSTOMER BALANCE 
						IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
						BEGIN
							UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = ISNULL((SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID),0) + ISNULL(@total_points_rewards,0) 
							WHERE CUSTOMER_ID =@CUSTOMER_ID
							
						END
						ELSE
						BEGIN
							INSERT INTO customer_balance 
							(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans)VALUES
							(@CUSTOMER_ID,@total_points_rewards,0,0,0,0,0,1) 
							
						END							   
						    IF(@new_user_status =1)
							BEGIN
							SELECT 1 AS response_code , 
							'Huat ah! You have won $8 worth of WINK+ points which will be credited to your WINK+ account. You can view your points under Account > My Rewards.' as response_message
							RETURN

							END
							ELSE IF (@new_user_status =0)
							BEGIN
								SELECT 1 AS response_code , 
							'Huat ah! You have won $2 worth of WINK+ points which will be credited to your WINK+ account. You can view your points under Account > My Rewards.' as response_message
							RETURN


							END

						END 

				  END
				 
				  ELSE 
				  BEGIN

				  INSERT INTO [dbo].[CNY_2018_Campaign]
						   ([campaign_id]
						   ,[customer_id]
						   ,[answer]
						   ,[correct_answer_status]
						   ,[created_at]
						   ,[updated_at]
						   ,location
						   ,ip_address
						   ,new_user_status
						   )
					 VALUES
					 (@campaign_id,
					  @customer_id,
					  @customer_answer,
					  'No',
					  @current_datetime,
					  @current_datetime,
					  @location,
					  @ip_address
					  ,@new_user_status
					 )

					  IF(@@ROWCOUNT>0)
						BEGIN
						    DECLARE @total_wrong  int 
							set @total_wrong = ISNULL ((SELECT COUNT(*) FROM [CNY_2018_Campaign] WHERE [correct_answer_status] ='No' and 
							customer_id =@customer_id ),0) 
							---First try
						    IF ( @total_wrong = 1)
							BEGIN
							SELECT 2 AS response_code , 'Oops! That&#39;s not the right answer. You have 2 more chances to get it right.' as response_message
							RETURN

							END
							ELSE IF ( @total_wrong = 2)
							BEGIN
							SELECT 2 AS response_code , 'Uh-oh! You have 1 more chance left.' as response_message
							RETURN

							END
							ELSE IF ( @total_wrong = 3)
							BEGIN
							SELECT 0 AS response_code , 'Oh well! Better luck next time! Thanks for playing!' as response_message
							RETURN

							END
						END 
				  END


			END


		END
	ELSE
	
		BEGIN
			SELECT 0 AS response_code , 'Invalid customer' as response_message
			RETURN 
		END
END


