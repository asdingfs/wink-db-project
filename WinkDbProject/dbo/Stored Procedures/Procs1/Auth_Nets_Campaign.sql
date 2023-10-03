
CREATE PROCEDURE [dbo].[Auth_Nets_Campaign]
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

set @campaign_start_date = CAST('2018-05-02' AS DATE)




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


		
			 --- Already participated ???
			IF EXISTS (SELECT 1 FROM NETS_Contactless_Cashcard as c where customer_id =@customer_id)
			BEGIN 
					SELECT 0 AS response_code , 'You have already participated in this contest.' as response_message
					RETURN 

			END
			ELSE
			BEGIN


				IF(cast(@current_datetime as Date) >= cast('2018-05-01' as Date) AND 
								cast(@current_datetime as Date) <= cast('2018-07-31' as Date) )
					BEGIN
						    
							--IF((SELECT count(*) from Authen_NETS_Contactless_Cashcard where MONTH(created_at) = MONTH(cast(@current_datetime as Date)) ) >= 10000 )

						

							--END 
							--ELSE
							--BEGIN

							IF EXISTS (SELECT 1 FROM Authen_NETS_Contactless_Cashcard where MONTH(created_at) = MONTH(cast(@current_datetime as Date)) and customer_id =@customer_id and SUBSTRING(nets_card,1,6) = '111179')
							BEGIN

							IF((SELECT count(*) from NETS_Contactless_Cashcard where MONTH(created_at) = MONTH(cast(@current_datetime as Date)) ) >= 10000 )
							BEGIN

							SELECT 0 AS response_code , 'Sorry! Contest has ended.' as response_message
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
								
							SELECT 0 AS response_code , 'Sorry! Contest has ended.' as response_message
					        RETURN 

							END
							--END

					END




			END


				
			

				END
				

		


		



END