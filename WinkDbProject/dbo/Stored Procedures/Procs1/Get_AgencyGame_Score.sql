
CREATE PROC [dbo].[Get_AgencyGame_Score]
(
  @campaign_id int,
  @customer_id varchar(10)
  
)

AS

BEGIN
Declare @start_date datetime
Declare @end_date datetime
Declare @team_id varchar(10)
Declare @phone_no varchar(10)
Declare @agency_id int

Set @start_date = '2017-07-18'
set @end_date = '2017-12-31'
--- By customer registration id  and by points 

select @agency_id=g.id ,@team_id =g.team_id from agency_game as g, agency_game_customers as c
where g.id = c.group_id and c.customer_id =@customer_id

select * from (
select G.id as agency_id , G.agency_name , ISNULL(s.total,0) as total_scans,
rank() over (order by  ISNULL(s.total,0) desc) as ranking
 from agency_game as G 
left join 
(select sum(isnull(p.points,0)) - sum(isnull(confis.confiscated_points,0)) as total ,G.id 

from agency_game_customers as A

join customer as C

on C.phone_no = A.phone_no

join agency_game as G

on G.id = A.group_id
and G.team_id = @team_id
Join 
(select sum(points) as points,customer_id from customer_earned_points where 
(Cast(created_at as date) >= Cast(@start_date as date) and 
Cast(created_at as date) <= Cast(@end_date as date))
group by customer_id

) AS P
on p.customer_id = C.customer_id

left join (select sum(confiscated_points) as confiscated_points,customer_id 
from points_confiscated_detail 
where 
(Cast(created_at as date) >= Cast(@start_date as date) and 
Cast(created_at as date) <= Cast(@end_date as date))
group by customer_id
) confis
on c.customer_id = confis.customer_id
group by G.id) AS S
on G.id = S.id
where G.team_id = @team_id) as summary
where summary.agency_id = @agency_id
--order by ranking 

  


/* By Phone_no
Set @phone_no = (select phone_no from customer where customer_id = @customer_id)

Set @team = (select team from agency_game_customers as c ,agency_game as g where
  phone_no = @phone_no
  and c.group_id =g.id)

--- By Points 

print (@phone_no)

select G.id as agency_id , G.agency_name , ISNULL(s.total,0) as total_scans,
rank() over (order by  ISNULL(s.total,0) desc) as ranking
 from agency_game as G 
left join 
(select sum(isnull(p.points,0)) - sum(isnull(confis.confiscated_points,0)) as total ,G.id 

from agency_game_customers as A

join customer as C

on C.phone_no = A.phone_no

join agency_game as G

on G.id = A.group_id
and G.team = @team


Join 
(select sum(points) as points,customer_id from customer_earned_points where 
(Cast(created_at as date) >= Cast(@start_date as date) and 
Cast(created_at as date) <= Cast(@end_date as date))
group by customer_id

) AS P
on p.customer_id = C.customer_id

left join (select sum(confiscated_points) as confiscated_points,customer_id 
from points_confiscated_detail 
where 
(Cast(created_at as date) >= Cast(@start_date as date) and 
Cast(created_at as date) <= Cast(@end_date as date))
group by customer_id
) confis
on c.customer_id = confis.customer_id
group by G.id) AS S
on G.id = S.id
where G.team = @team
order by ranking */

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



--select * from agency_game_customers

--select customer_id from customer where phone_no = 96338063