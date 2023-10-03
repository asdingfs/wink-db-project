
CREATE PROCEDURE Update_Customer_iMOBID_ServerMigration
	(
	   @customer_id int,
	   @imob_customer_id int,
	   @email varchar(100)
	
	)
AS
BEGIN
	IF EXISTS (select * from customer where customer.customer_id = @customer_id
	and customer.imob_customer_id != @imob_customer_id and @email = customer.email)
	BEGIN
	
	update customer set customer.imob_customer_id = @imob_customer_id 
	where customer.customer_id = @customer_id
	and customer.imob_customer_id != @imob_customer_id and @email = customer.email
    IF (@@ROWCOUNT>0)
    select '1' as success
	
	END
	ELSE
	BEGIN
	select '0' as success
	END
END
