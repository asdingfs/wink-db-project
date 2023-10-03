CREATE PROCEDURE [dbo].[UPDATE_CAN_ID_BY_CANID_KEY]
(@CAN_ID VARCHAR(50),
@CAN_ID_KEY VARCHAR(50),
@updated_at datetime
)
AS
BEGIN
DECLARE @EXISTING_CANID VARCHAR(50)
DECLARE @EXISTING_KEY VARCHAR(50)
	---CHECK DUPLICATE CAN ID
	IF EXISTS (SELECT can_id.customer_canid FROM can_id WHERE can_id.customer_canid =@CAN_ID)
		BEGIN
	
			SET @EXISTING_KEY = (SELECT can_id.can_id_key FROM can_id WHERE can_id.customer_canid = @CAN_ID)
			
			IF(@EXISTING_KEY = @CAN_ID_KEY)
		
			BEGIN
			
			--UPDATE can_id SET customer_canid=@CAN_ID , can_id_key = @CAN_ID WHERE can_id_key = @CAN_ID_KEY
			--IF(@@ROWCOUNT>0)
				--BEGIN
					SELECT '1' AS response_code , 'CAN ID is successfully updated!' AS response_message
					RETURN
				--END
			--ELSE
			/*	BEGIN
				SELECT '0' AS response_code , 'Fail to update CAN ID!' AS response_message
				END*/
			END
			ELSE 
				BEGIN
					SELECT '2' AS response_code , 'CAN ID is already in use!' AS response_message
					RETURN
				END
						
		END
			
	
	ELSE 
	
		BEGIN
			
			UPDATE can_id SET customer_canid=@CAN_ID , can_id_key = @CAN_ID , updated_at = @updated_at WHERE can_id_key = @CAN_ID_KEY
			IF(@@ROWCOUNT>0)
				BEGIN
					SELECT '1' AS response_code , 'CAN ID is successfully updated!' AS response_message
					RETURN
				END
			ELSE 
				BEGIN
					SELECT '0' AS response_code , 'Fail to update CAN ID!' AS response_message
					RETURN
				END
						
			END
	
		
END
