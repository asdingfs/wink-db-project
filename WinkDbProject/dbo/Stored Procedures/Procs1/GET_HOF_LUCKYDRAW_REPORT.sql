
CREATE PROC [dbo].[GET_HOF_LUCKYDRAW_REPORT]
AS

BEGIN

	SELECT ROW_NUMBER() OVER (Order by c.customer_id) AS no, c.customer_id,c.first_name +' '+c.last_name as customer_name,c.email,sum(a.points) as total_points, convert(varchar, a.created_at, 111) as created_at,h.prize
	from customer_earned_points as a 
	inner join customer as c on a.customer_id = c.customer_id
	left join hof_luckydraw AS h ON h.customer_id = a.customer_id
	where a.qr_code like 'hof%' and cast(a.created_at as date) = cast('2016-11-23' as date)
	GROUP BY c.customer_id,c.first_name +' '+c.last_name,c.email,convert(varchar,a.created_at, 111),h.prize
	order by ROW_NUMBER() OVER (Order by c.customer_id) asc
	

	--select * from hof_luckydraw
	--select * from customer_earned_points order by created_at desc

END