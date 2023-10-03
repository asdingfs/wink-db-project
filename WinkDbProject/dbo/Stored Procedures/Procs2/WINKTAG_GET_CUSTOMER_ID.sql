
CREATE PROC [dbo].[WINKTAG_GET_CUSTOMER_ID]
@token varchar(255)

AS
BEGIN
	IF EXISTS (SELECT * FROM VW_ACTIVE_CUSTOMER WHERE auth_token = @token)
	BEGIN
		SELECT '1' as response_code,'Success' as response_message, customer_id FROM CUSTOMER WHERE auth_token = @token
		return
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Customer' as response_message

		return
	END
	
END

