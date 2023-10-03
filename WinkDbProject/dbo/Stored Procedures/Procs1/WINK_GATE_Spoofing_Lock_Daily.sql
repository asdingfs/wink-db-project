CREATE PROCEDURE [dbo].[WINK_GATE_Spoofing_Lock_Daily]
	
AS
BEGIN
	DECLARE @CURRENT_DATETIME Datetime, @yesterday_date DATETIME     
	DECLARE @locked_reason varchar(255)
	DECLARE @admin_user_email_for_lock_account  varchar(255) 
	
	SET @admin_user_email_for_lock_account = 'system@winkwink.sg'
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT;

	set @yesterday_date = dateadd(d, -1, @CURRENT_DATETIME)

	DECLARE GATE_Cursor CURSOR FOR 
	
	SELECT e.customer_id, e.assetId, e.created_at 
	FROM wink_gate_points_earned as e, wink_gate_asset as a,
	wink_gate_booking as b

	WHERE CAST(e.created_at as DATE) = CAST(@yesterday_date as DATE)
	AND e.assetId = a.[id]
	AND a.gate_id not like 'ERP%'
	AND e.bookingId = b.id
	AND b.wink_gate_campaign_id !=39

	ORDER BY e.customer_id, e.created_at

	DECLARE @prev_asset_id int, @prev_customer_id int, @prev_hit_time DATETIME
	DECLARE @asset_id int, @customer_id int, @hit_time DATETIME
	DECLARE @is_lock BIT
	 
	set @is_lock = 0
	 
	OPEN GATE_Cursor 

	FETCH NEXT FROM GATE_Cursor INTO
	@prev_customer_id, @prev_asset_id, @prev_hit_time

	WHILE @@FETCH_STATUS = 0
	BEGIN
		FETCH NEXT FROM GATE_Cursor INTO
		@customer_id, @asset_id,  @hit_time
		 
		 if ( @customer_id != @prev_customer_id)
			set @is_lock = 0

		 
		 if ( @is_lock = 0 and @customer_id = @prev_customer_id and  @prev_asset_id != @asset_id)
		 BEGIN
			IF(DATEDIFF(second,@prev_hit_time, @hit_time) <= 10)
				BEGIN
					set @is_lock = 1
					
					Update customer set customer.status = 'disable',
					customer.updated_at = @CURRENT_DATETIME where customer.customer_id = @customer_id;

					IF (@@ROWCOUNT>0)
					BEGIN
						Set @locked_reason = 'GPS Spoofing.';

						Insert into System_Log (customer_id, action_status,created_at,reason)
						Select customer.customer_id,
						'disable',@CURRENT_DATETIME,@locked_reason
							from customer where customer.customer_id = @customer_id

						-----INSERT INTO ACCOUNT FILTERING LOCK
						EXEC Create_WINK_Account_Filtering @customer_id,@locked_reason,@admin_user_email_for_lock_account;
					END
					
				END
		 END
		 
		 --store prev_customer_id
		 set @prev_asset_id = @asset_id
		 set @prev_customer_id = @customer_id
		 set @prev_hit_time = @hit_time

	END
	CLOSE GATE_Cursor
	DEALLOCATE GATE_Cursor
END