
CREATE PROC [dbo].[Get_AgencyGame_Score_Report]
( @agency_name varchar(10),
  @customer_id int,
  @email varchar(50),
  @customer_name varchar(100),
  @phone_no varchar(10),
  @from_date varchar(20),
  @to_date varchar(20),
  @status varchar(10),
   @team_name varchar(10)
  )
AS

BEGIN
Declare @start_date datetime
Declare @end_date datetime

Set @start_date = @from_date
set @end_date = @to_date
if(@start_date is null or @start_date ='')
begin
set @start_date ='2017-07-24'

end

if(@end_date is null or @end_date ='')
begin
set @end_date ='2017-08-25'

end
--- By Points 
--IF (@customer_id = 0 and @customer_name ='' and @email ='' and @status ='')
BEGIN
select G.id as agency_id , G.agency_name , ISNULL(s.total,0) as total_points ,team_name as team ,G.agency_code,
G.group_size,total_registered, ISNULL(package_points,0) as package_points
from agency_game as G 
left join 
(

select sum(isnull(p.points,0)) - sum(isnull(A.total_confiscated_points,0)) as total ,G.id 
from agency_game_customers as A
join customer as C
--on C.phone_no = A.phone_no
on C.customer_id = A.customer_id
join agency_game as G
on G.id = A.group_id
--and G.team = @team_id
Join 
(select sum(points) as points,customer_id from customer_earned_points where 
(Cast(created_at as date) >= Cast(@start_date as date) and 
Cast(created_at as date) <= Cast(@end_date as date))
group by customer_id
) AS P
on p.customer_id = C.customer_id
group by G.id) AS S
on G.id = S.id
left join (select count(*) as total_registered , group_id from agency_game_customers group by group_id)
as F
on F.group_id = G.id

left join (select sum(package.package_points) as package_points,agency_id from agency_package_points as package
group by package.agency_id) as package
on package.agency_id = G.id


Where  G.agency_name like '%'+@agency_name +'%'
and G.team_name like '%' + @team_name +'%'

order by (ISNULL(s.total,0) +ISNULL(package_points,0))  desc

END



--- By Total Scans 
/*
select G.id as agency_id , G.agency_name , ISNULL(s.total,0) as total_scans from agency_game as G 
left join 
(select A.group_id,G.agency_name,Count(*)-sum(A.total_confiscated_scan) as total  from agency_game_customers as A
join customer as C
on C.phone_no = A.phone_no
join agency_game as G
on G.id = A.group_id
and G.team = @team_id
Join customer_earned_points as P
on p.customer_id = C.customer_id
and (Cast(p.created_at as date) >= Cast(@start_date as date) and 
Cast(p.created_at as date) <= Cast(@end_date as date))
group by A.group_id,G.agency_name) as s

on G.id = s.group_id
where G.team = @team_id
order by total desc
*/
/*select sum(confis.confiscated_points) as points_confis,sum(p.points) as points
from agency_game_customers as A
join customer as C
on C.phone_no = A.phone_no
join agency_game as G
on G.id = A.group_id
and G.team = @team_id
Join 
(select sum(points) as points,customer_id from customer_earned_points where 
(Cast(created_at as date) >= Cast(@start_date as date) and 
Cast(created_at as date) <= Cast(@end_date as date))
group by customer_id

) AS P
on p.customer_id = C.customer_id
left join (select sum(confiscated_points) as confiscated_points,customer_id from points_confiscated_detail where 
(Cast(created_at as date) >= Cast(@start_date as date) and 
Cast(created_at as date) <= Cast(@end_date as date))
group by customer_id
) confis
on c.customer_id = confis.customer_id
group by G.team*/

END
