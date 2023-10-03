-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 

CREATE PROCEDURE [dbo].[Edit_Card_By_TokenId]
(
	@authToken VARCHAR(255),
    @id int,
	@cardId VARCHAR(100),
	@cardTag VARCHAR(20)
)
AS
BEGIN
	DECLARE @curCardID varchar(100);
	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 
	
	IF (@id is null or @id = 0)
	BEGIN
		SET @id = NULL;
	END

	IF (@cardId is null or @cardId = '')
	BEGIN
		SET @cardId = NULL;
	END

	IF (@cardTag is null or @cardTag = '')
	BEGIN
		SET @cardTag = NULL;
	END

	IF EXISTS(SELECT * FROM customer WHERE auth_token = @authToken) --CUSTOMER EXISTS                           
	BEGIN
		SELECT @curCardID = customer_canid FROM can_id WHERE id = @id;

		UPDATE can_id 
		SET customer_canid = @cardId,
		can_id_key = @cardId,
		card_tag = @cardTag
		Where can_id.id = @id;
		
		IF(@@ROWCOUNT>0)
		BEGIN

			SELECT '1' as response_code,'Successfully updated' as response_message, @curCardID as prevCardId;
			return
			
		END
		ELSE
		BEGIN
			SELECT '0' as response_code, 'Failed to update' as response_message 
			RETURN
		END
		
		
	END 
	ELSE-- CUSTOMER DOES NOT EXISTS
	BEGIN
		SELECT '0' as response_code, 'Customer is not authorised' as response_message 
		RETURN
	END
	
END

