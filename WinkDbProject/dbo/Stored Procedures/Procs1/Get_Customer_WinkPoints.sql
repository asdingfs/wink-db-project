
CREATE PROC [dbo].[Get_Customer_WinkPoints]
@customer_tokenid VARCHAR(255)

AS
DECLARE @CUSTOMER_ID INT
DECLARE @POINT_BALANCE Decimal(10,2)

BEGIN 

	IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @customer_tokenid)                            
	BEGIN 
		SELECT TOP 1 @CUSTOMER_ID = CUSTOMER_ID FROM CUSTOMER WHERE auth_token = @customer_tokenid and customer.status = 'enable'
		
		IF EXISTS(SELECT * FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID = @CUSTOMER_ID)
		BEGIN
		-- update 15/05/2023
						 
			SELECT @POINT_BALANCE = TOTAL_POINTS - USED_POINTS - CONFISCATED_POINTS
			 FROM CUSTOMER_BALANCE 
			 WHERE CUSTOMER_ID=@CUSTOMER_ID
			 
			
			
			SELECT '1' as response_code, 'Success' as response_message, @POINT_BALANCE as points_balance 
			RETURN
		END
		ELSE
		BEGIN
			SELECT '1' as response_code, 'Success' as response_message, 0 as points_balance 
			RETURN
		END
	END
	ELSE
	BEGIN
		SELECT '0' as response_code, 'Success' as response_message, 0 as points_balance 
		RETURN
	END
	
END




