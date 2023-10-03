CREATE PROCEDURE [dbo].[Earn_NETS_Contactless_Cashcard_Campaign]
	(

	 @customer_id int,
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
DECLARE @total_count_customers int

DECLARE @total_points int
DECLARE @total_points_rewards int

DECLARE @new_user_status int

DECLARE @customer_answer varchar(50)
DECLARE @netscanid  varchar(50)
DECLARE @netscanidDate datetime

set @campaign_start_date = CAST('2018-05-02' AS DATE)




EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime OUTPUT

SET @total_count_customers = 10000

SET @total_points = 50

SET @total_points_rewards =0

SET @netscanid = (select nets_card from Authen_NETS_Contactless_Cashcard WHERE customer_id = @CUSTOMER_ID 
AND SUBSTRING(nets_card,1,6) = '111179')

SET @netscanidDate = (select created_at from Authen_NETS_Contactless_Cashcard WHERE customer_id = @CUSTOMER_ID 
AND SUBSTRING(nets_card,1,6) = '111179')

	IF EXISTS (select 1 from customer where customer.customer_id = @customer_id and status ='disable')
     BEGIN
   
	 SELECT '0' as response_code, 'Your account is locked. Please contact customer service.' as response_message 
	
		RETURN 
	END

    --SELECT @customer_id=customer.customer_id FROM customer WHERE customer.status='enable' and
	
	IF (@customer_id IS NOT NULL AND @customer_id !=0 AND @customer_id !='')
		BEGIN
		  
		     --- Already participated ???
			IF EXISTS (SELECT 1 FROM NETS_Contactless_Cashcard where customer_id =@customer_id)
			BEGIN 
					SELECT 0 AS response_code , 'You have already participated in this campaign.' as response_message
					RETURN 

			END						
			ELSE
			BEGIN
				 
				 ----CHECK FULLY REDEEMED

			
					BEGIN


						SET @total_points_rewards = @total_points

						IF( (SELECT COUNT(*) FROM NETS_Contactless_Cashcard) >= @total_count_customers)

							BEGIN
							SELECT 0 AS response_code , 'Sorry! This campaign has ended.' as response_message
					        RETURN 

							END 

					END




				  ---CHECK THE CORRECT ANSWER
				 --IF ( LOWER(LTRIM(RTRIM(@customer_answer))) = LOWER(LTRIM(RTRIM(@correct_answer))) )
				  BEGIN
					
			IF EXISTS (SELECT 1 FROM Authen_NETS_Contactless_Cashcard where MONTH(created_at) = MONTH(cast(@current_datetime as Date)) and customer_id =@customer_id and SUBSTRING(nets_card,1,6) = '111179')
			
			BEGIN

			IF NOT EXISTS (SELECT 1 FROM NETS_Contactless_Cashcard where customer_id =@customer_id)

			BEGIN


					INSERT INTO [dbo].[NETS_Contactless_Cashcard]
						   ([campaign_id]
						   ,[customer_id]
						   ,[nets_card]
						   ,[registered_date_for_nets]
						   ,[correct_answer_status]
						   ,[created_at]
						   ,[updated_at]
						   ,location
						   ,ip_address
						   ,points_rewards
						   )
					 VALUES
					 (@campaign_id,
					  @customer_id,
					  @netscanid,
					  @netscanidDate,
					  'Yes',
					  @current_datetime,
					  @current_datetime,
					  @location,
					  @ip_address,
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
						    --IF(@new_user_status =1)
							BEGIN
							SELECT 1 AS response_code , 
							'Congrats! You have earned 50 WINK+ points which will be credited to your WINK+ account. You can view your points under Account > My Rewards.' as response_message
							RETURN

							END
							--ELSE IF (@new_user_status =0)
							--BEGIN
								--SELECT 1 AS response_code , 
							--'Huat ah! You have won $2 worth of WINK+ points which will be credited to your WINK+ account. You can view your points under Account > My Rewards.' as response_message
							--RETURN


							--END

						END 
			
			
			
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


