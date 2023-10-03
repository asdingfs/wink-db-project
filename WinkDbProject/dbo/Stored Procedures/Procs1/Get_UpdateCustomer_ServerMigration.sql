
CREATE PROCEDURE Get_UpdateCustomer_ServerMigration
	
AS
BEGIN
	select * from customer where customer.updated_at > CAST ('2016-06-24 16:24:27.257' as datetime) 
    and customer.created_at < customer.updated_at
END
