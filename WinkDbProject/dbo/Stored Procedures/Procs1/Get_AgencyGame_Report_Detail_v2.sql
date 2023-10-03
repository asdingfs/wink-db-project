
CREATE PROC [dbo].[Get_AgencyGame_Report_Detail_v2]
(
  
  @agency_name varchar(10),
  @customer_id int,
  @email varchar(50),
  @customer_name varchar(100),
  @phone_no varchar(10),
  @from_date varchar(20),
  @to_date varchar(20),
  @status varchar(10),
  @team_name varchar(10),
  @agency_id varchar(10),
  @lukydraw_status varchar(5)
  )

AS

BEGIN
Declare @start_date datetime
Declare @end_date datetime




set @start_date = @from_date
set @end_date = @to_date

if(@start_date is null or @start_date ='')
begin
set @start_date ='2017-07-24'

end

if(@end_date is null or @end_date ='')
begin
set @end_date ='2017-08-25'

end

if(@customer_id is null or  @customer_id ='')
Begin
set @customer_id = NULL
end

if(@phone_no is null and @phone_no ='')
Begin
set @phone_no = NULL
end

if(@team_name is null and @team_name ='')
BEGIN

set @team_name = NULL

END

if(@status is null or @status ='')
BEGIN
set @status = NULL;
END

if(@agency_id is null or @agency_id ='')
BEGIN
set @agency_id = NULL;
END

if(@lukydraw_status is null or @lukydraw_status ='')
BEGIN
set @lukydraw_status = NULL;
END



IF (@start_date is not null and @start_date !='' and @end_date is not null and @end_date !='')
BEGIN

IF (@lukydraw_status is null or @lukydraw_status ='Yes')
BEGIN
print ('filter date')
select A.group_id,G.agency_name,p.customer_id,c.phone_no,G.team_name as team,
G.agency_code,G.group_size,h.prize,ISNULL(pak.package_points,0) as package_points,
(c.first_name +' '+c.last_name) as cust_name,c.email,p.created_at,p.ip_address,
p.GPS_location,c.status,p.qr_code,
p.points as total_points -- for points
 from agency_game_customers as A
join customer as C
--on C.phone_no = A.phone_no
on c.customer_id = A.customer_id
join agency_game as G
on G.id = A.group_id
Join customer_earned_points as P
on p.customer_id = C.customer_id
--and (Cast(p.created_at as date) >= Cast(@current_date as date) 
and (Cast(p.created_at as date) >= Cast(@start_date as date)
and Cast(p.created_at as date) <= Cast(@end_date as date)
)
left join hof_luckydraw AS h ON h.qr_code = p.qr_code and c.customer_id = h.customer_id 
and h.qr_code like 'agency%' 

and (Cast(p.created_at as date) =Cast(h.created_at as date))
left join agency_package_points as pak
on pak.agency_id = g.id
where 
(@customer_id is null or c.customer_id = @customer_id)
 and (@phone_no is null or a.phone_no like @phone_no+'%')
  and (c.first_name like '%'+@customer_name + '%' or 
   c.last_name like '%'+@customer_name + '%')
  and g.agency_name like '%'+@agency_name +'%'
  --and c.status like '%'+@status+'%'
  and g.team_name like '%' + @team_name +'%'
  and c.email like '%' + @email +'%'
  and (@status is null or c.status like '%'+@status+'%')
  and (@agency_id is null or g.id = @agency_id)
  and (@lukydraw_status is null or h.prize like +'%a surprise%')
 
  
order by p.created_at desc

END

ELSE IF (@lukydraw_status = 'No')
BEGIN
select A.group_id,G.agency_name,p.customer_id,c.phone_no,G.team_name as team,
G.agency_code,G.group_size,h.prize,ISNULL(pak.package_points,0) as package_points,
(c.first_name +' '+c.last_name) as cust_name,c.email,p.created_at,p.ip_address,
p.GPS_location,c.status,p.qr_code,
p.points as total_points -- for points
 from agency_game_customers as A
join customer as C
--on C.phone_no = A.phone_no
on c.customer_id = A.customer_id
join agency_game as G
on G.id = A.group_id
Join customer_earned_points as P
on p.customer_id = C.customer_id
--and (Cast(p.created_at as date) >= Cast(@current_date as date) 
and (Cast(p.created_at as date) >= Cast(@start_date as date)
and Cast(p.created_at as date) <= Cast(@end_date as date)
)
left join hof_luckydraw AS h ON h.qr_code = p.qr_code and c.customer_id = h.customer_id 
and h.qr_code like 'agency%' 

and (Cast(p.created_at as date) =Cast(h.created_at as date))
left join agency_package_points as pak
on pak.agency_id = g.id
where 
(@customer_id is null or c.customer_id = @customer_id)
 and (@phone_no is null or a.phone_no like @phone_no+'%')
  and (c.first_name like '%'+@customer_name + '%' or 
   c.last_name like '%'+@customer_name + '%')
  and g.agency_name like '%'+@agency_name +'%'
  --and c.status like '%'+@status+'%'
  and g.team_name like '%' + @team_name +'%'
  and c.email like '%' + @email +'%'
  and (@status is null or c.status like '%'+@status+'%')
  and (@agency_id is null or g.id = @agency_id)
  and (h.prize is null or h.prize ='')
 
  
order by p.created_at desc

END


END



END


