CREATE Procedure [dbo].[Customer_AutoLock_Action]
(@customer_id int,
 @customer_tokenid varchar(150),
 @action_name varchar(30)
 )
 AS
 BEGIN

 DECLARE @CURRENT_DATETIME Datetime
 Exec GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT
 
				Update customer set customer.status = 'disable',
				customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid
				IF (@@ROWCOUNT>0)
				BEGIN
					Insert into System_Log (customer_id, action_status,created_at,reason)
					Select customer.customer_id,
					'disable',@CURRENT_DATETIME,@action_name
					 from customer where customer.auth_token = @customer_tokenid
				END

 END