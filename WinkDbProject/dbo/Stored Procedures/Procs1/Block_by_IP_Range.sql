
CREATE Procedure [dbo].[Block_by_IP_Range] 
(
	@ip_range varchar(50)
)
As
Begin
   
	Declare @current_datetime datetime
	Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output
	
	DECLARE @range varchar(50)
	IF(@ip_range like '%/16')
	BEGIN
		SET @range = SUBSTRING(@ip_range, 1,  LEN(@ip_range)-6);
	END
	ELSE IF(@ip_range like '%/24')
	BEGIN
		SET @range = SUBSTRING(@ip_range, 1,  LEN(@ip_range)-4);
	END
	ELSE IF(@ip_range like '%/8')
	BEGIN
		SET @range = SUBSTRING(@ip_range, 1,  LEN(@ip_range)-7);
	END
	ELSE
	BEGIN
		SET @range = @ip_range;
	END

	DECLARE IP_Cursor CURSOR FOR 
	select ip_traped
	from [winkwink].[dbo].[mousetrap] 
	where ip_traped like (@range+'%')
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
End
