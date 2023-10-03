CREATE Procedure [dbo].[Update_NETsCANID_Sent_Status]
(
 @request_date datetime,
 @total_sent_records int
)
AS
Begin

Declare @total int
set @total =(select count(*) from NETs_Sent_CANID_List where sent_status = 0 and cast (updated_at as date ) = cast (@request_date as date) )

if(@total = @total_sent_records)
BEGIN
update NETs_Sent_CANID_List set sent_status = 1 where sent_status = 0 and cast (updated_at as date ) = cast (@request_date as date) 
END

END
