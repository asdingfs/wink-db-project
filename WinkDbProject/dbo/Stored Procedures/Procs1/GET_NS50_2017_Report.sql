
CREATE PROC [dbo].[GET_NS50_2017_Report]
(
	@customer_name varchar(200),
	@email varchar(200),
	@wid varchar(50),
	@customer_id int
)
AS

BEGIN


	if(@customer_name is null or @customer_name ='')
		set @customer_name = Null

	if(@email is null or @email ='')
		set @email = Null

	if(@customer_id is null or  @customer_id =''  or @customer_id =0)
		set @customer_id = Null

	IF(@wid is null or @wid ='')
		SET @wid = NULL

	SELECT ROW_NUMBER() OVER (Order by a.created_at desc) AS [no], c.WID as wid, c.customer_id,c.first_name +' '+c.last_name as customer_name,c.email,
	a.points as total_points, a.qr_code,a.created_at as created_at,a.GPS_location
	from customer_earned_points as a 
	inner join customer as c on a.customer_id = c.customer_id
	where a.qr_code like 'NS50_NS50_01_49312%' 
	AND (@wid is null or c.wid like '%'+@wid+'%')
	and (@customer_name is null or Concat(c.first_name,' ',c.last_name) like '%'+@customer_name+'%')
	and (@email is null or c.email like '%'+@email+'%')
	and (@customer_id is null or c.customer_id = @customer_id)
	group by c.wid, c.customer_id,c.first_name +' '+c.last_name,c.email,a.created_at,a.points,a.qr_code,a.GPS_location
	order by ROW_NUMBER() OVER (Order by a.created_at desc) 
END