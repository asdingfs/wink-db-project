CREATE PROCEDURE [dbo].[ThirdParty_Update_Customer_By_UniqueId]
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
	 @nick_name varchar(30)
	 )
AS
BEGIN
DECLARE @CUSTOMER_ID INT 
DECLARE @OLD_EMAIL VARCHAR(50)

Declare @team_id int



--- After implementing Thirdparty Unified
Declare @unique_id varchar(250)

	IF NOT EXISTS (select 1 from customer where customer.auth_token =@token_id)
	BEGIN
		IF EXISTS (select 1 from customer where customer.customer_unique_id = @token_id)
		BEGIN
		set @token_id = (select customer.auth_token from customer where customer_unique_id = @token_id)
		END

	END

	IF(@team_name is null or  @team_name ='')
		BEGIN
		select @team_id = team_id from customer where customer.auth_token = @token_id
		END
		ELSE
		BEGIN
		select @team_id = ISNULL (team_id,1) from wink_team where team_name = @team_name
		END
	--------------------END Thirdparty Unified 


	IF EXISTS (SELECT customer.customer_id FROM CUSTOMER WHERE LTRIM(RTRIM(customer.auth_token)) = @token_id)
		BEGIN
		
		--Check Existing Email 
		
		--SET @OLD_EMAIL = (SELECT CUSTOMER.email FROM customer WHERE LTRIM(RTRIM(customer.auth_token)) = @token_id)	
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
						customer.password=@password,
						gender=@gender,
						date_of_birth=@date_of_birth,
						updated_at=@updated_at,
						phone_no = @phone_no,
						--avatar_id = @avatar_id,
						--avatar_image = @avatar_image,
						--skin_name = @skin_name,
						team_id =@team_id,
						nick_name =@nick_name
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
						nick_name =@nick_name
						Where LTRIM(RTRIM(customer.auth_token)) = @token_id
						
						END
						
						IF (@@ROWCOUNT>0)
						SELECT '1' as response_code, 'Successfully saved' As response_message
						else 
						SELECT '0' as response_code, 'Fail to save' As response_message
						
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


