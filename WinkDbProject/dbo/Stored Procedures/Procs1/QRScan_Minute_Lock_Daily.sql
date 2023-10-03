CREATE PROCEDURE [dbo].[QRScan_Minute_Lock_Daily]
	
AS
BEGIN
	DECLARE @CURRENT_DATETIME Datetime, @yesterday_date DATETIME     
	DECLARE @locked_reason varchar(255)
	DECLARE @admin_user_email_for_lock_account  varchar(255) 

	
	SET @admin_user_email_for_lock_account = 'system@winkwink.sg'
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT;
	set @yesterday_date = dateadd(d, -1, @CURRENT_DATETIME)

	DECLARE Customer_Cursor CURSOR FOR 
	   select a.earned_points_id, a.customer_id, a.qr_code, a.last_scanned_time from customer_earned_points as a, asset_type_management as b,
	   customer as c
	where b.qr_code_value like a.qr_code 
	and c.customer_id = a.customer_id
	AND c.status = 'enable'
	and b.special_campaign like 'No'
	and b.asset_status like '1'
	AND a.qr_code not like 'Train%' 
	AND a.qr_code not like '%VendingMachine%'
	AND CAST(a.created_at as DATE) = CAST(@yesterday_date as DATE)

	 order by a.customer_id, a.created_at

	 DECLARE @prev_earned_points_id INT, @prev_qr_code VARCHAR(200), @prev_customer_id INT, @prev_last_Scanned_time DATETIME
	 DECLARE @earned_points_id INT, @qr_code VARCHAR(200), @customer_id INT, @last_Scanned_time DATETIME
	 DECLARE @is_lock BIT
	 
	 set @is_lock = 0
	 
	OPEN Customer_Cursor 

	FETCH NEXT FROM Customer_Cursor INTO
		@prev_earned_points_id,  @prev_customer_id, @prev_qr_code, @prev_last_Scanned_time

	--print(@earned_points_id + ' ' + @customer_id + ' ' + @last_Scanned_time)
		
	WHILE @@FETCH_STATUS = 0
	BEGIN

		--print(CAST(@earned_points_id AS VARCHAR)  + ',' + CAST(@customer_id AS VARCHAR) + ',' + CONVERT(VARCHAR(24),@last_Scanned_time,0))



		--RAISERROR(@MessageOutput,0,1) WITH NOWAIT

		FETCH NEXT FROM Customer_Cursor INTO
		 @earned_points_id,  @customer_id, @qr_code, @last_Scanned_time
		 
		 if ( @customer_id != @prev_customer_id)
			set @is_lock = 0

		 
		 if ( @is_lock = 0 and @customer_id = @prev_customer_id and  LEFT(@prev_qr_code,3) != LEFT(@qr_code, 3)   )
		 BEGIN
			IF(DATEDIFF(second,@prev_last_Scanned_time, @last_Scanned_time) < 30)
				BEGIN
					set @is_lock = 1
					--minute lock
					print('lock..' + CAST(@earned_points_id AS VARCHAR)  + ',' + CAST(@customer_id AS VARCHAR) + ',' + CONVERT(VARCHAR(20),@last_Scanned_time,0))
					
					--print('shorter than 30s');
					
					Update customer set customer.status = 'disable',
					customer.updated_at = @CURRENT_DATETIME where customer.customer_id = @customer_id;

					IF (@@ROWCOUNT>0)
					BEGIN
						Set @locked_reason = 'Minute Lock ('+@qr_code+')';

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
		 set @prev_earned_points_id = @earned_points_id
		 set @prev_customer_id = @customer_id
		 set @prev_last_Scanned_time = @last_Scanned_time
		 set @prev_qr_code = @qr_code


	END
	CLOSE Customer_Cursor
	DEALLOCATE Customer_Cursor
END