
CREATE PROCEDURE [dbo].[Mismatch_PhoneNo_And_Return_MultipleAccount_ID]
	 (@customer_id int,
	  @filtering_id int,
	  @whatsapp_phone_no varchar(20)
	  )
AS
BEGIN
DECLARE @multiple_account_id int 
DECLARE @return_value varchar(50)
	SET @return_value ='Error'
	IF EXISTS (select 1 from wink_account_filtering as f , customer as c where id = @filtering_id 
	and c.customer_id = @customer_id
	and c.status ='disable'
	)
	BEGIN

	----CHECK WHATSAPP USED BY OTHER ACCOUNT ?

	SELECT @multiple_account_id =customer_id FROM CUSTOMER WHERE CUSTOMER.phone_no = @whatsapp_phone_no

		IF(@multiple_account_id >0 and @multiple_account_id !=@customer_id)
			BEGIN

				set @return_value= @multiple_account_id
			END
		ELSE 
			BEGIN
				set @return_value= 'NA'

			END 
		

	

	END

	ELSE 
		BEGIN

			set @return_value= 'Unlocked'

		END

		select @return_value


END




