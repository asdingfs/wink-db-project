
CREATE PROCEDURE [dbo].[CreateNewMerchant]
(@first_name varchar(100),
 @last_name varchar(100),
 @email varchar(100),
 @password varchar(100),
 @mas_code varchar(100),
 @imobshop_merchant_id int,
 @auth_toke varchar(100))
 --@merchant_id int output)
  	
AS
BEGIN

DECLARE @CURRENT_DATE DATETIME

EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT
	INSERT INTO [winkwink].[dbo].[merchant]
           ([first_name]
           ,[last_name]
           ,[email]
           ,[password]
           ,[mas_code]
           ,[imobshop_merchant_id]
           ,[auth_token]
           ,created_at 
           ,updated_at)
     VALUES
           (@first_name,@last_name,@email,@password,@mas_code,@imobshop_merchant_id,@auth_toke,
            @CURRENT_DATE,@CURRENT_DATE
            )
            
      Select SCOPE_IDENTITY()

END

