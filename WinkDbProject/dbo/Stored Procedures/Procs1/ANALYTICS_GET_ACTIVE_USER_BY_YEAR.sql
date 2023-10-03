

CREATE PROC [dbo].[ANALYTICS_GET_ACTIVE_USER_BY_YEAR]

@from_date datetime,
@to_date datetime,
@monthadd int

AS

BEGIN
	/******Nang Modify**************/

	select 
period,count(distinct c.customer_id) as total_customer,count(distinct l.customer_id) as Month0
 from 
	(
	select distinct customer_id,LEFT(CONVERT(VARCHAR(10), created_at, 126), 7) as period
	from customer where cast(created_at as date) >= cast(@from_date as date)
	and cast(created_at as date) <= cast(@to_date as date) 

	)
	as c
	left join
	customer_action_log_summary as l
	on c.customer_id = l.customer_id
	and LEFT(CONVERT(VARCHAR(10), l.customer_action_date, 126), 7) =
	LEFT(CONVERT(VARCHAR(10), DATEADD(MONTH,@monthadd,CAST(c.period+'-'+'01' AS DATE)), 126), 7) 
	group by  period
	order by period desc
	/*
	select T1.period,T1.total_customer,

	(
		select count(distinct customer_id) as total from customer_action_log_summary 
		where cast(customer_action_date as date)>=cast(@from_date as date)
		and LEFT(CONVERT(VARCHAR(10), customer_action_date, 126), 7) = LEFT(CONVERT(VARCHAR(10), DATEADD(MONTH,@monthadd,CAST(T1.period+'-'+'01' AS DATE)), 126), 7) 
		and (cast(customer_action_date as date) < cast(dateadd(hour,8,GETDATE()) as date))
		and customer_id in (select customer_id from customer where LEFT(CONVERT(VARCHAR(10), created_at, 126), 7) = T1.period and cast(created_at as date) >= cast(@from_date as date) and cast(created_at as date) <= cast(@to_date as date))	
	) As Month0

	from
	(
	select count(*) as total_customer,LEFT(CONVERT(VARCHAR(10), created_at, 126), 7) as period
	from customer where cast(created_at as date) >= cast(@from_date as date)
	and cast(created_at as date) <= cast(@to_date as date) group by LEFT(CONVERT(VARCHAR(10), created_at, 126), 7)
	) as T1 order by period desc
	*/

	/*select T1.period,T1.total_customer,

	(
		select count(distinct customer_id) as total from customer_action_log_summary 
		where LEFT(CONVERT(VARCHAR(10), customer_action_date, 126), 7) = LEFT(CONVERT(VARCHAR(10), DATEADD(MONTH,@monthadd,CAST(T1.period+'-'+'01' AS DATE)), 126), 7) 
		and customer_id in (select customer_id from customer where LEFT(CONVERT(VARCHAR(10), created_at, 126), 7) = T1.period and cast(created_at as date) >= cast(@from_date as date) and cast(created_at as date) <= cast(@to_date as date))	
	) As Month0

	from
	(
	select count(*) as total_customer,LEFT(CONVERT(VARCHAR(10), created_at, 126), 7) as period
	from customer where cast(created_at as date) >= cast(@from_date as date)
	and cast(created_at as date) <= cast(@to_date as date) group by LEFT(CONVERT(VARCHAR(10), created_at, 126), 7)
	) as T1 order by period desc*/

	

END
