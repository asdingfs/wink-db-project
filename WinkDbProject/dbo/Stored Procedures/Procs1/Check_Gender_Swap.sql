CREATE PROCEDURE [dbo].[Check_Gender_Swap]
	(@authToken varchar(255),
	 @newGender varchar(10)
	 )
AS
BEGIN
Declare @oldGender nchar(10)

DECLARE @CURRENT_DATETIME DATETIME

EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUT

DECLARE @locked_reason varchar(255)
DECLARE @locked_customer_id int 
DECLARE @admin_user_email_for_lock_account  varchar(255) 

SET @admin_user_email_for_lock_account = 'system@winkwink.sg'

	--Check if gender has been changed
		Select @oldGender = gender from customer where LTRIM(RTRIM(customer.auth_token)) = @authToken;

		

		IF(LTRIM(RTRIM(@oldGender)) = 'Female' and LTRIM(RTRIM(@newGender)) = 'Male')
		BEGIN
			Update customer set customer.status = 'disable', customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @authToken;

			IF (@@ROWCOUNT>0)
			BEGIN
				Insert into System_Log (customer_id, action_status,created_at,reason)
				Select customer.customer_id,
				'disable',@CURRENT_DATETIME,'Gender Swap'
				from customer where customer.auth_token = @authToken;

	 
	 			-----INSERT INTO ACCOUNT FILTERING LOCK
			
				Select @locked_customer_id = customer.customer_id from customer where customer.auth_token = @authToken
				set @locked_reason ='Gender Swap';
				 
				EXEC Create_WINK_Account_Filtering @locked_customer_id,@locked_reason,@admin_user_email_for_lock_account
				SELECT '3' as response_code, 'Your account is locked. Please contact customer service.' as response_message 

				RETURN

			END
		END
		ELSE IF(LTRIM(RTRIM(@oldGender))  = 'Male' and LTRIM(RTRIM(@newGender)) = 'Female')
		BEGIN
			Update customer set customer.status = 'disable', customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @authToken;

			IF (@@ROWCOUNT>0)
			BEGIN
				Insert into System_Log (customer_id, action_status,created_at,reason)
				Select customer.customer_id,
				'disable',@CURRENT_DATETIME,'Gender Swap'
				from customer where customer.auth_token = @authToken;

	 
	 			-----INSERT INTO ACCOUNT FILTERING LOCK
			
				Select @locked_customer_id = customer.customer_id from customer where customer.auth_token = @authToken
				set @locked_reason ='Gender Swap';
				 
				EXEC Create_WINK_Account_Filtering @locked_customer_id,@locked_reason,@admin_user_email_for_lock_account
				SELECT '3' as response_code, 'Your account is locked. Please contact customer service.' as response_message 

				RETURN

			END
		END

END

