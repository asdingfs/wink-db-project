CREATE PROC [dbo].[WINKTAG_GET_SIMPLIFIED_REPORT_VALIDITY_NDP2021]
(
	@customer_name varchar(200),
	@email varchar(200),
	@gender varchar(200),
	@customer_id int,
	@start_date varchar(50),
	@end_date varchar(50),
	@winktag_report varchar(50),
	@wid varchar(50),
	@status varchar(50),
	@validity varchar(10),
	@winner varchar(10) = null

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

	IF(@validity is null or @validity='')
		SET @validity = NULL

	IF(@winner is null or @winner='')
		SET @winner = NULL
	
	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
		RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)

	/*IF(@CAMPAIGN_ID = 167 )*/
				
	IF(@CAMPAIGN_ID = 167 or @CAMPAIGN_ID = 158 or @CAMPAIGN_ID = 156 or @CAMPAIGN_ID = 148 or @CAMPAIGN_ID = 144 or @CAMPAIGN_ID = 113 or @CAMPAIGN_ID = 115 or @CAMPAIGN_ID = 117 or @CAMPAIGN_ID = 118 or @CAMPAIGN_ID = 120 or @CAMPAIGN_ID = 125 or @CAMPAIGN_ID = 129 )
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
					T.Q1
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT customer_id,0 as points,location as GPS_location,ip_address,created_at, '' as Q1
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
					WHERE ( @validity is null 
							or (@validity = 'Yes' AND T.Q1 != '')  
							or (@validity = '0' AND T.Q1 = ''))
						  AND 	
						   ( @winner is null   
							or 
							(@CAMPAIGN_ID = 167  AND ((@winner = 'Yes' AND T.Q1 like '%THE ROAD AHEAD%')  
							or (@winner = '0'  AND T.Q1 not like '%THE ROAD AHEAD%')))
							)
						
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
	ELSE IF(@CAMPAIGN_ID = 139 or @CAMPAIGN_ID = 114)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
					T.Q2
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at, '' as Q2
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
					WHERE @validity is null 
							or (@validity = 'Yes' AND T.Q2 != '')  
							or (@validity = '0' AND T.Q2 = '')
						
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
	ELSE IF(@CAMPAIGN_ID = 119)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
					T.winner,T.Q1
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at, '' AS winner, '' as Q1
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count AND T1.option_id = 1642
						) as winner,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
					WHERE @validity is null 
							or (@validity = 'Yes' AND T.Q1 != '')  
							or (@validity = '0' AND T.Q1 = '')
						
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

	ELSE IF(@CAMPAIGN_ID = 127)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
					isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4,isnull(T.Q3_5,'') as Q3_5,isnull(T.Q3_6,'') as Q3_6,isnull(T.Q3_7,'') as Q3_7
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT customer_id,0 as points,location as GPS_location,ip_address,created_at, 
						'' as Q3_1, '' as Q3_2,'' as Q3_3,'' as Q3_4,'' as Q3_5,'' as Q3_6,'' as Q3_7

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.1' AND T1.row_count = C.row_count
						) as Q3_1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.2' AND T1.row_count = C.row_count
						) as Q3_2,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.3' AND T1.row_count = C.row_count
						) as Q3_3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.4' AND T1.row_count = C.row_count
						) as Q3_4,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.5' AND T1.row_count = C.row_count
						) as Q3_5,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.6' AND T1.row_count = C.row_count
						) as Q3_6,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.7' AND T1.row_count = C.row_count
						) as Q3_7
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
					WHERE @validity is null 
							or (@validity = 'Yes' AND (T.Q3_1 != '' or T.Q3_2 != '' or T.Q3_3 != '' or T.Q3_4 != '' or T.Q3_5 != ''or T.Q3_6 != ''or T.Q3_7 != '') ) 
							or (@validity = '0' AND T.Q3_1 = '' AND T.Q3_2 = '' AND T.Q3_3 = '' AND T.Q3_4 = '' AND T.Q3_5 = '' AND T.Q3_6 = '' AND T.Q3_7 = '')
						
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
	ELSE IF(@CAMPAIGN_ID = 157)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at, 
					isnull(T.Q1,'') as Q1
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at,
						'' as Q1
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5' 
						) as Q1
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
					WHERE @validity is null 
							or (@validity = 'Yes' AND T.Q1 != '')  
							or (@validity = '0' AND (T.Q1 is null or T.Q1=''))
						
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



