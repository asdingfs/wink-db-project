CREATE Procedure [dbo].[Update_NETsCANIDRedemptionList_Sent_NETs_Server_Status]
(
 @request_date datetime
 )
AS
Begin
Declare @currentDate datetime
Declare @day int

set @day = 1

EXEC GET_CURRENT_SINGAPORT_DATETIME @currentDate output

if(@request_date is not null and @request_date !='')
BEGIN

SET @request_date = DATEADD(day, -1, @request_date)

END

-- Insert to the log file 

Declare @current_date datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

update [NETs_CANID_Redemption_Record_SendingLog] set cronjob_status ='sent', cronjob_sending_date = @currentDate
where cast (created_at as date) = cast(@currentDate as date) and cronjob_status ='pending'

IF(@@ROWCOUNT>0)
BEGIN
update NETs_CANID_Redemption_Record_Detail set cronjob_status ='sent', cronjob_sending_date = @currentDate
where cast (created_at as date) = cast(@request_date as date) and cronjob_status ='pending'
RETURN @@ROWCOUNT
END

END
