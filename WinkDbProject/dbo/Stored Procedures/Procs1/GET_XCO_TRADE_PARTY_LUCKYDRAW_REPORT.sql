
CREATE PROC [dbo].[GET_XCO_TRADE_PARTY_LUCKYDRAW_REPORT]
(
	@wid varchar(50),
	@lucky_draw varchar(200),
	@customer_name varchar(200),
	@email varchar(200),
	@customer_id int,
	@qr_code varchar(150)
)
AS

BEGIN

	if(@lucky_draw is null or @lucky_draw ='')
		set @lucky_draw =Null

	if(@customer_name is null or @customer_name ='')
		set @customer_name = Null

	if(@email is null or @email ='')
		set @email = Null

	if(@customer_id is null or  @customer_id =''  or @customer_id =0)
		set @customer_id = Null

	IF(@wid is null or @wid ='')
		SET @wid = NULL

	if(@qr_code is null or  @qr_code ='')
		set @qr_code = Null




	SELECT ROW_NUMBER() OVER (Order by a.created_at desc) AS [no], c.WID as wid, c.customer_id,c.first_name +' '+c.last_name as customer_name,c.email,
	a.points as total_points, a.qr_code,a.created_at as created_at,h.prize,a.GPS_location
	from customer_earned_points as a 
	inner join customer as c on a.customer_id = c.customer_id
	left join hof_luckydraw AS h ON h.qr_code = a.qr_code and c.customer_id = h.customer_id 
	where a.qr_code like 'XCOTradeParty%' 
	and (@lucky_draw is null or h.prize like '%'+@lucky_draw+'%')
	and (@customer_name is null or Concat(c.first_name,' ',c.last_name) like '%'+@customer_name+'%')
	and (@email is null or c.email like '%'+@email+'%')
	AND (@wid is null or c.wid like '%'+@wid+'%')
	and (@customer_id is null or c.customer_id = @customer_id)
	and (@qr_code is null or a.qr_code like '%'+@qr_code+'%')
	
	group by c.wid, c.customer_id,c.first_name +' '+c.last_name,c.email,a.created_at,h.prize,a.points,a.qr_code,a.GPS_location
	order by ROW_NUMBER() OVER (Order by a.created_at desc) 

END

