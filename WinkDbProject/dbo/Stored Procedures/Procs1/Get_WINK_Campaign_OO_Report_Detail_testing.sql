
CREATE PROC [dbo].[Get_WINK_Campaign_OO_Report_Detail_testing]
(
  
  @campaign_name varchar(10),
  @customer_id int,
  @email varchar(50),
  @customer_name varchar(100),
  @gender varchar(10),
  @contest_prize varchar(10),
  @from_date varchar(20),
  @to_date varchar(20),
  @redemption_status varchar(10) ,
  @branch_code varchar(10),
  @branch_name varchar(50),
  @correct_answer_status varchar(10)
  )

AS

BEGIN

	Declare @CAMPAIGN_ID int
	set @CAMPAIGN_ID =16



	IF(@campaign_name is null or @campaign_name ='')
	BEGIN
		SET @campaign_name = NULL;
	END

	IF(@customer_id is null or @customer_id ='' or @customer_id =0)
	BEGIN
		SET @customer_id = NULL;
	END

	IF(@email is null or @email ='')
	BEGIN
		SET @email = NULL;
	END

	IF(@customer_name is null or @customer_name ='')
	BEGIN
		SET @customer_name = NULL;
	END

	IF(@gender is null or @gender ='')
	BEGIN
		SET @gender = NULL;
	END

	IF(@contest_prize is null or @contest_prize ='')
	BEGIN
		SET @contest_prize = NULL;
	END

	IF(@from_date is null or @from_date ='')
	BEGIN
		SET @from_date = NULL;
	END

	IF(@to_date is null or @to_date = '')
	BEGIN
		SET @to_date = NULL;
	END

	IF(@redemption_status is null or @redemption_status ='')
	BEGIN
		SET @redemption_status = NULL;
	END

	IF(@branch_code is null or @branch_code ='')
	BEGIN
		SET @branch_code =NULL;
	END

	IF(@branch_name is null or @branch_name ='')
	BEGIN
		SET @branch_name =NULL;
	END

	IF (@correct_answer_status is null OR @correct_answer_status ='')
	BEGIN 
		SET @correct_answer_status =NULL;
	END

	print ('@correct_answer_status')
	print (@correct_answer_status)

    IF(@redemption_status ='1' AND @correct_answer_status ='No')
	BEGIN
		return
	END
	ELSE
	BEGIN
		IF (@from_date is null or @to_date is null)
		Select * from (
			SELECT o.campaign_name,o.prize,t.from_time,t.to_time,w.answer,w.branch_code,m.merchant_name as branch_name
			,w.redemption_status,w.redemption_date,w.created_at as participated_date, w.points,
			w.gps,(c.first_name+' '+ c.last_name ) as customer_name,c.gender,W.updated_at,
			c.customer_id,c.email,
			floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) as age,

			'Yes' as correct_answer_status
	
			FROM wink_oo_campaign_winner as w 
			JOIN 

			wink_oo_campaign_timing as t

			ON w.campaign_timing_id = t.id

			AND (@redemption_status is null or w.redemption_status = @redemption_status)
			AND (@customer_id is null or w.customer_id =@customer_id)
			--AND (@from_date is null or (cast(w.updated_at as date) >= cast(@from_date as date) AND 
			--cast(w.updated_at as date) <= cast(@to_date as date)))

			JOIN
			wink_oo_campaign as o

			ON o.campaign_id = t.campaign_id

			AND 

			(@campaign_name is null OR o.campaign_name like '%'+@campaign_name +'%' ) --- FILTER CAMPAIGN NAME
			AND 
			(@contest_prize is null OR o.prize like '%'+@contest_prize +'%') --- FILTER PRIZE

			JOIN 
			customer as c
			ON c.customer_id = w.customer_id
	
			LEFT JOIN
	
			wink_oo_campaign_merchant as m

			ON m.branch_code =w.branch_code

			WHERE 
			(@branch_name is NULL or m.merchant_name like '%'+@branch_name+'%')
			AND 
			(@branch_code is NULL or m.branch_code =@branch_code )
				AND 
			(@email is null OR c.email like '%'+@email +'%' )

			AND 
			(@customer_name is null OR ((c.first_name+' '+c.last_name) like '%'+@customer_name +'%'))

			AND 
			( @gender is null OR c.gender =@gender ) 
			-------------------------UNION WITH OO LOG---------------------
			UNION
			 
			SELECT o.campaign_name,o.prize,t.from_time,t.to_time,'' as answer,'' as branch_code,'' as branch_name
			,0 AS redemption_status, NULL as redemption_date,w.created_at as participated_date, w.points,
			w.gps,(c.first_name+' '+ c.last_name ) as customer_name,c.gender,W.updated_at,
			c.customer_id,c.email,
			floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) as age,

			'No' as correct_answer_status
	
			FROM wink_oo_campaign_winner_log as w

			JOIN customer as c

			ON 
			w.customer_id = c.customer_id

			JOIN

			wink_oo_campaign_timing as t

			ON
			
			w.campaign_timing_id = t.id 

				JOIN
			wink_oo_campaign as o

			ON
			
			w.campaign_id = o.campaign_id		
			WHERE 	
			--(@from_date is null or (cast(w.updated_at as date) >= cast(@from_date as date) AND 
			--cast(w.updated_at as date) <= cast(@to_date as date)))
			--AND 
			(o.campaign_name like '%'+@campaign_name +'%' OR @campaign_name is null)
			AND 
			(@email is null OR c.email like '%'+@email +'%' )
			AND 
			(@customer_name is null OR ((c.first_name+' '+c.last_name) like '%'+@customer_name +'%'))
			AND 
			( @gender is null OR c.gender =@gender )
			AND 
			(@customer_id is null or c.customer_id =@customer_id)
	  
			-------UNION WITH WINK TAG LOG---------------------------
/*
			UNION

			select '' as campaign_name ,'' as prize,'' as from_time,'' as to_time,'' as answer,'' as branch_code,'' as branch_name
			,0 as redemption_status, NULL as redemption_date,A.created_at as participated_date, 0 as points,
			location as gps,(c.first_name+' '+ c.last_name ) as customer_name,c.gender,A.created_at as updated_at,
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
			(@email is null OR c.email like '%'+@email +'%' )

			AND 
			(@customer_name is null OR ((c.first_name+' '+c.last_name) like '%'+@customer_name +'%'))
			AND 
			( @gender is null OR c.gender =@gender )

			AND (@customer_id is null or c.customer_id =@customer_id)
			--AND (@from_date is null or (cast (A.created_at as date) >= cast (@from_date as date)
	        --AND cast (A.created_at  as date) <= cast (@to_date as date)))
			*/
		)
		as l
		-- WHERE (@from_date is null or (cast (l.updated_at as date) >= cast (@from_date as date)
		--AND cast (l.updated_at as date) <= cast (@to_date as date)))
		WHERE (@campaign_name is null or l.campaign_name like '%'+@campaign_name +'%')
		AND (@branch_code is NULL or l.branch_code =@branch_code )
		AND (@branch_name is NULL or l.branch_name like '%'+@branch_name+'%')
		AND (prize like '%'+@contest_prize +'%' OR @contest_prize is null)
		AND (@redemption_status is null or l.redemption_status = @redemption_status)
		AND (@correct_answer_status is null or @correct_answer_status =l.correct_answer_status)
		order by l.updated_at desc
		ELSE
		Select * from (
			SELECT o.campaign_name,o.prize,t.from_time,t.to_time,w.answer,w.branch_code,m.merchant_name as branch_name
			,w.redemption_status,w.redemption_date,w.created_at as participated_date, w.points,
			w.gps,(c.first_name+' '+ c.last_name ) as customer_name,c.gender,W.updated_at,
			c.customer_id,c.email,
			floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) as age,

			'Yes' as correct_answer_status
	
			FROM wink_oo_campaign_winner as w 
			JOIN 

			wink_oo_campaign_timing as t

			ON w.campaign_timing_id = t.id

			AND (@redemption_status is null or w.redemption_status = @redemption_status)
			AND (@customer_id is null or w.customer_id =@customer_id)
			AND (@from_date is null or (cast(w.updated_at as date) >= cast(@from_date as date) AND 
			cast(w.updated_at as date) <= cast(@to_date as date)))

			JOIN
			wink_oo_campaign as o

			ON o.campaign_id = t.campaign_id

			AND 

			(@campaign_name is null OR o.campaign_name like '%'+@campaign_name +'%' ) --- FILTER CAMPAIGN NAME
			AND 
			(@contest_prize is null OR o.prize like '%'+@contest_prize +'%') --- FILTER PRIZE

			JOIN 
			customer as c
			ON c.customer_id = w.customer_id
	
			LEFT JOIN
	
			wink_oo_campaign_merchant as m

			ON m.branch_code =w.branch_code

			WHERE 
			(@branch_name is NULL or m.merchant_name like '%'+@branch_name+'%')
			AND 
			(@branch_code is NULL or m.branch_code =@branch_code )
				AND 
			(@email is null OR c.email like '%'+@email +'%' )

			AND 
			(@customer_name is null OR ((c.first_name+' '+c.last_name) like '%'+@customer_name +'%'))

			AND 
			( @gender is null OR c.gender =@gender ) 
			-------------------------UNION WITH OO LOG---------------------
			UNION
			 
			SELECT o.campaign_name,o.prize,t.from_time,t.to_time,'' as answer,'' as branch_code,'' as branch_name
			,0 AS redemption_status, NULL as redemption_date,w.created_at as participated_date, w.points,
			w.gps,(c.first_name+' '+ c.last_name ) as customer_name,c.gender,W.updated_at,
			c.customer_id,c.email,
			floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) as age,

			'No' as correct_answer_status
	
			FROM wink_oo_campaign_winner_log as w

			JOIN customer as c

			ON 
			w.customer_id = c.customer_id

			JOIN

			wink_oo_campaign_timing as t

			ON
			
			w.campaign_timing_id = t.id 

				JOIN
			wink_oo_campaign as o

			ON
			
			w.campaign_id = o.campaign_id		
			WHERE 	
			(@from_date is null or (cast(w.updated_at as date) >= cast(@from_date as date) AND 
			cast(w.updated_at as date) <= cast(@to_date as date)))
			AND 
			(o.campaign_name like '%'+@campaign_name +'%' OR @campaign_name is null)
			AND 
			(@email is null OR c.email like '%'+@email +'%' )
			AND 
			(@customer_name is null OR ((c.first_name+' '+c.last_name) like '%'+@customer_name +'%'))
			AND 
			( @gender is null OR c.gender =@gender )
			AND 
			(@customer_id is null or c.customer_id =@customer_id)
	  
			-------UNION WITH WINK TAG LOG---------------------------
			/*
			UNION

			select '' as campaign_name ,'' as prize,'' as from_time,'' as to_time,'' as answer,'' as branch_code,'' as branch_name
			,0 as redemption_status, NULL as redemption_date,A.created_at as participated_date, 0 as points,
			location as gps,(c.first_name+' '+ c.last_name ) as customer_name,c.gender,A.created_at as updated_at,
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
			(@email is null OR c.email like '%'+@email +'%' )

			AND 
			(@customer_name is null OR ((c.first_name+' '+c.last_name) like '%'+@customer_name +'%'))
			AND 
			( @gender is null OR c.gender =@gender )

			AND (@customer_id is null or c.customer_id =@customer_id)
			AND (@from_date is null or (cast (A.created_at as date) >= cast (@from_date as date)
	        AND cast (A.created_at  as date) <= cast (@to_date as date)))
			*/
		)
		as l
		where (@from_date is null or (cast (l.updated_at as date) >= cast (@from_date as date)
		AND cast (l.updated_at as date) <= cast (@to_date as date)))
		AND (@campaign_name is null or l.campaign_name like '%'+@campaign_name +'%')
		AND (@branch_code is NULL or l.branch_code =@branch_code )
		AND (@branch_name is NULL or l.branch_name like '%'+@branch_name+'%')
		AND (prize like '%'+@contest_prize +'%' OR @contest_prize is null)
		AND (@redemption_status is null or l.redemption_status = @redemption_status)
		AND (@correct_answer_status is null or @correct_answer_status =l.correct_answer_status)
		order by l.updated_at desc
	END
END