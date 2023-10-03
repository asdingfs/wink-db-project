-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 

CREATE PROCEDURE [dbo].[CreateNew_CANID_BY_TokenId_With_CAN_ID_Key]
	(@customer_tokenid VARCHAR(255),
      @can_id VARCHAR(100),
      @can_id_key VARCHAR(50)    
      
      )
AS
BEGIN
	DECLARE @CUSTOMER_ID int

	DECLARE @CUSTOMER_EMAIL varchar(255)
	DECLARE @CUSTOMER_NAME varchar(255)

	DECLARE @CURRENT_DATETIME datetime
	DECLARE @TOTAL_CANID INT
	SET @CURRENT_DATETIME = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');
	IF EXISTS(SELECT * FROM customer WHERE auth_token = @customer_tokenid) --CUSTOMER EXISTS                           
	BEGIN
		SELECT TOP 1 @CUSTOMER_ID = customer.customer_id, @CUSTOMER_EMAIL=customer.email, @CUSTOMER_NAME= customer.first_name +' '+customer.last_name
		
		FROM customer WHERE auth_token = @customer_tokenid
		
		
		SET @TOTAL_CANID = ISNULL((SELECT COUNT(can_id.id) FROM can_id WHERE can_id.customer_id=@CUSTOMER_ID
		GROUP BY can_id.customer_id),0)
		-- CHECK CUSTOMER TOTAL CAN ID
		IF(@TOTAL_CANID <3)
		BEGIN
			INSERT INTO can_id(customer_canid,customer_id,created_at,updated_at,can_id_key)
			VALUES (@can_id,@CUSTOMER_ID,@CURRENT_DATETIME,@CURRENT_DATETIME,@can_id_key)
		
			IF(@@ROWCOUNT>0)
			BEGIN
				SELECT can_id.customer_canid, @CUSTOMER_EMAIL As customer_email, @CUSTOMER_NAME As name,'1' as response_code FROM can_id WHERE can_id.customer_id =@CUSTOMER_ID
				RETURN
			END
			ELSE
				BEGIN
				SELECT '0' as response_code, 'Insert fail' as response_message 
			RETURN
			END
		END
		ELSE
			BEGIN
		     SELECT '0' as response_code, 'Customer has exceeded the maximum limit of total CAN ID' as response_message 
		
			END
		
		
	END 
	ELSE-- CUSTOMER DOES NOT EXISTS
	BEGIN
		SELECT '0' as response_code, 'Customer does not exist' as response_message 
		RETURN
	END
	
END
