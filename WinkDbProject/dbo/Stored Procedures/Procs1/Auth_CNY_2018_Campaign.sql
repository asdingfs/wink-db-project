CREATE PROCEDURE [dbo].[Auth_CNY_2018_Campaign]
	(@customer_id int,
	 @campaign_id int)
AS
BEGIN



DECLARE @current_datetime datetime

DECLARE @campaign_start_date datetime
DECLARE @total_new_customers int
DECLARE @total_old_customers int

DECLARE @new_user_status int

DECLARE @customer_answer varchar(50)

set @campaign_start_date = CAST('2018-02-15' AS DATE)




EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime OUTPUT

SET @new_user_status =0
SET @total_new_customers = 10
SET @total_old_customers =10



-- CHECK ACCOUNT LOCKED
IF EXISTS (select 1 from customer where customer.customer_id = @customer_id and status ='disable')
     BEGIN
   
	 SELECT 0 as response_code, 'Your account is locked. Please contact customer service.' as response_message 
	
		RETURN 
	END-- END

  --  SELECT @customer_id=customer.customer_id FROM customer WHERE customer.status='enable' and Lower(LTRIM(RTRIM(customer.auth_token))) = Lower(LTRIM(RTRIM(@auth_token)))
	
	IF (@customer_id IS NOT NULL AND @customer_id !=0 AND @customer_id !='')
		BEGIN

				IF EXISTS (SELECT 1 FROM CUSTOMER WHERE CAST(created_at AS DATE)
			                  >= CAST(@campaign_start_date AS DATE ) AND customer.customer_id = @customer_id)
				BEGIN
						print('new')
						SET @new_user_status =1
 
				END

					 IF (@new_user_status =1) --- NEW USER
					
					BEGIN
					  print ('new')
						

						IF( (SELECT COUNT(*) FROM CNY_2018_Campaign WHERE new_user_status = ISNULL( @new_user_status,0) and correct_answer_status='Yes') >= @total_new_customers)

							BEGIN
							SELECT 0 AS response_code , 'Sorry! Contest has ended.' as response_message
					        RETURN 

							END 
					END
				ELSE 
					BEGIN

					   print('old')
						IF( (SELECT COUNT(*) FROM CNY_2018_Campaign WHERE new_user_status = ISNULL(@new_user_status,0) and correct_answer_status='Yes') >= @total_old_customers)

							BEGIN
							SELECT 0 AS response_code , 'Sorry! Contest has ended.' as response_message
					        RETURN 

							END 

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
				    SELECT 1 AS response_code , 'User is authenticate' as response_message
					RETURN 

			END


		END
	ELSE
	
		BEGIN
			SELECT 0 AS response_code , 'Invalid customer' as response_message
			RETURN 
		END
END
