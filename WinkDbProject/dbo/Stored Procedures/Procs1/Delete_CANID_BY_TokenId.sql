-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 

CREATE PROCEDURE [dbo].[Delete_CANID_BY_TokenId]
	(@customer_tokenid VARCHAR(255),
      @can_id VARCHAR(100))
AS
BEGIN
	DECLARE @CUSTOMER_ID int
	DECLARE @CURRENT_DATETIME datetime
	DECLARE @TOTAL_CANID INT
	SET @CURRENT_DATETIME = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');
	IF EXISTS(SELECT * FROM customer WHERE auth_token = @customer_tokenid) --CUSTOMER EXISTS                           
	BEGIN
		SELECT TOP 1 @CUSTOMER_ID = customer.customer_id FROM customer WHERE auth_token = @customer_tokenid;

		Delete can_id Where can_id.customer_canid = @can_id
		and can_id.customer_id =@CUSTOMER_ID;
		
		IF(@@ROWCOUNT>0)
		BEGIN

			SELECT '1' as response_code,'Successfully deleted' as response_message;
			return
			--SET @TOTAL_CANID =(SELECT COUNT(*) FROM can_id WHERE can_id.customer_id = @CUSTOMER_ID)
			--IF @TOTAL_CANID>0
			--	BEGIN
			--	SELECT can_id.customer_canid,'1' as response_code,'Successfully deleted' as response_message FROM can_id WHERE can_id.customer_id =@CUSTOMER_ID
			--	END
			--ELSE 
			--	BEGIN
			--	SELECT '2' as response_code ,'Successfully deleted' as response_message
			--	END
			--RETURN
			
		END
		ELSE
		BEGIN
			SELECT '0' as response_code, 'Failed to delete' as response_message 
			RETURN
		END
		
		
	END 
	ELSE-- CUSTOMER DOES NOT EXISTS
	BEGIN
		SELECT '0' as response_code, 'Customer is not authorised' as response_message 
		RETURN
	END
	
END

