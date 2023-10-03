CREATE Procedure [dbo].[INSERT_CUSTOMER_ENQUIRY]
(
  @email varchar(200),
  @phone_no varchar(10),
  @ip varchar(20),
  @GPS_location varchar(200),
  @app_version varchar(50)
)
AS
BEGIN
	declare @prev_date as datetime
	Declare @current_date datetime
	Declare @customerID int
	Declare @currentCID int = 0
	Declare @currentReason varchar(4000)
	Declare @currentAFMID int
	Declare @AFMID int
	Declare @reason varchar(4000)
	Declare @admin_user_email_for_lock_account  varchar(255) 
	DECLARE @CurUserIsLocked int = 0;

	SET @admin_user_email_for_lock_account = 'system@winkwink.sg'
	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	IF(@app_version is null or @app_version = '')
	BEGIN
		SET @app_version = null;
	END

	DECLARE CustomerID_Cursor CURSOR FOR  
	select distinct c.customer_id from customer as c, customer_enquiry as e where 
	e.ip_address = @ip
	and e.email not like @email
	and e.email like c.email
	and (DATEDIFF(MINUTE,e.created_at, @current_date) < 30);

	
	INSERT INTO customer_enquiry 
			([phone_no]
           ,[email]
           ,[ip_address]
           ,[GPS_location]
		   ,[app_version]
           ,[created_at])
     VALUES
           (@phone_no
           ,@email
           ,@ip
           ,@GPS_location
		   ,@app_version
           ,@current_date);


			
	--lock other accounts that used the same IP address for enquiry
	OPEN CustomerID_Cursor;

	FETCH NEXT FROM CustomerID_Cursor INTO @customerID;  
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		IF EXISTS (select 1 from customer where customer_id = @customerID AND [status] like 'disable')
		BEGIN
			SELECT TOP(1) @AFMID = id, @reason = reason from wink_account_filtering where customer_id = @customerID order by created_at desc;
			
			UPDATE wink_account_filtering
			SET reason = @reason + ' Enquiry IP-'+@ip+'.'
			where id = @AFMID;

		END
		ELSE
		BEGIN
			UPDATE customer
			SET [status] = 'disable', updated_at = @current_date 
			WHERE customer_id = @customerID

			IF (@@ROWCOUNT>0)
			BEGIN
				Set @reason = 'Enquiry IP-' + @ip+'.';

				Insert into System_Log (customer_id, action_status,created_at,reason)
				EXEC Create_WINK_Account_Filtering @customerID, @reason, @admin_user_email_for_lock_account;
			END
		END
		print(@customerID);
		IF(@CurUserIsLocked = 0)
		BEGIN
			print('Lock current user');
			SET @CurUserIsLocked = 1;
		END

		FETCH NEXT FROM CustomerID_Cursor into @customerID; 
	END;  

	CLOSE CustomerID_Cursor;  
	DEALLOCATE CustomerID_Cursor;

	IF(@CurUserIsLocked = 1)
	BEGIN
		print('current user is locked due to multiple users sent in using the same IP within 30 min');
		SELECT @currentCID = customer_id from customer where email = @email;
		IF(@currentCID is not null)
		BEGIN
			IF EXISTS (select 1 from customer where customer_id = @currentCID AND [status] like 'disable')
			BEGIN
				SELECT TOP(1) @currentAFMID = id, @currentReason = reason from wink_account_filtering where customer_id = @currentCID order by created_at desc;
			
				UPDATE wink_account_filtering
				SET reason = @currentReason + ' Enquiry IP-'+@ip+'.'
				where id = @currentAFMID;

			END
			ELSE
			BEGIN
				UPDATE customer
				SET [status] = 'disable', updated_at = @current_date 
				WHERE customer_id = @currentCID;

				IF (@@ROWCOUNT>0)
				BEGIN

					Set @currentReason = 'Enquiry IP-' + @ip+'.';

					Insert into System_Log (customer_id, action_status,created_at,reason)
					EXEC Create_WINK_Account_Filtering @currentCID, @currentReason, @admin_user_email_for_lock_account;
				END
			END
		END
	END

	IF(
		(
			SELECT COUNT(*)
			FROM customer_enquiry
			WHERE ip_address like @ip
			AND (DATEDIFF(MINUTE,created_at, @current_date) < 30)
		)
		> 10
	)
	BEGIN
		print('User(s) sent in more than 10 enquiries using the same IP within 30 min');
		IF(@CurUserIsLocked = 0)
		BEGIN
			print('current user is locked due to sending more than 10 enquiries using the same IP within 30 min');
			SET @CurUserIsLocked = 1;
			SELECT @currentCID = customer_id from customer where email = @email;
			IF(@currentCID is not null)
			BEGIN
				IF EXISTS (select 1 from customer where customer_id = @currentCID AND [status] like 'disable')
				BEGIN
					SELECT TOP(1) @currentAFMID = id, @currentReason = reason from wink_account_filtering where customer_id = @currentCID order by created_at desc;
			
					UPDATE wink_account_filtering
					SET reason = @currentReason + ' Enquiry IP-'+@ip+'.'
					where id = @currentAFMID;

				END
				ELSE
				BEGIN
					UPDATE customer
					SET [status] = 'disable', updated_at = @current_date 
					WHERE customer_id = @currentCID;

					IF (@@ROWCOUNT>0)
					BEGIN

						Set @currentReason = 'Enquiry IP-' + @ip+'.';

						Insert into System_Log (customer_id, action_status,created_at,reason)
						EXEC Create_WINK_Account_Filtering @currentCID, @currentReason, @admin_user_email_for_lock_account;
					END
				END
			END
		END

		--print('Lock other users who use this IP to send enquiries within 30 min');

		--SET @customerID = 0;
		--DECLARE SpammerCusID_Cursor CURSOR FOR  
		--select distinct c.customer_id 
		--from customer as c, customer_enquiry as e 
		--where e.ip_address = @ip
		--and e.email not like @email
		--and e.email like c.email
		--and (DATEDIFF(MINUTE,e.created_at, @current_date) < 30);

		--OPEN SpammerCusID_Cursor;

		--FETCH NEXT FROM SpammerCusID_Cursor INTO @customerID;  
		--WHILE @@FETCH_STATUS = 0  
		--BEGIN  
		--	IF EXISTS (select 1 from customer where customer_id = @customerID AND [status] like 'disable')
		--	BEGIN
		--		SELECT TOP(1) @AFMID = id, @reason = reason from wink_account_filtering where customer_id = @customerID order by created_at desc;
			
		--		UPDATE wink_account_filtering
		--		SET reason = @reason + ' Enquiry IP-'+@ip+'.'
		--		where id = @AFMID;

		--	END
		--	ELSE
		--	BEGIN
		--		UPDATE customer
		--		SET [status] = 'disable', updated_at = @current_date 
		--		WHERE customer_id = @customerID

		--		IF (@@ROWCOUNT>0)
		--		BEGIN
		--			Set @reason = 'Enquiry IP-' + @ip+'.';

		--			Insert into System_Log (customer_id, action_status,created_at,reason)
		--			EXEC Create_WINK_Account_Filtering @customerID, @reason, @admin_user_email_for_lock_account;
		--		END
		--	END
		--	print(@customerID);
		--	FETCH NEXT FROM SpammerCusID_Cursor into @customerID; 
		--END;  

		--CLOSE SpammerCusID_Cursor;  
		--DEALLOCATE SpammerCusID_Cursor;
	END
END
