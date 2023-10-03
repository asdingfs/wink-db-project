CREATE PROCEDURE [dbo].[GetAllCanIdsByAuthToken]
	-- Add the parameters for the stored procedure here
	(@customer_tokenid VARCHAR(255))
AS
BEGIN
	DECLARE @CUSTOMER_ID int
	
	IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @customer_tokenid)                            
	BEGIN 
		SELECT TOP 1 @CUSTOMER_ID = CUSTOMER_ID FROM CUSTOMER WHERE auth_token = @customer_tokenid 
		IF @CUSTOMER_ID IS NOT NULL 
		BEGIN 
		SELECT * FROM can_id WHERE can_id.customer_id =@CUSTOMER_ID
		
		END
	END
		
		 
END
