CREATE PROCEDURE [dbo].[Update_Merchant_By_iMOB_ID]
	(@imob_merchant_id varchar(100),
	 @first_name varchar(50),
	 @last_name varchar(50),
	 @email varchar(50),
	 @mas_code varchar(20),
	-- @date_of_birth date,
	 @password varchar(100),
	-- @gender varchar(10),
	
	 @updated_at datetime
	 )
AS
BEGIN
DECLARE @MERCHANT_ID INT 
DECLARE @OLD_EMAIL VARCHAR(50)
	IF EXISTS (SELECT merchant.merchant_id FROM merchant WHERE LTRIM(RTRIM(merchant.imobshop_merchant_id)) = @imob_merchant_id)
		BEGIN
		SET @OLD_EMAIL = (SELECT merchant.email FROM merchant WHERE merchant.imobshop_merchant_id = @imob_merchant_id)	
		IF (@password IS NOT NULL AND @password !='')
		
			BEGIN
				UPDATE merchant SET 
				first_name =@first_name ,
                last_name=@last_name,
                email=@email,
                merchant.password=@password,
                mas_code =@mas_code,
               -- gender=@gender,
               -- date_of_birth=@date_of_birth,
                updated_at=@updated_at
                Where LTRIM(RTRIM(merchant.imobshop_merchant_id)) = @imob_merchant_id
			
			END
			ELSE
				BEGIN
				
				UPDATE merchant SET 
				first_name =@first_name ,
                last_name=@last_name,
                email=@email,
                mas_code =@mas_code,
               -- gender=@gender,
               -- date_of_birth=@date_of_birth,
                updated_at=@updated_at
                Where LTRIM(RTRIM(merchant.imobshop_merchant_id)) = @imob_merchant_id
				
				END
			IF(@@ROWCOUNT>0)
				BEGIN
			     -- Update Master User Group Rel
				    IF(LTRIM(RTRIM(@email))!=LTRIM(RTRIM(@old_email)))
						BEGIN
							UPDATE master_user_group_relationship SET email = @email WHERE email = @old_email
						END
					SELECT '1' AS response_code , 'User data is successfully updated!' As response_message
					RETURN 
				END
			ELSE
			
				BEGIN
					SELECT '1' AS response_code , 'Fail to update user data!' As response_message
				
				END
			
			
		
		END
		ELSE 
			BEGIN
				SELECT '0' as response_code, 'User is not authorized!' As response_message
		
			END
	
END
