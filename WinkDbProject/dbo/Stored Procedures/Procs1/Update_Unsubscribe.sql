

CREATE PROCEDURE [dbo].[Update_Unsubscribe]
(
 @email varchar(255)
 
)
AS
BEGIN
 --DECLARE @email varchar(255)
 
 IF EXISTS (SELECT 1 FROM customer where customer.email = @email)

BEGIN
		
			
				BEGIN
				--print('aaaaa')
				update customer set customer.subscribe_status = '0' 
				Where customer.email = @email 
				END
		
		--print(@@ROWCOUNT)
		IF @@ROWCOUNT > 0
				BEGIN
			---print('dkfjkdljf')
			SELECT '1' AS response_code 
			RETURN
				END
		ELSE
				BEGIN
				--print('GGGG')
			SELECT '0' AS response_code
			RETURN
END

	
 



--Select * from admin_log




END
END

