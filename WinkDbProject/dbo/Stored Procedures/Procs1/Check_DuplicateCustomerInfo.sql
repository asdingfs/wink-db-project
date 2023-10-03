CREATE PROCEDURE [dbo].[Check_DuplicateCustomerInfo]
	(@can_id varchar(50),
	 @email varchar(150),
	 @phone_no varchar(10)
	
	)
AS
BEGIN
     
    IF EXISTS (SELECT * FROM can_id WHERE can_id.customer_canid = @can_id)
    BEGIN
		SELECT '0' as success , 'CAN ID is already in use.Please key in new CAN ID' as response_message
    END
    ELSE IF EXISTS (SELECT * FROM customer where customer.email = @email)
	BEGIN
		SELECT '0' as success , 'Email is already in use.Please key in new email' as response_message
    END
    ELSE IF EXISTS (SELECT * FROM customer where customer.phone_no = @phone_no)
	BEGIN
		SELECT '0' as success , 'Mobile number is already in use.Please key in new mobile number!' as response_message
    END
    ELSE
    BEGIN
		SELECT '1' as success , 'Valid customer' as response_message
    END
    
	
END


