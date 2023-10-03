CREATE PROC [dbo].[WINKTAG_GET_SIMPLIFIED_REPORT]
(
	@customer_name varchar(200),
	@email varchar(200),
	@gender varchar(200),
	@customer_id int,
	@start_date varchar(50),
	@end_date varchar(50),
	@winktag_report varchar(50),
	@wid varchar(50),
	@status varchar(50)
)
AS

BEGIN

	DECLARE @CAMPAIGN_ID int;
	
	IF (@start_date is null or @start_date = '')
		SET @start_date = NULL;

	IF (@end_date is null or @end_date = '')
		SET @end_date = NULL;

	IF(@customer_name is null or @customer_name ='')
		SET @customer_name = NULL

	IF(@email is null or @email ='')
		SET @email = NULL

	IF(@gender is null or @gender ='')
	SET @gender = NULL

	IF(@customer_id = 0)
		SET @customer_id = NULL

	IF(@wid is null or @wid ='')
		SET @wid = NULL

	IF(@status is null or @status='')
		SET @status = NULL
	
	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
		RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)
  IF(@CAMPAIGN_ID = 74 or @CAMPAIGN_ID = 77 or @CAMPAIGN_ID = 85 or  @CAMPAIGN_ID = 95 or  @CAMPAIGN_ID = 106 or @CAMPAIGN_ID = 108 or @CAMPAIGN_ID = 113 )
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
					T.Q1
					
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at, '' as Q1
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

				) AS TEMP----1 END
				WHERE (@email is null or TEMP.email like '%'+@email+'%')
				and (@gender is null or TEMP.gender = @gender)
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@status is null or TEMP.status = @status)
				AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
				order by temp.no desc
		END
  ELSE IF(@CAMPAIGN_ID = 76)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
					T.Q3
					
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at, '' as Q3
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
						
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
						) as Q3
						
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

				) AS TEMP----1 END
				WHERE (@email is null or TEMP.email like '%'+@email+'%')
				and (@gender is null or TEMP.gender = @gender)
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@status is null or TEMP.status = @status)
				AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
				order by temp.no desc
		END
	ELSE IF(@CAMPAIGN_ID = 66)
	BEGIN
		SELECT * FROM 
			(--1 START
				SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
				T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,T.winner,
				T.Q1
					
					
				FROM

				(
					-----table1
					SELECT * from
					(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at, '' AS winner,'' as Q1
					from winktag_customer_action_log 
						WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
					) as T1
					-----table1

					UNION
	
					-----table2
					SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count AND T1.option_id = 955
					) as winner,
						
					(
						SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
					) as Q1
						
					FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
					-----table2

				) AS T 
				INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

			) AS TEMP----1 END
			WHERE (@email is null or TEMP.email like '%'+@email+'%')
			and (@gender is null or TEMP.gender = @gender)
			AND (@wid is null or TEMP.wid like '%'+@wid+'%')
			AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
			AND (@customer_id is null or TEMP.customer_id = @customer_id)
			AND (@status is null or TEMP.status = @status)
			AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
			order by temp.no desc
	END
	ELSE IF(@CAMPAIGN_ID = 67)
	BEGIN
		SELECT * FROM 
			(--1 START
				SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
				T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,T.winner,
				T.Q1
					
					
				FROM

				(
					-----table1
					SELECT * from
					(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at, '' AS winner,'' as Q1
					from winktag_customer_action_log 
						WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
					) as T1
					-----table1

					UNION
	
					-----table2
					SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count AND T1.option_id = 979
					) as winner,
						
					(
						SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
					) as Q1
						
					FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
					-----table2

				) AS T 
				INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

			) AS TEMP----1 END
			WHERE (@email is null or TEMP.email like '%'+@email+'%')
			and (@gender is null or TEMP.gender = @gender)
			AND (@wid is null or TEMP.wid like '%'+@wid+'%')
			AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
			AND (@customer_id is null or TEMP.customer_id = @customer_id)
			AND (@status is null or TEMP.status = @status)
			AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
			order by temp.no desc
	END
	ELSE IF(@CAMPAIGN_ID = 69)
	BEGIN
		SELECT * FROM 
			(--1 START
				SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
				T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,T.winner,
				T.Q1
					
					
				FROM

				(
					-----table1
					SELECT * from
					(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at, '' AS winner,'' as Q1
					from winktag_customer_action_log 
						WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
					) as T1
					-----table1

					UNION
	
					-----table2
					SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count AND T1.option_id = 1030
					) as winner,
						
					(
						SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
					) as Q1
						
					FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
					-----table2

				) AS T 
				INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

			) AS TEMP----1 END
			WHERE (@email is null or TEMP.email like '%'+@email+'%')
			and (@gender is null or TEMP.gender = @gender)
			AND (@wid is null or TEMP.wid like '%'+@wid+'%')
			AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
			AND (@customer_id is null or TEMP.customer_id = @customer_id)
			AND (@status is null or TEMP.status = @status)
			AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
			order by temp.no desc
	END
	ELSE IF(@CAMPAIGN_ID = 70)
	BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,T.winner,
					T.Q1
					
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at, '' AS winner,'' as Q1
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count AND T1.option_id = 1097
						) as winner,
						
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1
						
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

				) AS TEMP----1 END
				WHERE (@email is null or TEMP.email like '%'+@email+'%')
				and (@gender is null or TEMP.gender = @gender)
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@status is null or TEMP.status = @status)
				AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
				order by temp.no desc
		END
	ELSE IF(@CAMPAIGN_ID = 75 )
	BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,T.winner,
					T.Q1
					
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at, '' AS winner,'' as Q1
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count AND T1.option_id = 1169
						) as winner,
						
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1
						
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

				) AS TEMP----1 END
				WHERE (@email is null or TEMP.email like '%'+@email+'%')
				and (@gender is null or TEMP.gender = @gender)
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@status is null or TEMP.status = @status)
				AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
				order by temp.no desc
		END
	ELSE IF(@CAMPAIGN_ID = 97)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,T.winner,
					T.Q1
					
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at, '' AS winner,'' as Q1
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count AND T1.option_id = 1340
						) as winner,
						
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1
						
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

				) AS TEMP----1 END
				WHERE (@email is null or TEMP.email like '%'+@email+'%')
				and (@gender is null or TEMP.gender = @gender)
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@status is null or TEMP.status = @status)
				AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
				order by temp.no desc
		END
	ELSE IF(@CAMPAIGN_ID = 142 or @CAMPAIGN_ID = 102)
	BEGIN
		
	SELECT * FROM 
	(--1 START
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
		T.campaign_id,T.customer_id,T.GPS_location,T.ip_address,T.created_at,
		T.Q1
		FROM(
			SELECT  * FROM  
			(SELECT campaign_id,customer_id, location as GPS_location,ip_address,created_at, '' as Q1
			from winktag_customer_action_log 
				WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
			) as T1
					-----table1

			UNION

			SELECT * from 

			(
				SELECT campaign_id,customer_id, GPS_location, ip_address, created_at, answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1'
			) as Q1

					
			) AS T 
				INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

		) AS TEMP----1 END
		WHERE (@email is null or TEMP.email like '%'+@email+'%')
		AND (@wid is null or TEMP.wid like '%'+@wid+'%')
		AND (@gender is null or TEMP.gender like @gender+'%')
		AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
		AND (@customer_id is null or TEMP.customer_id = @customer_id)
		AND (@status is null or TEMP.status = @status)
		AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			
		order by temp.no desc
	END
	ELSE IF(@CAMPAIGN_ID = 104)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,T.winner,
					T.Q1
					
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at, '' AS winner,'' as Q1
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count AND T1.option_id = 1483
						) as winner,
						
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1
						
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

				) AS TEMP----1 END
				WHERE (@email is null or TEMP.email like '%'+@email+'%')
				and (@gender is null or TEMP.gender = @gender)
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@status is null or TEMP.status = @status)
				AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
				order by temp.no desc
		END
	ELSE IF(@CAMPAIGN_ID = 105)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.customer_id,T.GPS_location,T.ip_address,T.created_at,T.winner,
					T.Q1
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT customer_id,location as GPS_location,ip_address,created_at
						, '' AS winner
						, '' AS Q1
						
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.customer_id,C.GPS_location,C.ip_address,C.created_at,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count AND T1.option_id = 1503
						) as winner,

						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1


						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

				) AS TEMP----1 END
				WHERE (@email is null or TEMP.email like '%'+@email+'%')
				and (@gender is null or TEMP.gender = @gender)
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@status is null or TEMP.status = @status)
				AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
				order by temp.no desc
		END
	ELSE IF(@CAMPAIGN_ID = 107)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.customer_id,T.GPS_location,T.ip_address,T.created_at,T.winner,
					T.Q1
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT customer_id,location as GPS_location,ip_address,created_at
						, '' AS winner
						, '' AS Q1
						
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.customer_id,C.GPS_location,C.ip_address,C.created_at,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count AND T1.option_id = 1524
						) as winner,

						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1


						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

				) AS TEMP----1 END
				WHERE (@email is null or TEMP.email like '%'+@email+'%')
				and (@gender is null or TEMP.gender = @gender)
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@status is null or TEMP.status = @status)
				AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
				order by temp.no desc
		END
	ELSE IF(@CAMPAIGN_ID = 132)
	BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.customer_id,T.GPS_location,T.ip_address,T.created_at,T.winner,
					T.Q1
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT customer_id,location as GPS_location,ip_address,created_at
						, '' AS winner
						, '' AS Q1
						
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.customer_id,C.GPS_location,C.ip_address,C.created_at,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count AND T1.option_id = 1747
						) as winner,

						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1


						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

				) AS TEMP----1 END
				WHERE (@email is null or TEMP.email like '%'+@email+'%')
				and (@gender is null or TEMP.gender = @gender)
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@status is null or TEMP.status = @status)
				AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
				order by temp.no desc
		END
	
END



