CREATE PROC [dbo].[WINK_MouseTrap_Lock_Unlock_IP]
@mousetrap_id int,
@status int,
@admin_email varchar(50)

AS

BEGIN

	Declare @ip_address varchar(50)
	Declare @admin_user_id int
	Declare @current_datetime datetime
	Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

	set @admin_user_id = (select admin_user_id from admin_user where email = @admin_email)
	
	if @status = 1 --lock
	begin
		if exists (select * from mousetrap where mousetrap_id = @mousetrap_id)
		begin
			
			set @ip_address = (select top 1 ip_traped from mousetrap where mousetrap_id = @mousetrap_id)

			if(@ip_address is not null and @ip_address != '')
			begin
				
				if not exists(select * from wink_customer_block_ip where ip_address = @ip_address)
				begin
					INSERT INTO wink_customer_block_ip([ip_address],[created_at],[updated_at])
					VALUES
					(@ip_address,@current_datetime,@current_datetime)
				end

				update [winkwink].[dbo].[mousetrap] set status = 'Locked', updated_at = @current_datetime 
				where ip_traped = @ip_address --and (rtrim(ltrim(status)) is null or rtrim(ltrim(status)) = '' or rtrim(ltrim(status)) = 'none' or rtrim(ltrim(status)) = 'None')

				insert into mousetrap_action_log (mousetrap_id,ip_address,user_action,admin_email,admin_user_id,created_at,updated_at)
				values (@mousetrap_id,@ip_address,'Locked',@admin_email,@admin_user_id,@current_datetime,@current_datetime)

				select '1' as response_code, 'Successfully locked' as response_message
				return;

			end
			else
			begin
				select '0' as response_code, 'Record not found' as response_message
				return;
			end

		end
		else
		begin
			select '0' as response_code, 'Record not found' as response_message
			return;
		end

		return;
	end

	else if @status = 2 --unlock
	begin
		if exists (select * from mousetrap where mousetrap_id = @mousetrap_id)
		begin
			
			set @ip_address = (select top 1 ip_traped from mousetrap where mousetrap_id = @mousetrap_id)

			if(@ip_address is not null and @ip_address != '')
			begin
				
				if exists(select * from wink_customer_block_ip where ip_address = @ip_address)
					delete from wink_customer_block_ip where ip_address = @ip_address
				
				if exists(select * from mousetrap where ip_traped = @ip_address and status = 'Locked')
					update mousetrap set status = 'Unlocked',updated_at = @current_datetime where ip_traped = @ip_address and status = 'Locked'
				
				insert into mousetrap_action_log (mousetrap_id,ip_address,user_action,admin_email,admin_user_id,created_at,updated_at)
				values (@mousetrap_id,@ip_address,'Unlocked',@admin_email,@admin_user_id,@current_datetime,@current_datetime)

				select '1' as response_code, 'Successfully unlocked' as response_message
				return;

				return;

			end
			else
			begin
				select '0' as response_code, 'Record not found' as response_message
				return;
			end

		end
		else
		begin
			select '0' as response_code, 'Record not found' as response_message
			return;
		end

		return;
	end
END



