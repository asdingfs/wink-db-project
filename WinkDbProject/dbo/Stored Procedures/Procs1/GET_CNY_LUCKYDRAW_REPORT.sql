
CREATE PROC [dbo].[GET_CNY_LUCKYDRAW_REPORT]
(
  @winner varchar(10)
)
AS

BEGIN
	IF(@winner is null OR @winner ='')
	BEGIN
	SELECT ROW_NUMBER()OVER (Order by a.created_at) AS [no], c.WID as wid, c.customer_id,c.first_name +' '+c.last_name as customer_name,c.email,a.qr_code,a.points as total_points, a.created_at,h.prize
		from customer_earned_points as a 
		inner join customer as c on a.customer_id = c.customer_id
		left join hof_luckydraw AS h ON h.CUSTOMER_ID = a.customer_id and a.created_at = h.created_at
		where a.qr_code like 'singtel%'
		order by ROW_NUMBER() OVER (Order by a.created_at) desc
	END
	ELSE IF(@winner ='yes')
	BEGIN
		SELECT ROW_NUMBER() OVER (Order by a.created_at) AS [no], 
		c.WID as wid, c.customer_id,c.first_name +' '+c.last_name as customer_name,c.email,a.qr_code,a.points as total_points, a.created_at,h.prize
		from customer_earned_points as a 
		inner join customer as c on a.customer_id = c.customer_id
		join hof_luckydraw AS h ON h.CUSTOMER_ID = a.customer_id and a.created_at = h.created_at
		where a.qr_code like 'singtel%'
		order by ROW_NUMBER() OVER (Order by a.created_at)
	END
	ELSE IF(@winner ='no')
	BEGIN
		SELECT ROW_NUMBER() OVER (Order by a.created_at) AS [no], 
		c.WID as wid, c.customer_id,c.first_name +' '+c.last_name as customer_name,c.email,a.qr_code,a.points as total_points, a.created_at,'' as prize
		from customer_earned_points as a 
		inner join customer as c on a.customer_id = c.customer_id
		and a.qr_code like 'singtel%'
		left join hof_luckydraw AS h ON h.CUSTOMER_ID = a.customer_id and a.created_at = h.created_at
		where a.qr_code like 'singtel%'
		and h.prize is null
		order by ROW_NUMBER()OVER (Order by a.created_at)
	END
END

