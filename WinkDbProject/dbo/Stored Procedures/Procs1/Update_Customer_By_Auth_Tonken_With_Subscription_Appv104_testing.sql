CREATE PROCEDURE [dbo].[Update_Customer_By_Auth_Tonken_With_Subscription_Appv104_testing]
	(@token_id varchar(255),
	 @first_name varchar(50),
	 @last_name varchar(50),
	 @email varchar(50),
	 @date_of_birth date,
	 @password varchar(100),
	 @gender varchar(10),
	 @updated_at datetime,
	 @phone_no varchar(15),
	 @avatar_id int,
	 @avatar_image varchar(250),
	 @skin_name varchar(50),
	 @team_name varchar(50),
	 @nick_name varchar(30),
	 @subscription_status int,
	 @biometrics int
	 )
AS
BEGIN
	DECLARE @CUSTOMER_ID INT
	DECLARE @OLD_EMAIL VARCHAR(50)

	Declare @oldGender varchar(10)

	DECLARE @CURRENT_DATETIME DATETIME

	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUT

	DECLARE @locked_reason varchar(255)
	DECLARE @locked_customer_id int 
	DECLARE @admin_user_email_for_lock_account  varchar(255) 

	Declare @team_id int

	SET @admin_user_email_for_lock_account = 'system@winkwink.sg';


	select @team_id = ISNULL (team_id,1) from wink_team where team_name = @team_name;

	if(@team_id is null or @team_id ='')
		set @team_id =1;

	IF EXISTS (SELECT customer.customer_id FROM CUSTOMER WHERE LTRIM(RTRIM(customer.auth_token)) = @token_id)
	BEGIN
		--- Check Account locked
		IF EXISTS (SELECT customer.customer_id FROM CUSTOMER WHERE LTRIM(RTRIM(customer.auth_token)) = @token_id and status ='disable')
		BEGIN
			select 3 as response_code , 'Account locked. Please contact customer service.' as response_message
			Return
		END
		
		--Check Existing Email 
		
		IF NOT EXISTS (Select * from customer where customer.email = @email and LTRIM(RTRIM(customer.auth_token)) 
		!= @token_id)
		BEGIN
			-- Check Phone No
			IF NOT EXISTS (Select * from customer where customer.phone_no = @phone_no and LTRIM(RTRIM(customer.auth_token)) != @token_id)
			BEGIN
					
				IF (@password IS NOT NULL AND @password !='')
				BEGIN
					UPDATE customer SET 
					first_name =@first_name ,
					last_name=@last_name,
					email=@email,
					customer.[password]=@password,
					gender=@gender,
					date_of_birth=@date_of_birth,
					updated_at=@updated_at,
					phone_no = @phone_no,
					avatar_id = @avatar_id,
					avatar_image = @avatar_image,
					skin_name = @skin_name,
					team_id =@team_id,
					nick_name =@nick_name,
					subscribe_status = @subscription_status,
					biometrics = @biometrics
					Where LTRIM(RTRIM(customer.auth_token)) = @token_id
					
				END
				ELSE
				BEGIN
					UPDATE customer SET 
					first_name =@first_name ,
					last_name=@last_name,
					email=@email,
					gender=@gender,
					date_of_birth=@date_of_birth,
					updated_at=@updated_at,phone_no = @phone_no,
					avatar_id = @avatar_id,
					avatar_image = @avatar_image,
					skin_name = @skin_name,
					team_id =@team_id,
					nick_name =@nick_name,
					subscribe_status = @subscription_status,
					biometrics = @biometrics
					Where LTRIM(RTRIM(customer.auth_token)) = @token_id
				END
						
				IF (@@ROWCOUNT>0)
				BEGIN

					IF(@date_of_birth is not null)
					BEGIN
						declare @age int;

						set @age = (select floor(datediff(day,@date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25));

						IF( @age <= 0 or @age > 90)
						BEGIN

							SELECT @customer_id = customer.customer_id FROM CUSTOMER WHERE LTRIM(RTRIM(customer.auth_token)) = @token_id;

							Update customer set customer.status = 'disable',
							customer.updated_at = @CURRENT_DATETIME where customer.customer_id = @customer_id;

							IF (@@ROWCOUNT>0)
							BEGIN
								Set @locked_reason = 'Year of birth is '+convert(varchar(4), convert(datetime, @date_of_birth,112), 112)+'.';

								Insert into System_Log (customer_id, action_status,created_at,reason)
								Select customer.customer_id,
								'disable',@CURRENT_DATETIME,@locked_reason
								from customer where customer.customer_id = @customer_id;

								-----INSERT INTO ACCOUNT FILTERING LOCK
								EXEC Create_WINK_Account_Filtering @customer_id,@locked_reason,@admin_user_email_for_lock_account;
							END
						END
					END
					SELECT '1' as response_code, 'Profile Updated' As response_message
				END
				ELSE 
				BEGIN
					SELECT '0' as response_code, 'Fail to save' As response_message
				END	
			END
			ELSE
			BEGIN
				SELECT '0' as response_code, 'Mobile no. already in use' As response_message
			END
		END
		Else
		BEGIN
			SELECT '0' as response_code, 'Email already in use' As response_message
		END
					
	END
	ELSE 
	BEGIN
		--SELECT '0' as response_code, 'User is not authorized!' As response_message
		SELECT '2' as response_code, 'Multiple Logins not allowed.' As response_message
	END
END


