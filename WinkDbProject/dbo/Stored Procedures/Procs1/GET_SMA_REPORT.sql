CREATE PROC [dbo].[GET_SMA_REPORT]
(
	@customer_id int,
	@customer_name varchar(200),
	@email varchar(200),
	@qr_code varchar(100)
)
AS

BEGIN

	IF(@customer_name is null or @customer_name ='')
		SET @customer_name = NULL

	IF(@email is null or @email ='')
		SET @email = NULL

	IF(@qr_code is null or @qr_code ='')
	SET @qr_code = NULL

	IF(@customer_id = 0)
		SET @customer_id = NULL

	select * from
	(
		select a.qr_code as qr_code,a.created_at as created_at,a.points as points,c.customer_id as customer_id,c.first_name +' '+c.last_name as name ,c.email as email 
		from customer_earned_points as a,customer as c 
		where a.customer_id = c.customer_id and qr_code = 'SMA_SMA_21_49653' and year(a.created_at) = '2017'
	) AS temp
	where (@customer_id is null or temp.customer_id = @customer_id)
	and (@email is null or temp.email like '%'+@email+'%')	
	and (@customer_name is null or temp.name like '%'+@customer_name+'%') 
	and (@qr_code is null or temp.qr_code like '%'+@qr_code+'%')	
	order by created_at desc

END



