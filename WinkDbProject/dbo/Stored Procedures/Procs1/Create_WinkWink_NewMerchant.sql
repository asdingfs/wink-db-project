CREATE Procedure [dbo].[Create_WinkWink_NewMerchant]
(
@first_name varchar(150),
@last_name varchar(150),
@email varchar(150),
@password varchar(255),
@mas_code varchar(20),
--@gender varchar (10),
--@dob datetime,
@auth_token varchar(255),
@imob_merchant_id int,
@created_at DateTime,
@updated_at DateTime

)

AS 
BEGIN
DECLARE @merchant_id int 
INSERT INTO merchant
           ([first_name]
           ,[last_name]
           ,[email]
           ,[password]
           ,[mas_code]
           --,[gender]
          -- ,[date_of_birth]
           ,[auth_token]
           ,[imobshop_merchant_id]
           ,[created_at]
           ,[updated_at])
     VALUES
          (
          
       
@first_name ,
@last_name ,
@email ,
@password ,
@mas_code,
--@gender ,
--@dob ,
@auth_token ,
@imob_merchant_id,
@created_at ,
@updated_at 
)

If(@@ROWCOUNT>0)
BEGIN
Set @merchant_id = (Select SCOPE_IDENTITY())
INSERT INTO master_user_group_relationship (master_group_id,email)
VALUES (1, @email)

	IF (@@ROWCOUNT>0)
	BEGIN
	SELECT '1' AS response_code , 'New merchant is successfully created' AS response_code,@merchant_id AS merchant_id
	RETURN
	END
	ELSE 
	BEGIN
	SELECT '0' AS response_code , 'New merchant is successfully created' AS response_code,0 AS merchant_id
	RETURN
	END
	
END
END
