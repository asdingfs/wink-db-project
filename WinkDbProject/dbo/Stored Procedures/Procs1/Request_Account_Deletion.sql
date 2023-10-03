CREATE PROCEDURE [dbo].[Request_Account_Deletion]
(
	@authToken varchar(150)
)
AS
BEGIN

	DECLARE @CURRENT_DATETIME Datetime
	DECLARE @locked_reason varchar(255) = 'Account Deletion Requested'
	DECLARE @admin_user_email_for_lock_account  varchar(255) 
	
	SET @admin_user_email_for_lock_account = 'system@winkwink.sg'
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT;

	DECLARE @customerId int;
	SELECT @customerId = customer_id FROM customer where auth_token like @authToken;

	UPDATE customer 
	SET [status] = 'disable', updated_at = @CURRENT_DATETIME 
	WHERE customer_id = @customerId;

	IF (@@ROWCOUNT>0)
	BEGIN
		Insert into System_Log (customer_id, action_status,created_at,reason)
		VALUES(@customerId, 'disable',@CURRENT_DATETIME,@locked_reason);

		-----INSERT INTO ACCOUNT FILTERING LOCK
		EXEC Create_WINK_Account_Filtering @customerId,@locked_reason,@admin_user_email_for_lock_account;
		
		SELECT '1' as response_code, 'Your request has been forwarded to the WINK+ team and your account is currently disabled. An email will be sent to you for proof of account ownership and confirmation of account deletion request.' as response_message;
		RETURN
		
	END
	ELSE
	BEGIN
		SELECT '0' as response_code, 'Oops, something is wrong. Please try again later.' as response_message;
		RETURN
	END
END