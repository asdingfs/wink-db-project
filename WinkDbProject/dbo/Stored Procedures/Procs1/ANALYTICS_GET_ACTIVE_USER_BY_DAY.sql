
CREATE PROC [dbo].[ANALYTICS_GET_ACTIVE_USER_BY_DAY]

@from_date datetime,
@to_date datetime,
@dateadd int

AS

BEGIN

	/*select T1.period,T1.total_customer,

	(
		select count(*) as total from customer_action_log_summary 
		where cast(customer_action_date as date)>=cast(@from_date as date)
		and cast(customer_action_date as date) = cast((select dateadd(day,@dateadd,T1.period)) as date) 
		and (cast(customer_action_date as date) < cast(dateadd(hour,8,GETDATE()) as date))
		and customer_id in (select customer_id from customer where cast(created_at as date) = cast(T1.period as date) and cast(created_at as date) >= cast(@from_date as date)and cast(created_at as date) <= cast(@to_date as date))
	
	) As Day0

	from
	(
	select count(*) as total_customer,cast(created_at as date) as period
	from customer where cast(created_at as date) >= cast(@from_date as date)
	and cast(created_at as date) <= cast(@to_date as date) group by cast(created_at as date)
	) as T1 order by period desc*/

	select cast(period as date) as period ,count(*) as total_customer,count(l.customer_id) as day0 from 
	(
	select distinct customer_id,cast(created_at as date) as period
	from customer where cast(created_at as date) >= cast(@from_date as date)
	and cast(created_at as date) <= cast(@to_date as date) )
	as c
	left join
	customer_action_log_summary as l
	on c.customer_id = l.customer_id
	and cast(customer_action_date as date) =
	cast((select dateadd(day,@dateadd,c.period)) as date)
	group by cast(period as date)
	order by cast(period as date) desc

END
