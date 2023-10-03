CREATE PROCEDURE [dbo].[Invalidate_Online_Orders]
	(
		@order_num varchar(250)
	 )
	
AS
BEGIN

	IF((SELECT exception FROM wink_delights_online where order_number like @order_num) is null)
	BEGIN
		UPDATE wink_delights_online
		set exception = 'Yes'
		where order_number like @order_num;

		IF @@ROWCOUNT > 0
		BEGIN
			declare @custoemrId int
			declare @locked_reason varchar(10);
			set @locked_reason = 'WDO';
			DECLARE @CURRENT_DATETIME DATETIME
			EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUT
			DECLARE @admin_user_email_for_lock_account  varchar(255) 

			SET @admin_user_email_for_lock_account = 'system@winkwink.sg';
			SET @custoemrId = (SELECT cus_id from wink_delights_online where order_number like @order_num);

			Update customer 
			set customer.status = 'disable', customer.updated_at = @CURRENT_DATETIME 
			where customer.customer_id = @custoemrId;

			IF (@@ROWCOUNT>0)
			BEGIN
				Insert into System_Log
					([customer_id]
					,[action_status]
					,[created_at]
					,[reason])
				VALUES
					(@custoemrId
					,'disable'
					,@CURRENT_DATETIME
					,@locked_reason)

	 
	 			-----INSERT INTO ACCOUNT FILTERING LOCK
				EXEC Create_WINK_Account_Filtering @custoemrId,@locked_reason,@admin_user_email_for_lock_account
				SELECT '3' as response_code, 'Your account is locked. Please contact customer service.' as response_message 

				RETURN

			END
		END
	END
	
END
