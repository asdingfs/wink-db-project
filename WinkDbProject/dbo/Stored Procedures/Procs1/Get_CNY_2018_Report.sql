
CREATE PROC [dbo].[Get_CNY_2018_Report]
(
  
  --@campaign_name varchar(10),
  @customer_id int,
  @email varchar(50),
  @customer_name varchar(100),
  @gender varchar(10),
  --@answer varchar(10),
  @from_date varchar(20),
  @to_date varchar(20),
  @correct_answer_status varchar(10)
  )

AS

BEGIN

Declare @CAMPAIGN_ID int
set @CAMPAIGN_ID =25



		--IF(@campaign_name is null or @campaign_name ='')
		--set @campaign_name = NULL

		IF(@email is null or @email ='')
		set @email = NULL

		IF(@customer_name is null or @customer_name ='')
		set @customer_name = NULL

		IF(@gender is null or @gender ='')
		set @gender = NULL

		IF(@customer_id is null or @customer_id ='' or @customer_id =0)
		set @customer_id = NULL

		IF(@from_date is null or @from_date ='' or @to_date is null or @to_date is null)
		BEGIN
		set @from_date = NULL
		set @to_date = NULL

		END

	
		IF (@correct_answer_status is null OR @correct_answer_status ='')
		BEGIN 
		SET @correct_answer_status =NULL

		END


   
	   Select * from (
	 	  
			SELECT w.answer as ans , w.correct_answer_status as answer,
			w.created_at as participated_date, w.points_rewards as points,
			w.location,(c.first_name+' '+ c.last_name ) as customer_name,c.gender,W.updated_at,
			c.customer_id,c.email,
			floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) as age,

		    w.correct_answer_status as correct_answer_status
	
			FROM [CNY_2018_Campaign] as w 
						
			 JOIN 
			 customer as c
			 ON c.customer_id = w.customer_id
	         AND (@customer_id is null or w.customer_id =@customer_id)
			 AND (@from_date is null or (cast(w.updated_at as date) >= cast(@from_date as date) AND 
			 cast(w.updated_at as date) <= cast(@to_date as date)))
			 			
			WHERE 
		
			(@email is null OR c.email like @email +'%' )

			AND 
		    (@customer_name is null OR ((c.first_name+' '+c.last_name) like @customer_name +'%'))

			AND 
		    ( @gender is null OR c.gender =@gender ) 
		  
			-------UNION WITH WINK TAG LOG---------------------------

			 UNION

			SELECT '' as ans,'No' as answer,A.created_at as participated_date,
			0 as points,
			A.location,(c.first_name+' '+ c.last_name ) as customer_name,c.gender,A.created_at,
			c.customer_id,c.email,
			floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) as age,

		   'No' as correct_answer_status

			 from winktag_customer_action_log as A

			 JOIN 
			 
			 customer as c
			 on 
			 c.customer_id = A.customer_id
	  
			 JOIN 
			  (
				select customer_id, max(created_at) as MaxDate
				from winktag_customer_action_log
				group by customer_id
							) temp 
			 ON c.customer_id = temp.customer_id 
			 AND A.created_at = temp.MaxDate
			 WHERE A.campaign_id = @CAMPAIGN_ID
			 AND 
			 (@email is null OR c.email like @email +'%' )

			 AND 
			 (@customer_name is null OR ((c.first_name+' '+c.last_name) like @customer_name +'%'))
			 AND 
			 ( @gender is null OR c.gender =@gender )

			 AND (@customer_id is null or c.customer_id =@customer_id)
			 AND (@from_date is null or (cast (A.created_at as date) >= cast (@from_date as date)
	         AND cast (A.created_at  as date) <= cast (@to_date as date)))
			 AND A.customer_id not in (select distinct customer_id from [CNY_2018_Campaign]
			 where campaign_id = @CAMPAIGN_ID)
	  )

	  
	  	  
	   as l
	   where (@from_date is null or (cast (l.updated_at as date) >= cast (@from_date as date)
	   AND cast (l.updated_at as date) <= cast (@to_date as date)))
	 
	   AND (@correct_answer_status is null or @correct_answer_status =l.correct_answer_status)
	   --And customer_id not in (3,6,14)
	  order by l.updated_at desc
	
END

--select * from customer where email like 'nang' +'%'  or email like  '%'+'popo'+'%' or  email like  'zinwin'+'%' 