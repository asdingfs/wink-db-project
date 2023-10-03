
CREATE Procedure [dbo].[LockIP32] 
(
	@ip varchar(50),
	@index int,
	@adminEmail varchar(100)
)
As
Begin
   IF(@adminEmail is null)
	BEGIN
		SELECT '0' as response_code;
		RETURN
	END

	Declare @current_datetime datetime
	Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

	DECLARE IP_Cursor CURSOR FOR 
	select ip_traped
	from [winkwink].[dbo].[mousetrap] 
	where ip_traped like (@ip)
	AND [status] like '';

	DECLARE @ip_address varchar(100);

	OPEN IP_Cursor 
	FETCH NEXT FROM IP_Cursor INTO @ip_address
	WHILE @@FETCH_STATUS = 0
	BEGIN
		print(@ip_address)
		IF NOT EXISTS(SELECT * FROM wink_customer_block_ip WHERE ip_address like @ip_address)
		BEGIN
			INSERT INTO wink_customer_block_ip
					([ip_address]
					,[created_at]
					,[updated_at])
				VALUES
					(@ip_address
					,@current_datetime
					,@current_datetime);

			UPDATE [winkwink].[dbo].[mousetrap]
			SET [status] = 'locked' 
			WHERE ip_traped like @ip_address
			AND [status] not like 'locked';

		END

		FETCH NEXT FROM IP_Cursor INTO @ip_address
	END
	CLOSE IP_Cursor
	DEALLOCATE IP_Cursor

	Declare @result int
	EXEC Create_Lock_IP_Log
	@adminEmail, @ip, @index, 'Mousetrap Locking','IP(/32)', @result output ;
	--print (@result)
	if(@result=2)
	BEGIN
		SELECT '0' as response_code;
		RETURN
	END
	ELSE
	BEGIN
		SELECT '1' as response_code;
		RETURN
	END
End
