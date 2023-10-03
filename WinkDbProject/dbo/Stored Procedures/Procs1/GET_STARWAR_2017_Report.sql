CREATE PROC [dbo].[GET_STARWAR_2017_Report]
(
	@customer_id int,
	@customer_name varchar(200),
	@email varchar(200),
	@starwarcode varchar(10),
	@from_date varchar(20),
	@to_date varchar(20)
)
AS

BEGIN

Declare @campaign_start_date datetime
Declare @campaing_end_date datetime
Declare @campaign_name varchar(100)

select @campaign_start_date = from_date , @campaing_end_date = to_date ,@campaign_name = campaign_name from winktag_campaign as w
where w.winktag_type ='starwar2017'

--- For testing 

set @campaign_start_date = '2017-02-01'

print (@campaign_start_date)

	IF(@customer_name is null or @customer_name ='')
		SET @customer_name = NULL

	IF(@email is null or @email ='')
		SET @email = NULL

	IF(@starwarcode is null or @starwarcode ='')
	SET @starwarcode = NULL

	IF(@customer_id = 0)
		SET @customer_id = NULL

		---- Check Datetime

	IF(@from_date is null or @from_date ='' or @to_date ='' or @to_date is null)
	BEGIN

;WITH old_user as (

				 SELECT  p.customer_id ,p.created_at,'' as starwar_code,
									   ROW_NUMBER() OVER (PARTITION BY p.customer_id ORDER BY p.created_at) AS rn
									   FROM customer_earned_points as p , customer as c 
									   where
									   p.customer_id = c.customer_id and 
										cast (p.created_at as date) >= cast (@campaign_start_date as date)
									   and cast (p.created_at as date) <= cast (@campaing_end_date as date)
									   and cast(c.created_at as date) < cast (@campaign_start_date as date)
									   --where customer_id =1148

					

				),
			new_user as (

			SELECt  p.customer_id ,p.created_at,s.starwar_code as  starwar_code,
								   ROW_NUMBER() OVER (PARTITION BY p.customer_id ORDER BY p.created_at) AS rn
								   FROM customer_earned_points as p , winktag_starwar_2017 as s
								   where cast (p.created_at as date) >= cast (@campaign_start_date as date)
								   and cast (p.created_at as date) <= cast (@campaing_end_date as date)
								   and p.customer_id = s.customer_id
			
								   --where customer_id =1148

			)

			
            select * from (
			(select a.customer_id,a.email,(a.first_name+' '+a.last_name) as customer_name,n.starwar_code,
			 n.rn as total_scans_real,@campaign_name as campaign_name,5 as total_scans,
			 n.created_at from new_user as n
			join customer as a
			on n.customer_id = a.customer_id 
			and n.rn = 1
			and (@email is null or a.email like @email+'%')
			and (@customer_id is null or a.customer_id = @customer_id)
			and (@starwarcode is null or n.starwar_code = @starwarcode)
			and (@customer_name is null or (a.first_name+' '+a.last_name like '%'+@customer_name+'%'))
			)
			union 
			(select top 200  o.customer_id,b.email,(b.first_name+' '+b.last_name) as customer_name,o.starwar_code,
			 o.rn as total_scans_real,@campaign_name as campaign_name, 10 as total_scans,
			 o.created_at from old_user as o
			join customer as b
			on o.customer_id = b.customer_id   
			and o.rn=10
			and (@email is null or b.email like @email+'%')
			and (@customer_id is null or b.customer_id = @customer_id)
			and (@starwarcode is null or o.starwar_code = @starwarcode or @starwarcode='old')
			and (@customer_name is null or (b.first_name+' '+b.last_name like '%'+@customer_name+'%'))
			order by o.created_at)
			
			) as k
			order by k.created_at desc


			END

			ELSE
			BEGIN
			
;WITH old_user as (

				 SELECT  p.customer_id ,p.created_at,'' as starwar_code,
									   ROW_NUMBER() OVER (PARTITION BY p.customer_id ORDER BY p.created_at) AS rn
									   FROM customer_earned_points as p , customer as c 
									   where
									   p.customer_id = c.customer_id and 
										cast (p.created_at as date) >= cast (@campaign_start_date as date)
									   and cast (p.created_at as date) <= cast (@campaing_end_date as date)
									   and cast(c.created_at as date) < cast (@campaign_start_date as date)
									   --where customer_id =1148

					

				),
			new_user as (

			SELECt  p.customer_id ,p.created_at,s.starwar_code as  starwar_code,
								   ROW_NUMBER() OVER (PARTITION BY p.customer_id ORDER BY p.created_at) AS rn
								   FROM customer_earned_points as p , winktag_starwar_2017 as s
								   where cast (p.created_at as date) >= cast (@campaign_start_date as date)
								   and cast (p.created_at as date) <= cast (@campaing_end_date as date)
								   and p.customer_id = s.customer_id
			
								   --where customer_id =1148

			)

			
            select * from (
			(select a.customer_id,a.email,(a.first_name+' '+a.last_name) as customer_name,n.starwar_code,
			 n.rn as total_scans_real,@campaign_name as campaign_name,5 as total_scans,
			 n.created_at from new_user as n
			join customer as a
			on n.customer_id = a.customer_id 
			and n.rn = 5
			and (@email is null or a.email like @email+'%')
			and (@customer_id is null or a.customer_id = @customer_id)
			and (@starwarcode is null or n.starwar_code = @starwarcode)
			and (@customer_name is null or (a.first_name+' '+a.last_name like '%'+@customer_name+'%'))
			and (cast (n.created_at as date)>= cast (@from_date as date))
			and  (cast (n.created_at as date)<= cast (@to_date as date))
			)
			union 
			(select top 200  o.customer_id,b.email,(b.first_name+' '+b.last_name) as customer_name,o.starwar_code,
			 o.rn as total_scans_real,@campaign_name as campaign_name,10 as total_scans,
			 o.created_at from old_user as o
			join customer as b
			on o.customer_id = b.customer_id   
			and o.rn=10
			and (@email is null or b.email like @email+'%')
			and (@customer_id is null or b.customer_id = @customer_id)
			and (@starwarcode is null or o.starwar_code = @starwarcode or @starwarcode='old')
			and (@customer_name is null or (b.first_name+' '+b.last_name like '%'+@customer_name+'%'))
			and (cast (o.created_at as date)>= cast (@from_date as date))
			and  (cast (o.created_at as date)<= cast (@to_date as date))
			    
			order by o.created_at)
			
			) as k
			order by k.created_at desc

			END

END

