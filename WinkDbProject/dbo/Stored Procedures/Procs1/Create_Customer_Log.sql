CREATE PROCEDURE [dbo].[Create_Customer_Log]
	(@customer_id int,
	 @ip_address varchar(20),
	 @customer_action varchar(50),
	 @token_id varchar(100)
	 )
AS
BEGIN
	SET NOCOUNT ON
    Declare @current_datetime datetime
    Declare @email varchar(100)

	DECLARE @locked_reason varchar(255)
	DECLARE @admin_user_email_for_lock_account  varchar(255) 

	
	SET @admin_user_email_for_lock_account = 'system@winkwink.sg';


    
    IF (@token_id !='' and @token_id IS NOT NULL)
    BEGIN
     Set @email = (Select customer.email from customer where customer.auth_token =@token_id)
     Set @customer_id = (Select customer.customer_id from customer where customer.auth_token =@token_id)
    END
    ELSE IF(@customer_id !=0 and @customer_id !='' and @customer_id IS NOT NULL)
    BEGIN
    Set @email = (Select customer.email from customer where customer.customer_id =@customer_id)
    
    END
    
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime Output
	Insert into customer_action_log (customer_id, email ,ip_address, customer_action,token_id,created_at)
	Values (@customer_id,@email,@ip_address,@customer_action,@token_id,@current_datetime)
	
	IF EXISTS (select 1 from customer where customer.customer_id = @customer_id and status='enable')
	BEGIN
	update customer set customer.ip_address = @ip_address where customer_id =@customer_id
	END
	
	declare @total int 
	declare @from_time datetime
	declare @to_time datetime

	set @total = (select count(*) from customer_action_log where ip_address =@ip_address
	and customer_action ='register'
	and cast (created_at as date) = cast(@current_datetime as date) group by ip_address)
	IF (@total>=5)
	BEGIN

		DECLARE @timeDifference int;
		SELECT @timeDifference = DATEDIFF(MINUTE, CAST(lastRecordMinus4.created_at AS datetime), CAST(lastRecord.created_at AS datetime))
		FROM (
			SELECT created_at
			FROM customer_action_log
			where ip_address = @ip_address
			and customer_action ='register'
			and cast (created_at as date) = cast(@current_datetime as date)
			ORDER BY created_at ASC
			OFFSET (@total-5) ROWS FETCH NEXT 1 ROWS ONLY
		) AS lastRecordMinus4
		CROSS JOIN (
			SELECT created_at
			FROM customer_action_log
			where ip_address = @ip_address
			and customer_action ='register'
			and cast (created_at as date) = cast(@current_datetime as date)
			ORDER BY created_at ASC
			OFFSET (@total-1) ROWS FETCH NEXT 1 ROWS ONLY
		) AS lastRecord;

		if(@timeDifference<=5)
		BEGIN

					update customer set status ='disable' where customer_id in (
					select customer_id from customer_action_log 
					where ip_address =@ip_address
					and customer_action ='register'
					and cast (created_at as date) = cast(@current_datetime as date));

					Insert into System_Log (customer_id, action_status,created_at,reason)
					select customer_id ,'disable',@CURRENT_DATETIME,'Multi Reg' from customer_action_log 
					where ip_address =@ip_address
					and customer_action ='register'
					and cast (created_at as date) = cast(@current_datetime as date);

						 -----INSERT INTO ACCOUNT FILTERING LOCK

					Declare @customerID int

					 DECLARE CustomerID_Cursor CURSOR FOR  
					 select customer_id from customer_action_log 
					 where ip_address =@ip_address
					 and customer_action ='register'
					 and cast (created_at as date) = cast(@current_datetime as date);

					 OPEN CustomerID_Cursor;

					 FETCH NEXT FROM CustomerID_Cursor INTO @customerID;  
					WHILE @@FETCH_STATUS = 0  
					BEGIN  
						
						set @locked_reason ='Multi Reg-'+@ip_address;
						
						EXEC Create_WINK_Account_Filtering @customerID,@locked_reason,@admin_user_email_for_lock_account

						FETCH NEXT FROM CustomerID_Cursor into @customerID;
					END

					CLOSE CustomerID_Cursor;  
					DEALLOCATE CustomerID_Cursor;

		END
	END

END



