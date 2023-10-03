
CREATE PROCEDURE Get_NewCustomer_ServerMigration
	
AS
BEGIN
	select * from customer where customer.created_at > CAST ('2016-06-24 16:24:27.257' as datetime) 
and customer.created_at = customer.updated_at
and (customer.customer_password is not null or customer.customer_password !='')
END
