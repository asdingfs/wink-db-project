CREATE Procedure [dbo].[Create_New_Merchant]
(
@first_name varchar(150),
@email varchar(150),
@mas_code varchar(20),
@auth_token varchar(255),
@industry_id int,
@created_at DateTime,
@updated_at DateTime,
@wink_fee int
)

AS 
BEGIN
DECLARE @merchant_id int 

IF NOT EXISTS(SELECT mas_code from merchant where mas_code like @mas_code)
BEGIN
	INSERT INTO merchant
           ([first_name]
		   ,[last_name]
           ,[email]
           ,[mas_code]
           ,[auth_token]
           ,[created_at]
           ,[updated_at]
		   ,[wink_fee_percent])
     VALUES
          (
			@first_name ,
			'',
			@email ,
			@mas_code,
			@auth_token ,
			@created_at ,
			@updated_at,
			@wink_fee 
			);

	If(@@ROWCOUNT>0)
	BEGIN
		Set @merchant_id = (Select SCOPE_IDENTITY())
		INSERT INTO master_user_group_relationship (master_group_id,email)
		VALUES (1, @email);

		
			IF (@@ROWCOUNT>0)
			BEGIN
				IF(@industry_id != 0)
				BEGIN
					INSERT INTO merchant_industry (merchant_id,industry_id)
					VALUES (@merchant_id,@industry_id);
				END

				SELECT '1' AS response_code , 'New merchant is successfully created.' AS response_message,@merchant_id AS merchant_id
				RETURN
				
				
			END
			ELSE 
			BEGIN
				SELECT '0' AS response_code , 'Adding of new merchant to the master user group is unsuccessful.' AS response_message,0 AS merchant_id
				RETURN
			END
	END
	ELSE 
	BEGIN
		SELECT '0' AS response_code , 'Creation of the new merchant is unsuccessful.' AS response_message,0 AS merchant_id
		RETURN
	END
END

ELSE
BEGIN
	SELECT '0' AS response_code , 'Please enter a unique MAS code.' AS response_message,0 AS merchant_id
	RETURN
END
END
