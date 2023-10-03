
CREATE PROC [dbo].[Get_AgencyGame_Score_Detail_NotUsed]
(
  @campaign_id int,
  @team varchar(10),
  @total_scans int,
  @from_date varchar(20),
  @to_date varchar(20),
  @status varchar(10)
)

AS

BEGIN
Declare @start_date datetime
Declare @end_date datetime
Declare @select_status varchar(20)

set @start_date = @from_date
set @end_date = @to_date
set @select_status = @status

If (@select_status = 'all')
BEGIN
select G.id as group_id , G.agency_name , ISNULL(s.total,0) as total_scans from agency_game as G 
left join 
(select A.group_id,G.agency_name,Count(*)-sum(A.total_confiscated_scan) as total  from agency_game_customers as A
join customer as C
on C.phone_no = A.phone_no
join agency_game as G
on G.id = A.group_id
and G.team = @team
Join customer_earned_points as P
on p.customer_id = C.customer_id
and (Cast(p.created_at as date) >= Cast(@start_date as date) and 
Cast(p.created_at as date) <= Cast(@end_date as date))
group by A.group_id,G.agency_name) as s

on G.id = s.group_id
where G.team = @team
order by total desc
END
Else IF (@select_status ='highest_scan')
BEGIN

select G.id as group_id , G.agency_name , ISNULL(s.total,0) as total_scans from agency_game as G 
left join 
(select A.group_id,G.agency_name,Count(*)-sum(A.total_confiscated_scan) as total  from agency_game_customers as A
join customer as C
on C.phone_no = A.phone_no
join agency_game as G
on G.id = A.group_id
and G.team = @team
Join customer_earned_points as P
on p.customer_id = C.customer_id
and (Cast(p.created_at as date) >= Cast(@start_date as date) and 
Cast(p.created_at as date) <= Cast(@end_date as date))
group by A.group_id,G.agency_name) as s

on G.id = s.group_id
where G.team = @team
order by total desc

END

Else IF (@select_status ='daily_top_scan')
BEGIN

select G.id as group_id , G.agency_name , ISNULL(s.total,0) as total_scans from agency_game as G 
left join 
(select A.group_id,G.agency_name,Count(*)-sum(A.total_confiscated_scan) as total  from agency_game_customers as A
join customer as C
on C.phone_no = A.phone_no
join agency_game as G
on G.id = A.group_id
and G.team = @team
Join customer_earned_points as P
on p.customer_id = C.customer_id
and (Cast(p.created_at as date) >= Cast(@start_date as date) and 
Cast(p.created_at as date) <= Cast(@end_date as date))
group by A.group_id,G.agency_name) as s

on G.id = s.group_id
where G.team = @team
order by total desc

END

Else IF (@select_status ='weekly_top_scan')
BEGIN

select G.id as group_id , G.agency_name , ISNULL(s.total,0) as total_scans from agency_game as G 
left join 
(select A.group_id,G.agency_name,Count(*)-sum(A.total_confiscated_scan) as total  from agency_game_customers as A
join customer as C
on C.phone_no = A.phone_no
join agency_game as G
on G.id = A.group_id
and G.team = @team
Join customer_earned_points as P
on p.customer_id = C.customer_id
and (Cast(p.created_at as date) >= Cast(@start_date as date) and 
Cast(p.created_at as date) <= Cast(@end_date as date))
group by A.group_id,G.agency_name) as s

on G.id = s.group_id
where G.team = @team
order by total desc

END



END

