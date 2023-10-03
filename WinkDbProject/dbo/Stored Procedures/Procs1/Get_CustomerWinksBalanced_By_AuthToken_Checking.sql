CREATE PROCEDURE [dbo].[Get_CustomerWinksBalanced_By_AuthToken_Checking]
(@customer_tokenid varchar(255)
)
AS
BEGIN
DECLARE @CUSTOMER_ID INT
DECLARE @RATE_VALUE INT
DECLARE @CUSTOMER_POINTS_BALANCE INT

	IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @customer_tokenid)                            
	BEGIN 
		SELECT TOP 1 @CUSTOMER_ID = CUSTOMER_ID FROM CUSTOMER WHERE auth_token = @customer_tokenid 
		IF EXISTS(SELECT * FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID = @CUSTOMER_ID)
		BEGIN
			SELECT @RATE_VALUE = RATE_VALUE FROM RATE_CONVERSION WHERE RATE_CODE = 'points_per_wink'

			SELECT @CUSTOMER_POINTS_BALANCE =(TOTAL_POINTS - (USED_POINTS + CONFISCATED_POINTS)) FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID=@CUSTOMER_ID
			IF (@CUSTOMER_POINTS_BALANCE >= @RATE_VALUE)
			BEGIN
			SELECT @CUSTOMER_POINTS_BALANCE AS BALANCED_POINTS , '1' AS response_code,
			'Success' as response_message
			RETURN
			END
			ELSE
		    			
			SELECT 0 AS BALANCED_POINTS , '0' AS response_code,
			'Not enough points to redeem' as response_message
			RETURN
		END
		ELSE
		BEGIN
		   SELECT '0' AS response_code,
			'Customer is not authenticate' as response_message
		   RETURN
		END
		
	END
END
