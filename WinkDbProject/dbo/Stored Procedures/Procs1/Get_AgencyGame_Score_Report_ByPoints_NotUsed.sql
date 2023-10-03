CREATE PROC [dbo].[Get_AgencyGame_Score_Report_ByPoints_NotUsed]
(
  @campaign_id int,
  @team varchar(10),
  @from_date varchar(20),
  @to_date varchar(20),
  @status varchar(30)
)

AS

BEGIN
Declare @start_date datetime
Declare @end_date datetime
Declare @select_status varchar(50)
Declare @current_date datetime
Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

set @start_date = @from_date
set @end_date = @to_date
set @select_status = @status
If (@select_status = 'agency_highest_scan')
BEGIN
print('agency_highest_scan')
select G.id as group_id , G.agency_name , 
sum(ISNULL(s.total,0)) as total_scans
 from agency_game as G 
left join 
(select A.group_id,G.agency_name,p.customer_id,

--Count(*)-sum(A.total_confiscated_scan) as total  --for scan
(sum(p.points) - sum(A.total_confiscated_points)) as total -- for points
 from agency_game_customers as A
join customer as C
on C.phone_no = A.phone_no
join agency_game as G
on G.id = A.group_id
and G.team = @team
Join customer_earned_points as P
on p.customer_id = C.customer_id
and (Cast(p.created_at as date) >= Cast(@start_date as date) and 
Cast(p.created_at as date) <= Cast(@end_date as date)
)
group by  A.group_id,G.agency_name,p.customer_id) as s

on G.id = s.group_id
where G.team = @team
group by g.id,g.agency_name
order by sum(ISNULL(s.total,0)) desc
END
Else IF (@select_status ='daily_top_scan')
BEGIN
print(@select_status)
select A.group_id,G.agency_name,p.customer_id,c.customer_id,A.phone_no,
(c.first_name +' '+c.last_name) as cust_name,c.email,cast(p.created_at as date) as created_at,
--Count(*) as total  --for scan
sum(p.points) as total -- for points
 from agency_game_customers as A
join customer as C
on C.phone_no = A.phone_no
join agency_game as G
on G.id = A.group_id
--and G.team = 2
Join customer_earned_points as P
on p.customer_id = C.customer_id
--and (Cast(p.created_at as date) >= Cast(@current_date as date) 
and (Cast(p.created_at as date) >= Cast(@start_date as date)
and Cast(p.created_at as date) <= Cast(@to_date as date)
and p.qr_code like '%AgencyGame%'
)
--where c.status ='enable'
group by  A.group_id,G.agency_name,p.customer_id,c.customer_id,A.phone_no,
c.first_name,c.last_name,c.email,cast(p.created_at as date)
order by cast(p.created_at as date),sum(p.points)

END
Else IF (@select_status ='weekly_top_scan')
BEGIN
print(@select_status)
select A.group_id,G.agency_name,p.customer_id,c.customer_id,A.phone_no,
(c.first_name +' '+c.last_name) as cust_name,c.email,cast(p.created_at as date) as created_at,
--Count(*) as total  --for scan
sum(p.points) as total -- for points
 from agency_game_customers as A
join customer as C
on C.phone_no = A.phone_no
join agency_game as G
on G.id = A.group_id
--and G.team = 2
Join customer_earned_points as P
on p.customer_id = C.customer_id
--and (Cast(p.created_at as date) >= Cast(@current_date as date) 
and (Cast(p.created_at as date) >= Cast(@start_date as date)
and Cast(p.created_at as date) <= Cast(@to_date as date)
and p.qr_code like '%AgencyGame%'
)
--where c.status ='enable'
group by  A.group_id,G.agency_name,p.customer_id,c.customer_id,A.phone_no,
c.first_name,c.last_name,c.email,cast(p.created_at as date)
order by cast(p.created_at as date),sum(p.points)

END


END

