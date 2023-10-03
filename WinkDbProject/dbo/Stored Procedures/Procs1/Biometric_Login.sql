CREATE PROCEDURE [dbo].[Biometric_Login] 
(	
	@authToken varchar(255),
	@ipAddress varchar(20)
)
AS
BEGIN
	DECLARE @currentDate Datetime
	DECLARE @org_auth varchar(255)
	DECLARE @login_datetime varchar(50)

	EXEC GET_CURRENT_SINGAPORT_DATETIME @currentDate output

	DECLARE @locked_reason varchar(255);
	DECLARE @admin_user_email_for_lock_account varchar(255)  = 'system@winkwink.sg';
	DECLARE @accountLockedMsg varchar(255)= 'Your account is locked. Please contact customer service.';
	DECLARE @invalidTokenMsg varchar(255)= 'Biometric login failed. Please login using your email and password.';
	
	DECLARE @customerId int;
	DECLARE @status varchar(10);
	SELECT @customerId = customer_id, @status = [status] FROM customer WHERE auth_token like @authToken;

	--check if authToken is valid
	IF(@customerId = 0 or @customerId is null)
	BEGIN
		SELECT '0' as  response_code , @invalidTokenMsg as response_message
		RETURN
	END

	--check ip address
	IF EXISTS (Select 1 from wink_customer_block_ip where ip_address like @ipAddress)
    BEGIN
		UPDATE customer 
		SET [status] = 'disable', updated_at = @currentDate 
		WHERE auth_token = @authToken;
		IF (@@ROWCOUNT>0)
		BEGIN
			Insert into System_Log (customer_id, action_status,created_at,reason)
			Select customer_id,'disable',@currentDate,@ipAddress
			FROM customer 
			WHERE auth_token = @authToken;

			SET @locked_reason = 'Blocked IP'

			
			EXEC Create_WINK_Account_Filtering @customerId, @locked_reason,@admin_user_email_for_lock_account;
		END

		Select '0' as  response_code , @accountLockedMsg as response_message
		RETURN
    END

	--check status
	IF(@status like 'disable')
	BEGIN
		SELECT '0' as  response_code , @accountLockedMsg as response_message
		RETURN
	END

	-- Check customer authentication token
	Set @org_auth = (Select auth_token from customer_authentication_token where customer_id = @customerId);
	IF(@org_auth is not null and @org_auth !='')
	BEGIN
		-- Update Customer authentication 
		SET @login_datetime=Replace(Replace(Replace(CONVERT(VARCHAR(24), @currentDate, 121),' ',''),'.',''),':','');
		UPDATE customer 
		SET customer.auth_token = concat(@org_auth,@login_datetime) 
		WHERE customer.customer_id = @customerId;
	END
	ELSE
	BEGIN
		SELECT '0' as  response_code , @invalidTokenMsg as response_message
		RETURN
	END

	-- Insert into customer login action log
	Insert into customer_login_action_log (auth_token, customer_id, created_at)
	select auth_token,customer_id,@currentDate from customer
	where customer_id = @customerId;

    SELECT @customerId as customer_id, auth_token, [status],phone_no, 
	'1' as  response_code , 'You have successfully login' as response_message 
	FROM customer 
	WHERE customer_id = @customerId;
	RETURN
END

