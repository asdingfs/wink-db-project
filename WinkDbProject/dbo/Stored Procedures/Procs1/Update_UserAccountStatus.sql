
CREATE PROCEDURE [dbo].[Update_UserAccountStatus]
	(
	@customer_id int,
	@status varchar(10)
		
	)
AS
BEGIN


	Update customer set status = @status where customer.customer_id = @customer_id
	IF @@ROWCOUNT >0 
		BEGIN
	IF EXISTS (SELECT * FROM can_id where can_id.customer_id = @customer_id)
	BEGIN
	Update can_id set status = @status where can_id.customer_id = @customer_id 
		IF @@ROWCOUNT>0
		BEGIN
		Select '1' as success , 'Successfully disable user account' as response_message
		RETURN
		END
		ELSE
		BEGIN
		Select '0' as success , 'Fail to disable CAN ID' as response_message
		RETURN
		END
	
	END
	
		END
	ELSE
		BEGIN
	Select '0' as success , 'Fail to disable user account' as response_message
	RETURN
		END
		
	
END
