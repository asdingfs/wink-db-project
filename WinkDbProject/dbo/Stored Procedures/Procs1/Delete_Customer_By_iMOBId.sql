CREATE PROCEDURE [dbo].[Delete_Customer_By_iMOBId]
(

 @imob_customer_id int

)
AS
BEGIN
	IF EXISTS (Select * from customer where customer.imob_customer_id =@imob_customer_id)
		BEGIN
		Delete from customer where customer.imob_customer_id = @imob_customer_id
		IF(@@ROWCOUNT>0)
		Select '1' AS success ,'Successfully Delete' as response_message
		ELSE 
		select '2' As success , 'Fail to delete' as response_message
		
		END
	ELSE
		BEGIN
		
		Select '0' AS 'success' ,'Customer does not exists' as response_message
		
		END


END