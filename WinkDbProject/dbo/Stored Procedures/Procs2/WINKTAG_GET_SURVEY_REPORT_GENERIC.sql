﻿CREATE PROC [dbo].[WINKTAG_GET_SURVEY_REPORT_GENERIC]
(
	@customer_name varchar(200),
	@email varchar(200),
	@gender varchar(200),
	@customer_id int,
	@start_date varchar(50),
	@end_date varchar(50),
	@winktag_report varchar(50),
	@winktag_point_status varchar(50)
)
AS

BEGIN

	DECLARE @CAMPAIGN_ID int;
	DECLARE @qr_code varchar(100);

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

	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
		RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)

	IF @winktag_report = 'SMA2017'
		SET @qr_code = 'SMA_SMA_21_49653'
	IF @winktag_report = 'HOF2017'
		SET @qr_code = 'HOF_HOFEvent2017_01_49656'



		 IF(@CAMPAIGN_ID = 34)
	  
		BEGIN
			IF (@winktag_point_status = 'y')
	BEGIN
	SELECT * FROM 
		(--1 START
			SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC) AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at, isnull(T.Q1_1,'') as Q1_1, isnull(T.Q1_2,'') as Q1_2, isnull(T.Q1_3,'') as Q1_3,isnull(T.Q1_4,'') as Q1_4,isnull(T.Q1_5,'') as Q1_5,isnull(T.Q1_6,'') as Q1_6, T.Q2, T.Q3, T.Q4   FROM

			(		
				-----table2
				SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,

				
				(
					SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.1' AND T1.row_count = C.row_count
				) as Q1_1,

				(
					SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.2' AND T1.row_count = C.row_count
				) as Q1_2,

				(
					SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.3' AND T1.row_count = C.row_count
				) as Q1_3,

				(
					SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.4' AND T1.row_count = C.row_count
				) as Q1_4,

				(
					SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.5' AND T1.row_count = C.row_count
				) as Q1_5,

			   (
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.6' AND T1.row_count = C.row_count
				) as Q1_6,


				(
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
				) as Q2,

				 (
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
				) as Q3,(
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
				) as Q4

				FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID 
				-----table2

			) AS T 
			INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

		) AS TEMP----1 END
		WHERE (@email is null or TEMP.email like '%'+@email+'%')
		and (@gender is null or TEMP.gender = @gender)
		and (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
		and (@customer_id is null or TEMP.customer_id = @customer_id)
		and (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
		order by temp.no desc
	END
	ELSE IF(@winktag_point_status = 'n')
	BEGIN
	SELECT * FROM 
		(--1 START
			SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC) AS no, T.*,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age FROM

			(
				-----table1
				SELECT * from
				(
					SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at, '' as Q1_1,'' as Q1_2,'' as Q1_3,'' as Q1_4,'' as Q1_5,'' as Q1_6 ,'' as Q2,'' as Q3,'' as Q4  from winktag_customer_action_log 
					WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
				) as T1
				-----table1

			) AS T 
			INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id

		) AS TEMP----1 END
		WHERE (@email is null or TEMP.email like '%'+@email+'%')
		and (@gender is null or TEMP.gender = @gender)
		and (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
		and (@customer_id is null or TEMP.customer_id = @customer_id)
		and (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
		order by temp.no desc
	END
	ELSE
	BEGIN
	SELECT * FROM 
		(--1 START
			SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at, isnull(T.Q1_1,'') as Q1_1, isnull(T.Q1_2,'') as Q1_2, isnull(T.Q1_3,'') as Q1_3,isnull(T.Q1_4,'') as Q1_4,isnull(T.Q1_5,'') as Q1_5,isnull(T.Q1_6,'') as Q1_6, T.Q2, T.Q3, T.Q4   FROM

			(
				-----table1
				SELECT * from
				(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at, '' as Q1_1,'' as Q1_2,'' as Q1_3,'' as Q1_4,'' as Q1_5,'' as Q1_6 ,'' as Q2,'' as Q3,'' as Q4  from winktag_customer_action_log 
					--SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at,'' as Q1, '' as Q2_1,'' as Q2_2,'' as Q2_3,'' as Q2_4,'' as Q2_5,'' as Q2_6,'' as Q2_7,'' as Q3_1,'' as Q3_2,'' as Q3_3,'' as Q3_4,'' as Q3_5,'' as Q3_6,'' as Q3_7  from winktag_customer_action_log 
					WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
				) as T1
				-----table1

				UNION
	
				-----table2
				SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,

			
				
				(
					SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.1' AND T1.row_count = C.row_count
				) as Q1_1,

				(
					SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.2' AND T1.row_count = C.row_count
				) as Q1_2,

				(
					SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.3' AND T1.row_count = C.row_count
				) as Q1_3,

				(
					SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.4' AND T1.row_count = C.row_count
				) as Q1_4,

				(
					SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.5' AND T1.row_count = C.row_count
				) as Q1_5,

			   (
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.6' AND T1.row_count = C.row_count
				) as Q1_6,


				(
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
				) as Q2,

				 (
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
				) as Q3,(
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
				) as Q4

				FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID 
				-----table2

			) AS T 
			INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

		) AS TEMP----1 END
		WHERE (@email is null or TEMP.email like '%'+@email+'%')
		and (@gender is null or TEMP.gender = @gender)
		AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
		AND (@customer_id is null or TEMP.customer_id = @customer_id)
		AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
		order by temp.no desc
	END
			END

	  ELSE
	  BEGIN


	IF (@winktag_point_status = 'y')
	BEGIN
	SELECT * FROM 
		(--1 START
			SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC) AS no, T.*,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age FROM

			(		
				-----table2
				SELECT C.campaign_id,C.customer_id,E.points,C.GPS_location,C.ip_address,C.created_at,

				(
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
				) as Q1,

				(
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
				) as Q2,

				(
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
				) as Q3,

				(
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
				) as Q4,

				(
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5' AND T1.row_count = C.row_count
				) as Q5

				FROM winktag_customer_earned_points AS C LEFT JOIN customer_earned_points AS E
				ON C.customer_id = E.customer_id
				WHERE C.campaign_id = @CAMPAIGN_ID
				AND E.qr_code = @qr_code 
				-----table2

			) AS T 
			INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

		) AS TEMP----1 END
		WHERE (@email is null or TEMP.email like '%'+@email+'%')
		and (@gender is null or TEMP.gender = @gender)
		and (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
		and (@customer_id is null or TEMP.customer_id = @customer_id)
		and (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
		order by temp.no desc
	END
	ELSE IF(@winktag_point_status = 'n')
	BEGIN
	SELECT * FROM 
		(--1 START
			SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC) AS no, T.*,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age FROM

			(
				-----table1
				SELECT * from
				(
					SELECT A.campaign_id,A.customer_id,E.points,location as GPS_location,A.ip_address,A.created_at,'' as Q1, '' as Q2,'' as Q3 ,'' as Q4 , '' as Q5
					from winktag_customer_action_log AS A
					LEFT JOIN customer_earned_points AS E
					ON A.customer_id = E.customer_id
					inner join (
						select customer_id, max(created_at) as MaxDate
						from winktag_customer_action_log
						group by customer_id
					) temp on A.customer_id = temp.customer_id and A.created_at = temp.MaxDate
					WHERE E.qr_code = @qr_code 
					AND A.campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
				) as T1
				-----table1

			) AS T 
			INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id

		) AS TEMP----1 END
		WHERE (@email is null or TEMP.email like '%'+@email+'%')
		and (@gender is null or TEMP.gender = @gender)
		and (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
		and (@customer_id is null or TEMP.customer_id = @customer_id)
		and (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
		order by temp.no desc
	END
	ELSE
	BEGIN
	SELECT * FROM 
		(--1 START
			SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC) AS no, T.*,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age FROM

			(
				-----table1
				SELECT * from
				(
					SELECT A.campaign_id,A.customer_id,E.points as points,location as GPS_location,A.ip_address,A.created_at,'' as Q1, '' as Q2,'' as Q3 , '' as Q4, '' as Q5
					from winktag_customer_action_log AS A
					LEFT JOIN customer_earned_points AS E
					ON A.customer_id = E.customer_id
					inner join (
						select customer_id, max(created_at) as MaxDate
						from winktag_customer_action_log
						group by customer_id
					) temp on A.customer_id = temp.customer_id and A.created_at = temp.MaxDate
					WHERE E.qr_code = @qr_code 
					AND A.campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
				) as T1
				-----table1

				UNION
	
				-----table2
				SELECT C.campaign_id,C.customer_id,E.points,C.GPS_location,C.ip_address,C.created_at,

				(
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
				) as Q1,

				(
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
				) as Q2,

				(
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
				) as Q3,

				(
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
				) as Q4,

				(
					SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5' AND T1.row_count = C.row_count
				) as Q5

				FROM winktag_customer_earned_points AS C LEFT JOIN customer_earned_points AS E
				ON C.customer_id = E.customer_id
				WHERE C.campaign_id = @CAMPAIGN_ID
				AND E.qr_code = @qr_code 
				-----table2

			) AS T 
			INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

		) AS TEMP----1 END
		WHERE (@email is null or TEMP.email like '%'+@email+'%')
		and (@gender is null or TEMP.gender = @gender)
		AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
		AND (@customer_id is null or TEMP.customer_id = @customer_id)
		AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
		order by temp.no desc
	END
	
	END


END



