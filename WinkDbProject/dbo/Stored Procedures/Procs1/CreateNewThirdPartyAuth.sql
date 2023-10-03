
CREATE PROCEDURE [dbo].[CreateNewThirdPartyAuth]
(@merchant_id int,
 @email varchar(100),
 @merchant_name varchar(200)
 --@secret_key varchar(200) output
 )
  	
AS
BEGIN

DECLARE @CURRENT_DATE DATETIME
DECLARE @secret_key varchar(255)

SET @secret_key = NEWID()

EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT
IF NOT EXISTS (Select * from thirdparty_authentication where thirdparty_authentication.secret_key = 
@secret_key)
	BEGIN
		IF NOT EXISTS (SELECT * From thirdparty_authentication where merchant_id = 
@merchant_id)
			BEGIN
				INSERT INTO thirdparty_authentication
					   
(merchant_id,merchant_email,secret_key,created_at,updated_at,merchant_name)
				 VALUES
					   
(@merchant_id,@email,@secret_key,@CURRENT_DATE,@CURRENT_DATE,@merchant_name)
			           
				 SELECT * from thirdparty_authentication where 
thirdparty_authentication.merchant_id = @merchant_id
				 return
			END
		ELSE
			BEGIN
				Select 'Duplicate Merchant ID' as result 
				RETURN
			END 
    END
 ELSE 
	BEGIN
	 SELECT 'Auth already exist' as result
	 return
	
	END

END

--select * from thirdparty_authentication

--update thirdparty_authentication set merchant_name = 'Go Sushi' where merchant_id =1

--Alter table thirdparty_authentication add status_auth bit default 1

--Alter table thirdparty_authentication add merchant_name varchar(200)


