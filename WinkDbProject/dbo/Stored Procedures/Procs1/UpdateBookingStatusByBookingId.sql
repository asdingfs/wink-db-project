CREATE PROCEDURE [dbo].[UpdateBookingStatusByBookingId]
	(@booking_id varchar(500),
	 @booked_status varchar(10))
	
AS
BEGIN
Declare @ast_id int
    DECLARE @current_date datetime
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

	Update asset_management_booking set booked_status = @booked_status
	Where booking_id = @booking_id
	
	
	
	
	If(@@ROWCOUNT>0)
	BEGIN
		select @ast_id=ast.asset_type_management_id from asset_management_booking as ast Where booking_id = @booking_id 
		if exists (select 1 from asset_type_management where asset_type_management.special_campaign ='Yes' and asset_type_management.asset_type_management_id = @ast_id)
		Begin 
		Update asset_type_management set scan_start_date ='', scan_end_date =''
		where asset_type_management_id = @ast_id and special_campaign ='Yes'
		END
		select '1' as response_code , 'Successfully saved' as response_message
	END
	
	ELSE
	BEGIN
	select '0' as response_code , 'Fail to save' as response_message
	END
		

END
