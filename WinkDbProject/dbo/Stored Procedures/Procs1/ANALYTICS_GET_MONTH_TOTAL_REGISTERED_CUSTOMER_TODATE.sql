CREATE PROC [dbo].[ANALYTICS_GET_MONTH_TOTAL_REGISTERED_CUSTOMER_TODATE]
@month varchar(10),--for example, 2016-02
@total_registered int output

AS

BEGIN

declare @date varchar(20)= @month
declare @end_date_of_current_month date = EOMONTH(cast(@date+'-01' as date))

SET @total_registered =
(
	select count(distinct customer_id) from customer 
	where cast(created_at as date) <= @end_date_of_current_month and group_id in (13,14)
)

END
