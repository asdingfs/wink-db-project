CREATE Procedure [dbo].[CreateNewCustomer]
(
@user_id int out,
@first_name varchar(150),
@last_name varchar(150),
@email varchar(150),
@password varchar(255),
@gender varchar (10),
@dob varchar(10),
@auth_token varchar(255),
@created_at DateTime,
@updated_at DateTime

)

AS 
BEGIN

INSERT INTO customer
           ([first_name]
           ,[last_name]
           ,[email]
           ,[password]
           ,[gender]
           ,[date_of_birth]
           ,[auth_token]
           ,[created_at]
           ,[updated_at])
     VALUES
          (
          
       
@first_name ,
@last_name ,
@email ,
@password ,
@gender ,
@dob ,
@auth_token ,
@created_at ,
@updated_at 
)

If(@@ROWCOUNT>0)
Set @user_id = (Select SCOPE_IDENTITY())

END
