CREATE PROCEDURE [dbo].[Check_Age_Update]
	(@authToken varchar(255),
	 @dob varchar(100),
	 @ip varchar(100)
	 )
AS
BEGIN
Declare @oldDob varchar(100);

DECLARE @CURRENT_DATETIME DATETIME

EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUT

DECLARE @locked_reason varchar(255)
DECLARE @locked_customer_id int 
DECLARE @admin_user_email_for_lock_account  varchar(255) 

SET @admin_user_email_for_lock_account = 'system@winkwink.sg'

		--Check current dob
		Select @oldDob = date_of_birth from customer where LTRIM(RTRIM(customer.auth_token)) = @authToken;

		declare @customerId int;
		declare @email varchar(200);

		IF(@oldDob != @dob)
		BEGIN
			SELECT @customerId = customer_id, @email = email
			from customer
			where auth_token = @authToken;

			Insert into customer_action_log(customer_id, ip_address,customer_action, created_at,token_id,email)
			SELECT @customerId, @ip, 'age_update',@CURRENT_DATETIME,@authToken, @email
			from customer where auth_token = @authToken;

			
			IF((SELECT COUNT(customer_action) from customer_action_log where customer_id = @customerId and customer_action like 'age_update')>1)
			BEGIN
				Update customer set customer.status = 'disable', customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @authToken;
				IF (@@ROWCOUNT>0)
				BEGIN
					Insert into System_Log (customer_id, action_status,created_at,reason)
					Select customer.customer_id,
					'disable',@CURRENT_DATETIME,'Update DOB to '+@dob
					from customer where customer.auth_token = @authToken;

	 
	 				-----INSERT INTO ACCOUNT FILTERING LOCK
			
					Select @locked_customer_id = customer.customer_id from customer where customer.auth_token = @authToken
					set @locked_reason ='Update DOB to '+@dob;
				 
					EXEC Create_WINK_Account_Filtering @locked_customer_id,@locked_reason,@admin_user_email_for_lock_account
					SELECT '3' as response_code, 'Your account is locked. Please contact customer service.' as response_message 

					RETURN

				END
			END
		END
		
END

