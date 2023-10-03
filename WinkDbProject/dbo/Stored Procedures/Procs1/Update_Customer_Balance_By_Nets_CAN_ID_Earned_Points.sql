

CREATE PROCEDURE [dbo].[Update_Customer_Balance_By_Nets_CAN_ID_Earned_Points]
	(@canId varchar(50),
	 @points int)
AS
BEGIN
	DECLARE @CUSTOMER_ID INT
--	IF EXISTS (SELECT * FROM can_id WHERE can_id.customer_canid = @canId)
IF EXISTS (select * from can_id where can_id.customer_canid = @canId
	and can_id.customer_id IN (select customer.customer_id from customer where customer.status='enable')
	)
		BEGIN
		
			SET @CUSTOMER_ID = (SELECT can_id.customer_id FROM can_id WHERE can_id.customer_canid = @canId)
			IF (@CUSTOMER_ID IS NOT NULL AND @CUSTOMER_ID !='')
			BEGIN
				IF EXISTS (SELECT * FROM customer_balance WHERE customer_balance.customer_id =@CUSTOMER_ID)
				BEGIN
									
							UPDATE customer_balance 
							SET total_points=(customer_balance.total_points + @points)
							WHERE customer_balance.customer_id = @CUSTOMER_ID
							
							IF (@@ROWCOUNT>0)
								BEGIN 
								SELECT '1' AS response_code
		
								END 
								ELSE 
								BEGIN 
								SELECT '0' AS response_code , 'Update Fail' as response_message, @canId as can_id
								RETURN
		
								END 
								
		
							
					 	
					
				
				END
				ELSE 
					BEGIN
					
						INSERT INTO customer_balance (total_points,customer_id)
						VALUES (@points,@CUSTOMER_ID)
							IF (@@ROWCOUNT>0)
								BEGIN 
								SELECT '1' AS response_code
		
								END 
								ELSE 
								BEGIN 
								SELECT '0' AS response_code , 'Insert Fail' as response_message, @canId as can_id
								RETURN
		
								END 
					
					END
						
			
		
			END
			
		
		END
	
	ELSE 
		BEGIN 
			SELECT '0' AS response_code , 'No CAN ID Registration' as response_message
			RETURN
		
		END 
	
END



