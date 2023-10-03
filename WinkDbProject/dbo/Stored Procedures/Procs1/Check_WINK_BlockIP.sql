
CREATE Procedure [dbo].[Check_WINK_BlockIP] 
(
@ip_address varchar(50)
)
As
Begin
    
Declare @current_datetime datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

IF EXISTS (select * from wink_customer_block_ip where ip_address = @ip_address)
BEGIN

SELECT '1' AS response_code, 'Success' as response_message
		return

END

ELSE

BEGIN

SELECT '0' AS response_code, 'Fail' as response_message
		return

END


End
