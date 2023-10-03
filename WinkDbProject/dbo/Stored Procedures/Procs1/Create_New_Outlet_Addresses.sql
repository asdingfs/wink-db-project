CREATE PROCEDURE [dbo].[Create_New_Outlet_Addresses]
	(
	
	@merchant_id varchar (150),
	@branch_code int,
	  @outlet_address varchar (150) ,
	  @postal_code int ,
	  @phone varchar (150),
	  @created_at datetime
	  )
	  
AS
BEGIN

	DECLARE @status varchar(10)

	SET @status = (SELECT branch_status FROM branch where branch_code = @branch_code)
	INSERT INTO merchant_partners_address 
    (merchant_id,branch_code,outlet_address,postal_code,phone,created_at,status)
    VALUES (@merchant_id,@branch_code,@outlet_address,@postal_code,@phone,@created_at, @status)
    
    IF (@@ROWCOUNT>0)
		BEGIN 
		Select '1' as success , 'Successfully added' as response_message
		END 
	ELSE
	BEGIN 
		Select '0' as success , 'Failed to add' as response_message
		END 
		
END