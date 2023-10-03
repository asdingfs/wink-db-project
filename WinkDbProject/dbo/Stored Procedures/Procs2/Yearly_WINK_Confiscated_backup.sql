CREATE PROCEDURE [dbo].[Yearly_WINK_Confiscated_backup]

AS
BEGIN
DECLARE @confiscate_wink int 
DECLARE @intErrorCode INT
DECLARE @current_date datetime
DECLARE @campaign_id int
DECLARE @merchant_id int
DECLARE @year varchar(10)
DECLARE @CURRENT_YEAR varchar(10)
Declare @customer_id int 
-- Test Merchant Account
SET @merchant_id = 248
SET @campaign_id = 1


EXEC GET_CURRENT_SINGAPORT_DATETIME  @current_date OUTPUT
SET @year =Year (DATEADD(year,-1,@current_date))

----CHECK BEFORE EXECUTION

		EXEC GET_CURRENT_SINGAPORT_DATETIME  @current_date OUTPUT
		--SET @year =Year (DATEADD(year,-1,@current_date))
		SET @year = '2017'
		/*IF (DAY(@current_date) != '01' AND MONTH (@current_date) != '01')
		BEGIN
		SELECT 0 AS RESPONSE_CODE , 'WINKS ARE NOT EXPIRED' AS RESPONSE_MESSAGE
		Return
		END 
		ELSE IF EXISTS (SELECT 1 FROM yearly_wink_confiscated_detail WHERE year_end= @year)
		BEGIN
		SELECT 0 AS RESPONSE_CODE , 'Already executed' AS RESPONSE_MESSAGE
		Return
		END*/

		
		declare curr cursor local for select customer_id from customer_balance where customer_balance.total_winks-used_winks-confiscated_winks>0
		and customer_id !=15
		and customer_id in (1148,
2357,
2359,
2360,
2362,
2366,
2368,
2380,
2388,
2389,
2402,
2591,
2596,
2597,
2598,
2689,
2724,
2726,
2727,
2734,
2736,
2772,
2837,
2852,
2861)
			
				OPEN curr
				FETCH NEXT FROM curr INTO @customer_id
				
				WHILE (@@FETCH_STATUS = 0)
				BEGIN
				IF EXISTS (SELECT * from customer where customer.customer_id =@customer_id )
					BEGIN
					Select @confiscate_wink = total_winks -used_winks - confiscated_winks from customer_balance where customer_balance.customer_id = @customer_id
					IF (@confiscate_wink >0)
							BEGIN
							--1. Insert into WINK Confiscate Detail
								INSERT INTO yearly_wink_confiscated_detail (customer_id , merchant_id , created_at, updated_at, total_winks,year_end)
								values (@customer_id,@merchant_id,@current_date,@current_date,@confiscate_wink,@year)
				
							--2. Insert into WINK Confiscate Detail	
								INSERT INTO wink_confiscated_detail (customer_id , merchant_id , created_at, updated_at, total_winks,year_end)
								values (@customer_id,@merchant_id,@current_date,@current_date,@confiscate_wink,@year)
									
								SELECT @intErrorCode = @@ERROR
								IF (@intErrorCode = 0) 
								BEGIN
									BEGIN
									--3. Update Customer Balance 
										Update customer_balance set confiscated_winks = @confiscate_wink + confiscated_winks , expired_winks = @confiscate_wink + expired_winks where customer_balance.customer_id =@customer_id
											SELECT @intErrorCode = @@ERROR
											IF (@intErrorCode = 0) 
							
												BEGIN
													IF (@campaign_id != 0)
													BEGIN
													Update campaign set total_wink_confiscated = @confiscate_wink + total_wink_confiscated where campaign.campaign_id = @campaign_id
																
													END
										
												END
									
								
									END
								END
					
					
				
					
					
					
					
				
							END
        
					END
            
				FETCH NEXT FROM curr INTO @customer_id
				END
				close curr
				deallocate curr	
				
				SELECT 1 AS RESPONSE_CODE , 'Success' AS RESPONSE_MESSAGE
		        Return				
		
END


--select * from campaign where campaign.campaign_id =1