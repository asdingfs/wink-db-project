CREATE PROCEDURE [dbo].[Check_DuplicateCustomerInfo_version2]
	(@can_id varchar(50),
	 @email varchar(150),
	 @phone_no varchar(10),
	 @ip_address varchar(50)
	
	)
AS
BEGIN

	
    IF(@phone_no is not null and @phone_no !='')
    IF EXISTS (SELECT * FROM customer where customer.phone_no = @phone_no)
	BEGIN
		SELECT '0' as success , 'Mobile number is already in use. Please key in a new mobile number.' as response_message
		RETURN
    END
     
     
    IF EXISTS (Select * from wink_customer_block_ip where ip_address= @ip_address)
    BEGIN
		SELECT '0' as success , 'Failed to register' as response_message
		Return
    END
    IF EXISTS (SELECT * FROM can_id WHERE can_id.customer_canid = @can_id)
    BEGIN
		SELECT '0' as success , 'Travel card/membership ID is already in use. Please key in a new ID.' as response_message
    END
    ELSE IF EXISTS (SELECT * FROM customer where customer.email = @email)
	BEGIN
		SELECT '0' as success , 'Email is already in use. Please key in a new email.' as response_message
    END
   
    ELSE
    BEGIN
		SELECT '1' as success , 'Valid customer' as response_message
    END
    
	
END


