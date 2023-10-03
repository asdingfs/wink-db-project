CREATE PROC [dbo].[ANALYTICS_GET_MONTH_NEW]
@month varchar(10),--for example, 2016-02
@total_new int output

AS

BEGIN

declare @date varchar(20)= @month
declare @end_date_of_current_month date = EOMONTH(cast(@date+'-01' as date))

SET @total_new =
(
	select count(distinct customer_id) from customer 
	where LEFT(CONVERT(VARCHAR(10), created_at, 126), 7) = @date and group_id in (13,14)
)

END
