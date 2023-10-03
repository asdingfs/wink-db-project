CREATE PROCEDURE [dbo].[WINK_Confiscated]
	(@customer_id int
	-- @merchant_id int
	 )
	 
	 
AS
BEGIN
DECLARE @confiscate_wink int 
DECLARE @intErrorCode INT
DECLARE @current_date datetime
DECLARE @campaign_id int
DECLARE @merchant_id int

SET @merchant_id = 64

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

	BEGIN Transaction 
		BEGIN TRY
	IF EXISTS (SELECT * from customer where customer.customer_id =@customer_id and customer.status = 'disable')
		BEGIN
			Select @confiscate_wink = total_winks - used_winks - confiscated_winks from customer_balance where customer_balance.customer_id = @customer_id
			
			IF (@confiscate_wink !=0)
				BEGIN
				--1. Insert into WINK Confiscate Detail
					INSERT INTO wink_confiscated_detail (customer_id , merchant_id , created_at, updated_at, total_winks)
					values (@customer_id,@merchant_id,@current_date,@current_date,@confiscate_wink)
					
					SELECT @intErrorCode = @@ERROR
					IF (@intErrorCode <> 0) 
					BEGIN
					GOTO ERROR
					END
					ELSE
						BEGIN
						--2. Update Customer Balance 
							Update customer_balance set confiscated_winks = @confiscate_wink+confiscated_winks where customer_balance.customer_id =@customer_id
								SELECT @intErrorCode = @@ERROR
								IF (@intErrorCode <> 0) 
									BEGIN
								GOTO ERROR
									END
								ELSE
									BEGIN
										/*Set @campaign_id = (Select Top 1 campaign.campaign_id from campaign
										where campaign.merchant_id =@merchant_id and 
										CAST (campaign.campaign_end_date AS DATE) >= CAST (@current_date as Date)
										order by campaign.campaign_id desc)*/

										SET @campaign_id = 1

										IF (@campaign_id != 0)
										BEGIN
										Update campaign set total_wink_confiscated = @confiscate_wink + total_wink_confiscated where campaign.campaign_id = @campaign_id
										
										SELECT @intErrorCode = @@ERROR
										IF (@intErrorCode <> 0) GOTO ERROR
										
										
									
										
								
										END
										
									END
									
								
						END
						
					-- Commit Trans
						
					IF(@intErrorCode=0)
					BEGIN
						SELECT '1' as response_code, 'User is successfully updated' As response_message
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
	Select '0' as response_code , 'Fail to confiscate wink' as response_message
	RETURN
    
    END
		
END
