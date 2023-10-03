CREATE PROCEDURE [dbo].[CIC_Check_CANID]
	(@CANID varchar(100)
	 )
AS
BEGIN
IF EXISTS (select 1 from can_id where can_id.customer_canid = @CANID)
BEGIN
Select 1 as success , 'CAN ID is valid' as response_message
Return

END
ELSE
BEGIN
Select 0 as success , 'CAN ID not found' as response_message
Return

END
	
END


