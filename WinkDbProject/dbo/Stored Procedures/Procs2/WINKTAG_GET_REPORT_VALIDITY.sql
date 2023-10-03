CREATE PROC [dbo].[WINKTAG_GET_REPORT_VALIDITY]
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
	@validity varchar(10)
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
	
	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
        RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)

    IF(@CAMPAIGN_ID = 210)
        BEGIN
				SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
					T.points,T.created_at,
					T.Q1, T.Q2, isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3, isnull(T.Q4_1,'') as Q4_1, 
                    isnull(T.Q4_2,'') as Q4_2, isnull(T.Q5_1,'') as Q5_1, isnull(T.Q5_2,'') as Q5_2, isnull(T.Q5_3,'') as Q5_3, isnull(T.Q5_4,'') as Q5_4
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1, '' as Q2, '' as Q3_1,'' as Q3_2,'' as Q3_3,'' as Q4_1, '' as Q4_2,'' as Q5_1,'' as Q5_2,'' as Q5_3, '' as Q5_4

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
							AND (@customer_id is null or customer_id = @customer_id)
							AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2,

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
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.1' AND T1.row_count = C.row_count
						) as Q4_1,

                        (
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.2' AND T1.row_count = C.row_count
						) as Q4_2,
                        (
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.1' AND T1.row_count = C.row_count
						) as Q5_1,
                        (
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.2' AND T1.row_count = C.row_count
						) as Q5_2,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.3' AND T1.row_count = C.row_count
						) as Q5_3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.4' AND T1.row_count = C.row_count
						) as Q5_4
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						AND (@customer_id is null or C.customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
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
				AND (@status is null or TEMP.status = @status)
				order by temp.no desc
		END
    ELSE IF(@CAMPAIGN_ID = 208)
        BEGIN
				SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
					T.points,T.created_at,
					T.Q1, T.Q2, isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4, 
					isnull(T.Q3_5,'') as Q3_5, isnull(T.Q3_6,'') as Q3_6, isnull(T.Q3_7,'') as Q3_7,isnull(T.Q4,'') as Q4,isnull(T.Q5,'') as Q5 
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1, '' as Q2, '' as Q3_1,'' as Q3_2,'' as Q3_3,'' as Q3_4, '' as Q3_5,'' as Q3_6,'' as Q3_7,'' as Q4, '' as Q5

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
							AND (@customer_id is null or customer_id = @customer_id)
							AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2,

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
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.6' AND T1.row_count = C.row_count
						) as Q3_6,
                        (
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.7' AND T1.row_count = C.row_count
						) as Q3_7,

						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
						) as Q4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5' AND T1.row_count = C.row_count
						) as Q5
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						AND (@customer_id is null or C.customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
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
				AND (@status is null or TEMP.status = @status)
				order by temp.no desc
		END
	ELSE IF(@CAMPAIGN_ID = 204)
        BEGIN
				SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
					T.points,T.created_at,
					T.Q1, T.Q2, isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4, 
					isnull(T.Q4_1,'') as Q4_1, isnull(T.Q4_2,'') as Q4_2, isnull(T.Q4_3,'') as Q4_3,isnull(T.Q4_4,'') as Q4_4,isnull(T.Q4_5,'') as Q4_5,isnull(T.Q4_6,'') as Q4_6,
					isnull(T.Q5_1,'') as Q5_1, isnull(T.Q5_2,'') as Q5_2, isnull(T.Q5_3,'') as Q5_3,isnull(T.Q5_4,'') as Q5_4,isnull(T.Q5_5,'') as Q5_5 
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1, '' as Q2, '' as Q3_1,'' as Q3_2,'' as Q3_3,'' as Q3_4, '' as Q4_1,'' as Q4_2,'' as Q4_3,'' as Q4_4,'' as Q4_5,'' as Q4_6,'' as Q5_1,'' as Q5_2,'' as Q5_3,'' as Q5_4, '' as Q5_5

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
							AND (@customer_id is null or customer_id = @customer_id)
							AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2,

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
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.1' AND T1.row_count = C.row_count
						) as Q4_1,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.2' AND T1.row_count = C.row_count
						) as Q4_2,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.3' AND T1.row_count = C.row_count
						) as Q4_3,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.4' AND T1.row_count = C.row_count
						) as Q4_4,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.5' AND T1.row_count = C.row_count
						) as Q4_5,
                        (
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.6' AND T1.row_count = C.row_count
						) as Q4_6,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.1' AND T1.row_count = C.row_count
						) as Q5_1,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.2' AND T1.row_count = C.row_count
						) as Q5_2,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.3' AND T1.row_count = C.row_count
						) as Q5_3,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.4' AND T1.row_count = C.row_count
						) as Q5_4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.5' AND T1.row_count = C.row_count
						) as Q5_5
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						AND (@customer_id is null or C.customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
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
				AND (@status is null or TEMP.status = @status)
				order by temp.no desc
		END
	ELSE IF(@CAMPAIGN_ID = 183)
	BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
					T.points,T.created_at,
					T.Q1, T.Q2, T.Q3, T.Q4, T.Q5, T.Q6, T.Q7
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1, '' as Q2, '' as Q3, '' as Q4, '' as Q5, '' as Q6, '' as Q7

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
							AND (@customer_id is null or customer_id = @customer_id)
							AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
						) as Q3,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
						) as Q4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5' AND T1.row_count = C.row_count
						) as Q5,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q6' AND T1.row_count = C.row_count
						) as Q6,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q7' AND T1.row_count = C.row_count
						) as Q7
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						AND (@customer_id is null or C.customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
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
				AND (@status is null or TEMP.status = @status)
			 
				order by temp.no desc
		END
		ELSE IF(@CAMPAIGN_ID = 187)
	    BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
					T.points,T.created_at,
					T.Q1, T.Q2
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1, '' as Q2

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
							AND (@customer_id is null or customer_id = @customer_id)
							AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						AND (@customer_id is null or C.customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
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
				AND (@status is null or TEMP.status = @status)
			 
				order by temp.no desc
		END
		--SMRT35thAnniversaryPhase1,2,3,4,5,6,7--
		ELSE IF(@CAMPAIGN_ID = 189 OR @CAMPAIGN_ID = 191 OR @CAMPAIGN_ID = 194 OR @CAMPAIGN_ID = 198 OR @CAMPAIGN_ID = 199 OR @CAMPAIGN_ID = 200 OR @CAMPAIGN_ID = 201)
	    BEGIN
				SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
					T.points,T.created_at,
					T.Q1, T.Q2, T.Q3, T.Q4, T.Q5
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1, '' as Q2, '' as Q3, '' as Q4, '' as Q5

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
							AND (@customer_id is null or customer_id = @customer_id)
							AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
						) as Q3,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
						) as Q4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5' AND T1.row_count = C.row_count
						) as Q5
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						AND (@customer_id is null or C.customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
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
				AND (@status is null or TEMP.status = @status)
			 
				order by temp.no desc
		END

				--GreenLiving--
		ELSE IF(@CAMPAIGN_ID=197)
	    BEGIN
				SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
					T.points,T.created_at,
					T.Q1, T.Q2, T.Q3, T.Q4
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1, '' as Q2, '' as Q3, '' as Q4

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
							AND (@customer_id is null or customer_id = @customer_id)
							AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
						) as Q3,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
						) as Q4
						
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						AND (@customer_id is null or C.customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
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
				AND (@status is null or TEMP.status = @status)
			 
				order by temp.no desc
			END
        --Wink Hunt Survey P1 Campaign--
        ELSE IF(@CAMPAIGN_ID = 215)
        BEGIN
			   SELECT * FROM 
            (--1 START
            SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
            T.points,T.created_at, T3.promo_code, T3.Q1,
            isnull(T.Q1_1,'') as Q1_1, isnull(T.Q1_2,'') as Q1_2, isnull(T.Q1_3,'') as Q1_3,isnull(T.Q1_4,'') as Q1_4,isnull(T.Q1_5,'') as Q1_5,isnull(T.Q1_6,'') as Q1_6,
            isnull(T.Q2_1,'') as Q2_1, isnull(T.Q2_2,'') as Q2_2, isnull(T.Q2_3,'') as Q2_3,isnull(T.Q2_4,'') as Q2_4,
            isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3,
            isnull(T.Q4_1,'') as Q4_1, isnull(T.Q4_2,'') as Q4_2, isnull(T.Q4_3,'') as Q4_3,isnull(T.Q4_4,'') as Q4_4,isnull(T.Q4_5,'') as Q4_5,isnull(T.Q4_6,'') as Q4_6,
            isnull(T.Q5_1,'') as Q5_1, isnull(T.Q5_2,'') as Q5_2, isnull(T.Q5_3,'') as Q5_3,isnull(T.Q5_4,'') as Q5_4,isnull(T.Q5_5,'') as Q5_5 
                                    
            FROM (
                SELECT * from
                (SELECT campaign_id,customer_id,0 as points,created_at,
                '' as Q1_1, '' as Q1_2, '' as Q1_3, '' as Q1_4, '' as Q1_5, '' as Q1_6,
                '' as Q2_1, '' as Q2_2, '' as Q2_3, '' as Q2_4,
                '' as Q3_1, '' as Q3_2, '' as Q3_3,
                '' as Q4_1,'' as Q4_2,'' as Q4_3,'' as Q4_4,'' as Q4_5,'' as Q4_6,
                '' as Q5_1,'' as Q5_2,'' as Q5_3,'' as Q5_4, '' as Q5_5

                from winktag_customer_action_log
                WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
                AND (@customer_id is null or customer_id = @customer_id)
                AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))

                ) as T1              

                UNION
                ---table2
            SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
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
                    SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.6' AND T1.row_count = C.row_count
                ) as Q1_6,
                (
                    SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.1' AND T1.row_count = C.row_count
                ) as Q2_1,
                (
                    SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.2' AND T1.row_count = C.row_count
                ) as Q2_2,
                (
                    SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.3' AND T1.row_count = C.row_count
                ) as Q2_3,
                (
                    SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.4' AND T1.row_count = C.row_count
                ) as Q2_4,
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
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.1' AND T1.row_count = C.row_count
                ) as Q4_1,

                (
                    SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.2' AND T1.row_count = C.row_count
                ) as Q4_2,

                (
                    SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.3' AND T1.row_count = C.row_count
                ) as Q4_3,

                (
                    SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.4' AND T1.row_count = C.row_count
                ) as Q4_4,
                (
                    SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.5' AND T1.row_count = C.row_count
                ) as Q4_5,
                (
                    SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.6' AND T1.row_count = C.row_count
                ) as Q4_6,

                (
                    SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.1' AND T1.row_count = C.row_count
                ) as Q5_1,

                (
                    SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.2' AND T1.row_count = C.row_count
                ) as Q5_2,

                (
                    SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.3' AND T1.row_count = C.row_count
                ) as Q5_3,

                (
                    SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.4' AND T1.row_count = C.row_count
                ) as Q5_4,
                (
                    SELECT '1' FROM winktag_customer_survey_answer_detail AS T1  
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.5' AND T1.row_count = C.row_count
                ) as Q5_5
                FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
                AND (@customer_id is null or C.customer_id = @customer_id)
                AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
                -----table2

                ) as T
                INNER JOIN CUSTOMER 
                ON T.customer_id = CUSTOMER.customer_id 

                LEFT JOIN ( SELECT CODE.campaign_id, LOG.customer_id, CODE.promo_code as promo_code,
                    (
                        CASE
                            WHEN EXISTS (
                                SELECT 1 FROM TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS L
                                JOIN TBL_WINKPLAY_WINKHUNT_CODES AS C
                                ON L.WP_WH_CODES_ID = C.WP_WH_CODES_ID
                                WHERE C.campaign_id = @CAMPAIGN_ID 
                                AND (@customer_id is null or L.customer_id = @customer_id)
                            ) THEN '1'
                            ELSE ''
                        END
                        ) AS Q1
                        FROM TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS LOG
                        JOIN TBL_WINKPLAY_WINKHUNT_CODES AS CODE
                        ON LOG.WP_WH_CODES_ID = CODE.WP_WH_CODES_ID
                        WHERE CODE.campaign_id = @CAMPAIGN_ID 
                        AND (@customer_id is null or LOG.customer_id = @customer_id)
                        AND (@start_date IS NULL OR CAST(LOG.created_on as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))) as T3
                        ON T.customer_id = T3.customer_id
                        WHERE @validity is null 
                        or (@validity = 'Yes' AND T3.Q1 != '')  
                        or (@validity = '0' AND T3.Q1 = '')
                            ) AS TEMP----1 END
                            
                    WHERE (@email is null or TEMP.email like '%'+@email+'%')
                    and (@gender is null or TEMP.gender = @gender)
                    AND (@wid is null or TEMP.wid like '%'+@wid+'%')
                    AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
                    AND (@status is null or TEMP.status = @status)
                order by temp.no desc
            END
		-- Wink Hunt Survey P2 Campaign--
        ELSE IF(@CAMPAIGN_ID=218)
	    BEGIN
			SELECT * FROM 
            (--1 START
            SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
            T.points,T.created_at, T3.promo_code,-- T3.Q1,
            isnull(T.Q1,'') as Q1, isnull(T.Q2,'') as Q2, isnull(T.Q3,'') as Q3,isnull(T.Q4,'') as Q4,isnull(T.Q5,'') as Q5,isnull(T.Q6,'') as Q6,
            isnull(T.Q7,'') as Q7, isnull(T.Q8,'') as Q8
                                    
            FROM (
                SELECT * from
                (SELECT campaign_id,customer_id,0 as points,created_at,
                '' as Q1, '' as Q2, '' as Q3, '' as Q4, '' as Q5, '' as Q6,
                '' as Q7, '' as Q8

                from winktag_customer_action_log
                WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
                AND (@customer_id is null or customer_id = @customer_id)
                AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))

                ) as T1

                UNION
                ---table2
                SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
                (
                    SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
                ) as Q1,
                (
                    SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
                ) as Q2,
                (
                    SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
                ) as Q3,
                (
                    SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
                ) as Q4,
                (
                    SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5' AND T1.row_count = C.row_count
                ) as Q5,
                (
                    SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q6' AND T1.row_count = C.row_count
                ) as Q6,
                (
                    SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q7' AND T1.row_count = C.row_count
                ) as Q7,
                (
                    SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
                    WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q8' AND T1.row_count = C.row_count
                ) as Q8
                
                FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
                AND (@customer_id is null or C.customer_id = @customer_id)
                AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
                -----table2

                ) as T
                INNER JOIN CUSTOMER 
                ON T.customer_id = CUSTOMER.customer_id 

                LEFT JOIN ( SELECT CODE.campaign_id, LOG.customer_id, CODE.promo_code as promo_code,
                    (
                        CASE
                            WHEN EXISTS (
                                SELECT 1 FROM TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS L
                                JOIN TBL_WINKPLAY_WINKHUNT_CODES AS C
                                ON L.WP_WH_CODES_ID = C.WP_WH_CODES_ID
                                WHERE C.campaign_id = @CAMPAIGN_ID 
                                AND (@customer_id is null or L.customer_id = @customer_id)
                            ) THEN '1'
                            ELSE ''
                        END
                        ) AS Q1
                        FROM TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS LOG
                        JOIN TBL_WINKPLAY_WINKHUNT_CODES AS CODE
                        ON LOG.WP_WH_CODES_ID = CODE.WP_WH_CODES_ID
                        WHERE CODE.campaign_id = @CAMPAIGN_ID 
                        AND (@customer_id is null or LOG.customer_id = @customer_id)
                        AND (@start_date IS NULL OR CAST(LOG.created_on as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))) as T3
                        ON T.customer_id = T3.customer_id
                        WHERE @validity is null 
                        or (@validity = 'Yes' AND T3.Q1 != '')  
                        or (@validity = '0' AND T3.Q1 = '')
                       ) AS TEMP----1 END
                            
                    WHERE (@email is null or TEMP.email like '%'+@email+'%')
                    and (@gender is null or TEMP.gender = @gender)
                    AND (@wid is null or TEMP.wid like '%'+@wid+'%')
                    AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
                    AND (@status is null or TEMP.status = @status)
                order by temp.no desc
			END
		
		--WinkHuntRewardCards--
		ELSE IF(@CAMPAIGN_ID=217)
	    BEGIN
				SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
					T.points,T.created_at,T.Q1 as promo_code,
					T.Q1
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
							AND (@customer_id is null or customer_id = @customer_id)
							AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1
						
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						AND (@customer_id is null or C.customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
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
				AND (@status is null or TEMP.status = @status)
			 
				order by temp.no desc
			END
	ELSE IF(@CAMPAIGN_ID = 182)
	BEGIN
		SELECT * FROM 
			(--1 START
				SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
				T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
				isnull(T.Q1_1,'') as Q1_1, isnull(T.Q1_2,'') as Q1_2, isnull(T.Q1_3,'') as Q1_3,isnull(T.Q1_4,'') as Q1_4,
				isnull(T.Q2_1,'') as Q2_1, isnull(T.Q2_2,'') as Q2_2, isnull(T.Q2_3,'') as Q2_3,isnull(T.Q2_4,'') as Q2_4,
				isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4,isnull(T.Q3_5,'') as Q3_5,
				isnull(T.Q4_1,'') as Q4_1, isnull(T.Q4_2,'') as Q4_2, isnull(T.Q4_3,'') as Q4_3,isnull(T.Q4_4,'') as Q4_4,isnull(T.Q4_5,'') as Q4_5,
				isnull(T.Q5_1,'') as Q5_1, isnull(T.Q5_2,'') as Q5_2, isnull(T.Q5_3,'') as Q5_3,isnull(T.Q5_4,'') as Q5_4

					
				FROM

				(
					-----table1
					SELECT * from
					(SELECT customer_id,0 as points,location as GPS_location,ip_address,created_at, 
					'' as Q1_1, '' as Q1_2,'' as Q1_3,'' as Q1_4,
					'' as Q2_1, '' as Q2_2,'' as Q2_3,'' as Q2_4,
					'' as Q3_1, '' as Q3_2,'' as Q3_3,'' as Q3_4,'' as Q3_5,
					'' as Q4_1, '' as Q4_2,'' as Q4_3,'' as Q4_4,'' as Q4_5,
					'' as Q5_1, '' as Q5_2,'' as Q5_3,'' as Q5_4

					from winktag_customer_action_log 
						WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						AND (@customer_id is null or customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
					) as T1
					-----table1

					UNION
	
					-----table2
					SELECT C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
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
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.1' AND T1.row_count = C.row_count
					) as Q2_1,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.2' AND T1.row_count = C.row_count
					) as Q2_2,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.3' AND T1.row_count = C.row_count
					) as Q2_3,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.4' AND T1.row_count = C.row_count
					) as Q2_4,
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
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.1' AND T1.row_count = C.row_count
					) as Q4_1,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.2' AND T1.row_count = C.row_count
					) as Q4_2,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.3' AND T1.row_count = C.row_count
					) as Q4_3,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.4' AND T1.row_count = C.row_count
					) as Q4_4,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.5' AND T1.row_count = C.row_count
					) as Q4_5,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.1' AND T1.row_count = C.row_count
					) as Q5_1,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.2' AND T1.row_count = C.row_count
					) as Q5_2,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.3' AND T1.row_count = C.row_count
					) as Q5_3,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.4' AND T1.row_count = C.row_count
					) as Q5_4
					FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
					AND (@customer_id is null or C.customer_id = @customer_id)
					AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
					-----table2

				) AS T 
				INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
				WHERE @validity is null 
						or (@validity = 'Yes' AND (T.Q1_1 != '' or T.Q1_2 != '' or T.Q1_3 != '' or T.Q1_4 != '') )  
						or (@validity = '0' AND (T.Q1_1 != '' or T.Q1_2 != '' or T.Q1_3 != '' or T.Q1_4 != ''))
						
			) AS TEMP----1 END
			WHERE (@email is null or TEMP.email like '%'+@email+'%')
			and (@gender is null or TEMP.gender = @gender)
			AND (@wid is null or TEMP.wid like '%'+@wid+'%')
			AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
			AND (@status is null or TEMP.[status] = @status)
			 
			order by temp.no desc
	END
	ELSE IF(@CAMPAIGN_ID = 181)
	BEGIN
		SELECT * FROM 
			(--1 START
				SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
				T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
				isnull(T.Q1_1,'') as Q1_1, isnull(T.Q1_2,'') as Q1_2, isnull(T.Q1_3,'') as Q1_3,isnull(T.Q1_4,'') as Q1_4,
				isnull(T.Q2_1,'') as Q2_1, isnull(T.Q2_2,'') as Q2_2, isnull(T.Q2_3,'') as Q2_3,isnull(T.Q2_4,'') as Q2_4,
				isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4,isnull(T.Q3_5,'') as Q3_5,isnull(T.Q3_6,'') as Q3_6,isnull(T.Q3_7,'') as Q3_7,
				isnull(T.Q4_1,'') as Q4_1, isnull(T.Q4_2,'') as Q4_2, isnull(T.Q4_3,'') as Q4_3,isnull(T.Q4_4,'') as Q4_4,isnull(T.Q4_5,'') as Q4_5,isnull(T.Q4_6,'') as Q4_6,
				isnull(T.Q5_1,'') as Q5_1, isnull(T.Q5_2,'') as Q5_2, isnull(T.Q5_3,'') as Q5_3,isnull(T.Q5_4,'') as Q5_4

					
				FROM

				(
					-----table1
					SELECT * from
					(SELECT customer_id,0 as points,location as GPS_location,ip_address,created_at, 
					'' as Q1_1, '' as Q1_2,'' as Q1_3,'' as Q1_4,
					'' as Q2_1, '' as Q2_2,'' as Q2_3,'' as Q2_4,
					'' as Q3_1, '' as Q3_2,'' as Q3_3,'' as Q3_4,'' as Q3_5,'' as Q3_6,'' as Q3_7,
					'' as Q4_1, '' as Q4_2,'' as Q4_3,'' as Q4_4,'' as Q4_5,'' as Q4_6,
					'' as Q5_1, '' as Q5_2,'' as Q5_3,'' as Q5_4

					from winktag_customer_action_log 
						WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						AND (@customer_id is null or customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
					) as T1
					-----table1

					UNION
	
					-----table2
					SELECT C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
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
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.1' AND T1.row_count = C.row_count
					) as Q2_1,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.2' AND T1.row_count = C.row_count
					) as Q2_2,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.3' AND T1.row_count = C.row_count
					) as Q2_3,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.4' AND T1.row_count = C.row_count
					) as Q2_4,
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
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.6' AND T1.row_count = C.row_count
					) as Q3_6,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.7' AND T1.row_count = C.row_count
					) as Q3_7,

					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.1' AND T1.row_count = C.row_count
					) as Q4_1,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.2' AND T1.row_count = C.row_count
					) as Q4_2,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.3' AND T1.row_count = C.row_count
					) as Q4_3,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.4' AND T1.row_count = C.row_count
					) as Q4_4,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.5' AND T1.row_count = C.row_count
					) as Q4_5,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.6' AND T1.row_count = C.row_count
					) as Q4_6,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.1' AND T1.row_count = C.row_count
					) as Q5_1,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.2' AND T1.row_count = C.row_count
					) as Q5_2,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.3' AND T1.row_count = C.row_count
					) as Q5_3,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.4' AND T1.row_count = C.row_count
					) as Q5_4
					FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
					AND (@customer_id is null or C.customer_id = @customer_id)
					AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
					-----table2

				) AS T 
				INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
				WHERE @validity is null 
						or (@validity = 'Yes' AND (T.Q1_1 != '' or T.Q1_2 != '' or T.Q1_3 != '' or T.Q1_4 != '') )  
						or (@validity = '0' AND (T.Q1_1 != '' or T.Q1_2 != '' or T.Q1_3 != '' or T.Q1_4 != ''))
						
			) AS TEMP----1 END
			WHERE (@email is null or TEMP.email like '%'+@email+'%')
			and (@gender is null or TEMP.gender = @gender)
			AND (@wid is null or TEMP.wid like '%'+@wid+'%')
			AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
			AND (@status is null or TEMP.[status] = @status)
			 
			order by temp.no desc
	END
	ELSE IF(@CAMPAIGN_ID = 180)
	BEGIN
		SELECT * FROM 
			(--1 START
				SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
				T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
				isnull(T.Q1_1,'') as Q1_1, isnull(T.Q1_2,'') as Q1_2, isnull(T.Q1_3,'') as Q1_3,isnull(T.Q1_4,'') as Q1_4,
				isnull(T.Q2_1,'') as Q2_1, isnull(T.Q2_2,'') as Q2_2, isnull(T.Q2_3,'') as Q2_3,isnull(T.Q2_4,'') as Q2_4,isnull(T.Q2_5,'') as Q2_5,
				isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4,
				isnull(T.Q4_1,'') as Q4_1, isnull(T.Q4_2,'') as Q4_2, isnull(T.Q4_3,'') as Q4_3,isnull(T.Q4_4,'') as Q4_4,isnull(T.Q4_5,'') as Q4_5,
				isnull(T.Q5_1,'') as Q5_1, isnull(T.Q5_2,'') as Q5_2, isnull(T.Q5_3,'') as Q5_3,isnull(T.Q5_4,'') as Q5_4

					
				FROM

				(
					-----table1
					SELECT * from
					(SELECT customer_id,0 as points,location as GPS_location,ip_address,created_at, 
					'' as Q1_1, '' as Q1_2,'' as Q1_3,'' as Q1_4,
					'' as Q2_1, '' as Q2_2,'' as Q2_3,'' as Q2_4,'' as Q2_5,
					'' as Q3_1, '' as Q3_2,'' as Q3_3,'' as Q3_4,
					'' as Q4_1, '' as Q4_2,'' as Q4_3,'' as Q4_4,'' as Q4_5,
					'' as Q5_1, '' as Q5_2,'' as Q5_3,'' as Q5_4

					from winktag_customer_action_log 
						WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						AND (@customer_id is null or customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
					) as T1
					-----table1

					UNION
	
					-----table2
					SELECT C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
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
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.1' AND T1.row_count = C.row_count
					) as Q2_1,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.2' AND T1.row_count = C.row_count
					) as Q2_2,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.3' AND T1.row_count = C.row_count
					) as Q2_3,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.4' AND T1.row_count = C.row_count
					) as Q2_4,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.5' AND T1.row_count = C.row_count
					) as Q2_5,
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
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.1' AND T1.row_count = C.row_count
					) as Q4_1,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.2' AND T1.row_count = C.row_count
					) as Q4_2,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.3' AND T1.row_count = C.row_count
					) as Q4_3,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.4' AND T1.row_count = C.row_count
					) as Q4_4,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.5' AND T1.row_count = C.row_count
					) as Q4_5,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.1' AND T1.row_count = C.row_count
					) as Q5_1,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.2' AND T1.row_count = C.row_count
					) as Q5_2,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.3' AND T1.row_count = C.row_count
					) as Q5_3,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.4' AND T1.row_count = C.row_count
					) as Q5_4
					FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
					AND (@customer_id is null or C.customer_id = @customer_id)
					AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
					-----table2

				) AS T 
				INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
				WHERE @validity is null 
						or (@validity = 'Yes' AND (T.Q1_1 != '' or T.Q1_2 != '' or T.Q1_3 != '' or T.Q1_4 != '') )  
						or (@validity = '0' AND (T.Q1_1 != '' or T.Q1_2 != '' or T.Q1_3 != '' or T.Q1_4 != ''))
						
			) AS TEMP----1 END
			WHERE (@email is null or TEMP.email like '%'+@email+'%')
			and (@gender is null or TEMP.gender = @gender)
			AND (@wid is null or TEMP.wid like '%'+@wid+'%')
			AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
			AND (@status is null or TEMP.[status] = @status)
			 
			order by temp.no desc
	END
	ELSE IF(@CAMPAIGN_ID = 179)
	BEGIN
		SELECT * FROM 
			(--1 START
				SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
				T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
				isnull(T.Q1_1,'') as Q1_1, isnull(T.Q1_2,'') as Q1_2, isnull(T.Q1_3,'') as Q1_3,isnull(T.Q1_4,'') as Q1_4,
				isnull(T.Q2_1,'') as Q2_1, isnull(T.Q2_2,'') as Q2_2, isnull(T.Q2_3,'') as Q2_3,isnull(T.Q2_4,'') as Q2_4,
				isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4,
				isnull(T.Q4_1,'') as Q4_1, isnull(T.Q4_2,'') as Q4_2, isnull(T.Q4_3,'') as Q4_3,isnull(T.Q4_4,'') as Q4_4,
				isnull(T.Q5_1,'') as Q5_1, isnull(T.Q5_2,'') as Q5_2, isnull(T.Q5_3,'') as Q5_3,isnull(T.Q5_4,'') as Q5_4,isnull(T.Q5_5,'') as Q5_5, isnull(T.Q5_6,'') as Q5_6, isnull(T.Q5_7,'') as Q5_7

					
				FROM

				(
					-----table1
					SELECT * from
					(SELECT customer_id,0 as points,location as GPS_location,ip_address,created_at, 
					'' as Q1_1, '' as Q1_2,'' as Q1_3,'' as Q1_4,
					'' as Q2_1, '' as Q2_2,'' as Q2_3,'' as Q2_4,
					'' as Q3_1, '' as Q3_2,'' as Q3_3,'' as Q3_4,
					'' as Q4_1, '' as Q4_2,'' as Q4_3,'' as Q4_4,
					'' as Q5_1, '' as Q5_2,'' as Q5_3,'' as Q5_4,'' as Q5_5, '' as Q5_6,'' as Q5_7

					from winktag_customer_action_log 
						WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						AND (@customer_id is null or customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
					) as T1
					-----table1

					UNION
	
					-----table2
					SELECT C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
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
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.1' AND T1.row_count = C.row_count
					) as Q2_1,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.2' AND T1.row_count = C.row_count
					) as Q2_2,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.3' AND T1.row_count = C.row_count
					) as Q2_3,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.4' AND T1.row_count = C.row_count
					) as Q2_4,

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
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.1' AND T1.row_count = C.row_count
					) as Q4_1,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.2' AND T1.row_count = C.row_count
					) as Q4_2,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.3' AND T1.row_count = C.row_count
					) as Q4_3,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.4' AND T1.row_count = C.row_count
					) as Q4_4,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.1' AND T1.row_count = C.row_count
					) as Q5_1,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.2' AND T1.row_count = C.row_count
					) as Q5_2,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.3' AND T1.row_count = C.row_count
					) as Q5_3,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.4' AND T1.row_count = C.row_count
					) as Q5_4,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.5' AND T1.row_count = C.row_count
					) as Q5_5,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.6' AND T1.row_count = C.row_count
					) as Q5_6,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.7' AND T1.row_count = C.row_count
					) as Q5_7
					FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
					AND (@customer_id is null or C.customer_id = @customer_id)
					AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
					-----table2

				) AS T 
				INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
				WHERE @validity is null 
						or (@validity = 'Yes' AND (T.Q1_1 != '' or T.Q1_2 != '' or T.Q1_3 != '' or T.Q1_4 != '') )  
						or (@validity = '0' AND (T.Q1_1 != '' or T.Q1_2 != '' or T.Q1_3 != '' or T.Q1_4 != ''))
						
			) AS TEMP----1 END
			WHERE (@email is null or TEMP.email like '%'+@email+'%')
			and (@gender is null or TEMP.gender = @gender)
			AND (@wid is null or TEMP.wid like '%'+@wid+'%')
			AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
			AND (@status is null or TEMP.[status] = @status)
			 
			order by temp.no desc
	END
	ELSE IF(@CAMPAIGN_ID = 178)
	BEGIN
		SELECT * FROM 
			(--1 START
				SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
				T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
				isnull(T.Q1_1,'') as Q1_1, isnull(T.Q1_2,'') as Q1_2, isnull(T.Q1_3,'') as Q1_3,isnull(T.Q1_4,'') as Q1_4,
				isnull(T.Q2_1,'') as Q2_1, isnull(T.Q2_2,'') as Q2_2, isnull(T.Q2_3,'') as Q2_3,isnull(T.Q2_4,'') as Q2_4,
				isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4,
				isnull(T.Q4_1,'') as Q4_1, isnull(T.Q4_2,'') as Q4_2, isnull(T.Q4_3,'') as Q4_3,isnull(T.Q4_4,'') as Q4_4,
				isnull(T.Q5_1,'') as Q5_1, isnull(T.Q5_2,'') as Q5_2, isnull(T.Q5_3,'') as Q5_3,isnull(T.Q5_4,'') as Q5_4

					
				FROM

				(
					-----table1
					SELECT * from
					(SELECT customer_id,0 as points,location as GPS_location,ip_address,created_at, 
					'' as Q1_1, '' as Q1_2,'' as Q1_3,'' as Q1_4,
					'' as Q2_1, '' as Q2_2,'' as Q2_3,'' as Q2_4,
					'' as Q3_1, '' as Q3_2,'' as Q3_3,'' as Q3_4,
					'' as Q4_1, '' as Q4_2,'' as Q4_3,'' as Q4_4,
					'' as Q5_1, '' as Q5_2,'' as Q5_3,'' as Q5_4

					from winktag_customer_action_log 
						WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						AND (@customer_id is null or customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
					) as T1
					-----table1

					UNION
	
					-----table2
					SELECT C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
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
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.1' AND T1.row_count = C.row_count
					) as Q2_1,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.2' AND T1.row_count = C.row_count
					) as Q2_2,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.3' AND T1.row_count = C.row_count
					) as Q2_3,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.4' AND T1.row_count = C.row_count
					) as Q2_4,

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
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.1' AND T1.row_count = C.row_count
					) as Q4_1,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.2' AND T1.row_count = C.row_count
					) as Q4_2,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.3' AND T1.row_count = C.row_count
					) as Q4_3,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.4' AND T1.row_count = C.row_count
					) as Q4_4,

					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.1' AND T1.row_count = C.row_count
					) as Q5_1,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.2' AND T1.row_count = C.row_count
					) as Q5_2,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.3' AND T1.row_count = C.row_count
					) as Q5_3,
					(
						SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.4' AND T1.row_count = C.row_count
					) as Q5_4
					FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
					AND (@customer_id is null or C.customer_id = @customer_id)
					AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
					-----table2

				) AS T 
				INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
				WHERE @validity is null 
						or (@validity = 'Yes' AND (T.Q1_1 != '' or T.Q1_2 != '' or T.Q1_3 != '' or T.Q1_4 != '') )  
						or (@validity = '0' AND (T.Q1_1 != '' or T.Q1_2 != '' or T.Q1_3 != '' or T.Q1_4 != ''))
						
			) AS TEMP----1 END
			WHERE (@email is null or TEMP.email like '%'+@email+'%')
			and (@gender is null or TEMP.gender = @gender)
			AND (@wid is null or TEMP.wid like '%'+@wid+'%')
			AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
			AND (@status is null or TEMP.[status] = @status)
			 
			order by temp.no desc
	END
	ELSE IF(@CAMPAIGN_ID = 176)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.created_at,
					T.Q1, T.Q2, T.Q3, T.Q4, T.Q5, T.Q6, T.Q7, T.Q8, T.Q9, T.Q10, T.Q11, T.Q12, T.Q13, T.Q14, T.Q15, T.Q16, T.Q17, T.Q18_1, T.Q18_2, T.Q18_3, T.Q18_4, T.Q18_5
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1, '' as Q2, '' as Q3, '' as Q4, '' as Q5, '' as Q6, '' as Q7, '' as Q8, '' as Q9, '' as Q10
						, '' as Q11, '' as Q12, '' as Q13, '' as Q14, '' as Q15, '' as Q16, '' as Q17, '' as Q18_1, '' as Q18_2, '' as Q18_3, '' as Q18_4, '' as Q18_5

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
						) as Q3,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
						) as Q4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5' AND T1.row_count = C.row_count
						) as Q5,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q6' AND T1.row_count = C.row_count
						) as Q6,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q7' AND T1.row_count = C.row_count
						) as Q7,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q8' AND T1.row_count = C.row_count
						) as Q8,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q9' AND T1.row_count = C.row_count
						) as Q9,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q10' AND T1.row_count = C.row_count
						) as Q10,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q11' AND T1.row_count = C.row_count
						) as Q11,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q12' AND T1.row_count = C.row_count
						) as Q12,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q13' AND T1.row_count = C.row_count
						) as Q13,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q14' AND T1.row_count = C.row_count
						) as Q14,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q15' AND T1.row_count = C.row_count
						) as Q15,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q16' AND T1.row_count = C.row_count
						) as Q16,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q17' AND T1.row_count = C.row_count
						) as Q17,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q18.1' AND T1.row_count = C.row_count
						) as Q18_1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q18.2' AND T1.row_count = C.row_count
						) as Q18_2,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q18.3' AND T1.row_count = C.row_count
						) as Q18_3,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q18.4' AND T1.row_count = C.row_count
						) as Q18_4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q18.5' AND T1.row_count = C.row_count
						) as Q18_5

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
		ELSE IF(@CAMPAIGN_ID = 193)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.created_at,
					T.Q1, T.Q2, T.Q3, T.Q4, T.Q5, T.Q6, T.Q7, T.Q8, T.Q9, T.Q10, T.Q11, T.Q12_1, T.Q12_2, T.Q12_3, T.Q12_4, T.Q12_5, T.Q12_6
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1, '' as Q2, '' as Q3, '' as Q4, '' as Q5, '' as Q6, '' as Q7, '' as Q8, '' as Q9, '' as Q10
						, '' as Q11, '' as Q12_1, '' as Q12_2, '' as Q12_3, '' as Q12_4, '' as Q12_5, '' as Q12_6

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
						) as Q3,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
						) as Q4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5' AND T1.row_count = C.row_count
						) as Q5,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q6' AND T1.row_count = C.row_count
						) as Q6,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q7' AND T1.row_count = C.row_count
						) as Q7,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q8' AND T1.row_count = C.row_count
						) as Q8,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q9' AND T1.row_count = C.row_count
						) as Q9,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q10' AND T1.row_count = C.row_count
						) as Q10,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q11' AND T1.row_count = C.row_count
						) as Q11,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q12.1' AND T1.row_count = C.row_count
						) as Q12_1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q12.2' AND T1.row_count = C.row_count
						) as Q12_2,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q12.3' AND T1.row_count = C.row_count
						) as Q12_3,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q12.4' AND T1.row_count = C.row_count
						) as Q12_4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q12.5' AND T1.row_count = C.row_count
						) as Q12_5,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q12.6' AND T1.row_count = C.row_count
						) as Q12_6

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
	ELSE IF(@CAMPAIGN_ID = 158)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.created_at,
					T.Q1, T.Q2, T.Q3, T.Q4, T.Q5, T.Q6, T.Q7, T.Q8, T.Q9, T.Q10, T.Q11, T.Q12, T.Q13, T.Q14, T.Q15, T.Q16, T.Q17, T.Q18, T.Q19_1, T.Q19_2, T.Q19_3, T.Q19_4
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1, '' as Q2, '' as Q3, '' as Q4, '' as Q5, '' as Q6, '' as Q7, '' as Q8, '' as Q9, '' as Q10
						, '' as Q11, '' as Q12, '' as Q13, '' as Q14, '' as Q15, '' as Q16, '' as Q17, '' as Q18, '' as Q19_1, '' as Q19_2, '' as Q19_3, '' as Q19_4

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
						) as Q3,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
						) as Q4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5' AND T1.row_count = C.row_count
						) as Q5,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q6' AND T1.row_count = C.row_count
						) as Q6,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q7' AND T1.row_count = C.row_count
						) as Q7,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q8' AND T1.row_count = C.row_count
						) as Q8,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q9' AND T1.row_count = C.row_count
						) as Q9,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q10' AND T1.row_count = C.row_count
						) as Q10,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q11' AND T1.row_count = C.row_count
						) as Q11,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q12' AND T1.row_count = C.row_count
						) as Q12,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q13' AND T1.row_count = C.row_count
						) as Q13,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q14' AND T1.row_count = C.row_count
						) as Q14,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q15' AND T1.row_count = C.row_count
						) as Q15,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q16' AND T1.row_count = C.row_count
						) as Q16,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q17' AND T1.row_count = C.row_count
						) as Q17,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q18' AND T1.row_count = C.row_count
						) as Q18,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q19.1' AND T1.row_count = C.row_count
						) as Q19_1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q19.2' AND T1.row_count = C.row_count
						) as Q19_2,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q19.3' AND T1.row_count = C.row_count
						) as Q19_3,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q19.4' AND T1.row_count = C.row_count
						) as Q19_4

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
	ELSE IF(@CAMPAIGN_ID = 184 or @CAMPAIGN_ID = 173 or @CAMPAIGN_ID = 156 or @CAMPAIGN_ID = 148 or @CAMPAIGN_ID=167)
		BEGIN
			SELECT TEMP.[no],TEMP.gender,TEMP.age,TEMP.wid, TEMP.[status], TEMP.points, TEMP.created_at, TEMP.Q1 FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.customer_id,T.points,T.created_at,
					T.Q1
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
							AND (@customer_id is null or customer_id = @customer_id)
							AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						AND (@customer_id is null or C.customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
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
				AND (@status is null or TEMP.[status] = @status)
			 
				order by temp.no desc
		END
	ELSE IF(@CAMPAIGN_ID = 144)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.created_at,
					T.Q1, T.Q2, T.Q3, T.Q4, T.Q5, T.Q6, T.Q7, T.Q8, T.Q9, T.Q10, T.Q11, T.Q12, T.Q13, T.Q14, T.Q15, T.Q16
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1, '' as Q2, '' as Q3, '' as Q4, '' as Q5, '' as Q6, '' as Q7, '' as Q8, '' as Q9, '' as Q10
						, '' as Q11, '' as Q12, '' as Q13, '' as Q14, '' as Q15, '' as Q16

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
						) as Q3,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
						) as Q4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5' AND T1.row_count = C.row_count
						) as Q5,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q6' AND T1.row_count = C.row_count
						) as Q6,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q7' AND T1.row_count = C.row_count
						) as Q7,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q8' AND T1.row_count = C.row_count
						) as Q8,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q9' AND T1.row_count = C.row_count
						) as Q9,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q10' AND T1.row_count = C.row_count
						) as Q10,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q11' AND T1.row_count = C.row_count
						) as Q11,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q12' AND T1.row_count = C.row_count
						) as Q12,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q13' AND T1.row_count = C.row_count
						) as Q13,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q14' AND T1.row_count = C.row_count
						) as Q14,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q15' AND T1.row_count = C.row_count
						) as Q15,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q16' AND T1.row_count = C.row_count
						) as Q16
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
	ELSE IF(@CAMPAIGN_ID = 139)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.created_at,
					isnull(T.Q1_1,'') as Q1_1, isnull(T.Q1_2,'') as Q1_2, isnull(T.Q1_3,'') as Q1_3,isnull(T.Q1_4,'') as Q1_4, isnull(T.Q1_5,'') as Q1_5,
					isnull(T.Q1_6,'') as Q1_6,
					T.Q2,
					isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4,isnull(T.Q3_5,'') as Q3_5,isnull(T.Q3_6,'') as Q3_6
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1_1, '' as Q1_2,'' as Q1_3,'' as Q1_4,'' as Q1_5,'' as Q1_6,
						'' as Q2,
						'' as Q3_1, '' as Q3_2,'' as Q3_3,'' as Q3_4,'' as Q3_5,'' as Q3_6

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
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
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.5' AND T1.row_count = C.row_count
						) as Q1_5,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.6' AND T1.row_count = C.row_count
						) as Q1_6,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2,
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
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.6' AND T1.row_count = C.row_count
						) as Q3_6
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
	ELSE IF(@CAMPAIGN_ID = 129)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
					T.Q1,
					isnull(T.Q2_1,'') as Q2_1, isnull(T.Q2_2,'') as Q2_2, isnull(T.Q2_3,'') as Q2_3,isnull(T.Q2_4,'') as Q2_4,isnull(T.Q2_5,'') as Q2_5,
					isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4,isnull(T.Q3_5,'') as Q3_5,isnull(T.Q3_6,'') as Q3_6
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT customer_id,0 as points,location as GPS_location,ip_address,created_at, 
						'' as Q1, 
						'' as Q2_1, '' as Q2_2,'' as Q2_3,'' as Q2_4,'' as Q2_5,
						'' as Q3_1, '' as Q3_2,'' as Q3_3,'' as Q3_4,'' as Q3_5,'' as Q3_6

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
						) as Q1,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.1' AND T1.row_count = C.row_count
						) as Q2_1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.2' AND T1.row_count = C.row_count
						) as Q2_2,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.3' AND T1.row_count = C.row_count
						) as Q2_3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.4' AND T1.row_count = C.row_count
						) as Q2_4,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.5' AND T1.row_count = C.row_count
						) as Q2_5,

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
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.6' AND T1.row_count = C.row_count
						) as Q3_6
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
	ELSE IF(@CAMPAIGN_ID = 113)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.created_at,
					T.Q1,
					isnull(T.Q2_1,'') as Q2_1, isnull(T.Q2_2,'') as Q2_2, isnull(T.Q2_3,'') as Q2_3,isnull(T.Q2_4,'') as Q2_4, isnull(T.Q2_5,'') as Q2_5,
					isnull(T.Q2_6,'') as Q2_6,
					T.Q3,
					isnull(T.Q4_1,'') as Q4_1, isnull(T.Q4_2,'') as Q4_2, isnull(T.Q4_3,'') as Q4_3,isnull(T.Q4_4,'') as Q4_4, isnull(T.Q4_5,'') as Q4_5,
					isnull(T.Q5_1,'') as Q5_1, isnull(T.Q5_2,'') as Q5_2, isnull(T.Q5_3,'') as Q5_3,isnull(T.Q5_4,'') as Q5_4, isnull(T.Q5_5,'') as Q5_5,
					isnull(T.Q5_6,'') as Q5_6
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, '' as Q1, 
						'' as Q2_1, '' as Q2_2,'' as Q2_3,'' as Q2_4,'' as Q2_5,'' as Q2_6,
						'' as Q3,
						'' as Q4_1, '' as Q4_2,'' as Q4_3,'' as Q4_4,'' as Q4_5,
						'' as Q5_1, '' as Q5_2,'' as Q5_3,'' as Q5_4,'' as Q5_5,'' as Q5_6

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.1' AND T1.row_count = C.row_count
						) as Q2_1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.2' AND T1.row_count = C.row_count
						) as Q2_2,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.3' AND T1.row_count = C.row_count
						) as Q2_3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.4' AND T1.row_count = C.row_count
						) as Q2_4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.5' AND T1.row_count = C.row_count
						) as Q2_5,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.6' AND T1.row_count = C.row_count
						) as Q2_6,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
						) as Q3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.1' AND T1.row_count = C.row_count
						) as Q4_1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.2' AND T1.row_count = C.row_count
						) as Q4_2,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.3' AND T1.row_count = C.row_count
						) as Q4_3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.4' AND T1.row_count = C.row_count
						) as Q4_4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.5' AND T1.row_count = C.row_count
						) as Q4_5,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.1' AND T1.row_count = C.row_count
						) as Q5_1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.2' AND T1.row_count = C.row_count
						) as Q5_2,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.3' AND T1.row_count = C.row_count
						) as Q5_3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.4' AND T1.row_count = C.row_count
						) as Q5_4,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.5' AND T1.row_count = C.row_count
						) as Q5_5,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5.6' AND T1.row_count = C.row_count
						) as Q5_6
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
	ELSE IF(@CAMPAIGN_ID = 114)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.created_at,
					isnull(T.Q1_1,'') as Q1_1, isnull(T.Q1_2,'') as Q1_2, isnull(T.Q1_3,'') as Q1_3,isnull(T.Q1_4,'') as Q1_4, isnull(T.Q1_5,'') as Q1_5,
					isnull(T.Q1_6,'') as Q1_6,isnull(T.Q1_7,'') as Q1_7,
					T.Q2,
					T.Q3
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1_1, '' as Q1_2,'' as Q1_3,'' as Q1_4,'' as Q1_5,'' as Q1_6,'' as Q1_7,
						'' as Q2,
						'' as Q3

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
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
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.6' AND T1.row_count = C.row_count
						) as Q1_6,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.7' AND T1.row_count = C.row_count
						) as Q1_7,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
						) as Q3
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
	ELSE IF(@CAMPAIGN_ID = 115)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.created_at,
					T.Q1, T.Q2,
					isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4,isnull(T.Q3_5,'') as Q3_5,isnull(T.Q3_6,'') as Q3_6,isnull(T.Q3_7,'') as Q3_7
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, '' as Q1, 
						'' as Q2,
						'' as Q3_1, '' as Q3_2,'' as Q3_3,'' as Q3_4,'' as Q3_5,'' as Q3_6,'' as Q3_7

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2,
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
	ELSE IF(@CAMPAIGN_ID = 117)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.created_at,
					T.Q1, T.Q2,
					isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4,isnull(T.Q3_5,'') as Q3_5,isnull(T.Q3_6,'') as Q3_6
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, '' as Q1, 
						'' as Q2,
						'' as Q3_1, '' as Q3_2,'' as Q3_3,'' as Q3_4,'' as Q3_5,'' as Q3_6

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2,
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
						) as Q3_6
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
	ELSE IF(@CAMPAIGN_ID = 118)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.created_at,
					T.Q1,
					isnull(T.Q2_1,'') as Q2_1, isnull(T.Q2_2,'') as Q2_2, isnull(T.Q2_3,'') as Q2_3,isnull(T.Q2_4,'') as Q2_4, isnull(T.Q2_5,'') as Q2_5,
					isnull(T.Q2_6,'') as Q2_6,
					T.Q3
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, '' as Q1, 
						'' as Q2_1, '' as Q2_2,'' as Q2_3,'' as Q2_4,'' as Q2_5,'' as Q2_6,
						'' as Q3
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.1' AND T1.row_count = C.row_count
						) as Q2_1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.2' AND T1.row_count = C.row_count
						) as Q2_2,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.3' AND T1.row_count = C.row_count
						) as Q2_3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.4' AND T1.row_count = C.row_count
						) as Q2_4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.5' AND T1.row_count = C.row_count
						) as Q2_5,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.6' AND T1.row_count = C.row_count
						) as Q2_6,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
						) as Q3
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
	ELSE IF(@CAMPAIGN_ID = 120)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.customer_id,T.points,T.created_at,
					T.Q1,
					isnull(T.Q2_1,'') as Q2_1, isnull(T.Q2_2,'') as Q2_2, isnull(T.Q2_3,'') as Q2_3,isnull(T.Q2_4,'') as Q2_4, isnull(T.Q2_5,'') as Q2_5,
					isnull(T.Q2_6,'') as Q2_6,
					T.Q3, T.Q4
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT customer_id,0 as points,created_at, '' as Q1, 
						'' as Q2_1, '' as Q2_2,'' as Q2_3,'' as Q2_4,'' as Q2_5,'' as Q2_6,
						'' as Q3, '' as Q4
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.1' AND T1.row_count = C.row_count
						) as Q2_1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.2' AND T1.row_count = C.row_count
						) as Q2_2,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.3' AND T1.row_count = C.row_count
						) as Q2_3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.4' AND T1.row_count = C.row_count
						) as Q2_4,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.5' AND T1.row_count = C.row_count
						) as Q2_5,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.6' AND T1.row_count = C.row_count
						) as Q2_6,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
						) as Q3,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
						) as Q4
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
	ELSE IF(@CAMPAIGN_ID = 125)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.customer_id,T.points,T.created_at,
					T.Q1,
					isnull(T.Q2_1,'') as Q2_1, isnull(T.Q2_2,'') as Q2_2, isnull(T.Q2_3,'') as Q2_3,isnull(T.Q2_4,'') as Q2_4, isnull(T.Q2_5,'') as Q2_5,
					isnull(T.Q2_6,'') as Q2_6,
					isnull(T.Q3_1,'') as Q3_1,isnull(T.Q3_2,'') as Q3_2,isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4,
					ISNULL(T.Q3_5,'') as Q3_5,isnull(T.Q3_6,'') as Q3_6,isnull(T.Q3_7,'') as Q3_7,isnull(T.Q3_8,'') as Q3_8,
					 T.Q4,T.Q5,T.Q6
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT customer_id,0 as points,created_at, '' as Q1, 
						'' as Q2_1, '' as Q2_2,'' as Q2_3,'' as Q2_4,'' as Q2_5,'' as Q2_6,
						'' as Q3_1,'' as Q3_2, '' as Q3_3,'' as Q3_4,'' as Q3_5,'' as Q3_6,'' as Q3_7,'' as Q3_8,
						'' as Q4,'' as Q5,'' as Q6
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.1' AND T1.row_count = C.row_count
						) as Q2_1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.2' AND T1.row_count = C.row_count
						) as Q2_2,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.3' AND T1.row_count = C.row_count
						) as Q2_3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.4' AND T1.row_count = C.row_count
						) as Q2_4,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.5' AND T1.row_count = C.row_count
						) as Q2_5,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.6' AND T1.row_count = C.row_count
						) as Q2_6,
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
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.6' AND T1.row_count = C.row_count
						) as Q3_6,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.7' AND T1.row_count = C.row_count
						) as Q3_7,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.8' AND T1.row_count = C.row_count
						) as Q3_8,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
						) as Q4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5' AND T1.row_count = C.row_count
						) as Q5,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q6' AND T1.row_count = C.row_count
						) as Q6
						
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
					isnull(T.Q1_1,'') as Q1_1, isnull(T.Q1_2,'') as Q1_2, isnull(T.Q1_3,'') as Q1_3,isnull(T.Q1_4,'') as Q1_4,isnull(T.Q1_5,'') as Q1_5,isnull(T.Q1_6,'') as Q1_6,isnull(T.Q1_7,'') as Q1_7,
					isnull(T.Q2_1,'') as Q2_1, isnull(T.Q2_2,'') as Q2_2, isnull(T.Q2_3,'') as Q2_3,isnull(T.Q2_4,'') as Q2_4,isnull(T.Q2_5,'') as Q2_5,isnull(T.Q2_6,'') as Q2_6,isnull(T.Q2_7,'') as Q2_7,
					isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4,isnull(T.Q3_5,'') as Q3_5,isnull(T.Q3_6,'') as Q3_6,isnull(T.Q3_7,'') as Q3_7
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT customer_id,0 as points,location as GPS_location,ip_address,created_at, 
						'' as Q1_1, '' as Q1_2,'' as Q1_3,'' as Q1_4,'' as Q1_5,'' as Q1_6,'' as Q1_7,
						'' as Q2_1, '' as Q2_2,'' as Q2_3,'' as Q2_4,'' as Q2_5,'' as Q2_6,'' as Q2_7,
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
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.6' AND T1.row_count = C.row_count
						) as Q1_6,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1.7' AND T1.row_count = C.row_count
						) as Q1_7,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.1' AND T1.row_count = C.row_count
						) as Q2_1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.2' AND T1.row_count = C.row_count
						) as Q2_2,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.3' AND T1.row_count = C.row_count
						) as Q2_3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.4' AND T1.row_count = C.row_count
						) as Q2_4,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.5' AND T1.row_count = C.row_count
						) as Q2_5,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.6' AND T1.row_count = C.row_count
						) as Q2_6,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.7' AND T1.row_count = C.row_count
						) as Q2_7,

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
	ELSE IF(@CAMPAIGN_ID = 117)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.created_at,
					T.Q1, T.Q2,
					isnull(T.Q3_1,'') as Q3_1, isnull(T.Q3_2,'') as Q3_2, isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4,isnull(T.Q3_5,'') as Q3_5,isnull(T.Q3_6,'') as Q3_6
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, '' as Q1, 
						'' as Q2,
						'' as Q3_1, '' as Q3_2,'' as Q3_3,'' as Q3_4,'' as Q3_5,'' as Q3_6

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2,
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
						) as Q3_6
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
	ELSE IF(@CAMPAIGN_ID = 118)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.created_at,
					T.Q1,
					isnull(T.Q2_1,'') as Q2_1, isnull(T.Q2_2,'') as Q2_2, isnull(T.Q2_3,'') as Q2_3,isnull(T.Q2_4,'') as Q2_4, isnull(T.Q2_5,'') as Q2_5,
					isnull(T.Q2_6,'') as Q2_6,
					T.Q3
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, '' as Q1, 
						'' as Q2_1, '' as Q2_2,'' as Q2_3,'' as Q2_4,'' as Q2_5,'' as Q2_6,
						'' as Q3
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.1' AND T1.row_count = C.row_count
						) as Q2_1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.2' AND T1.row_count = C.row_count
						) as Q2_2,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.3' AND T1.row_count = C.row_count
						) as Q2_3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.4' AND T1.row_count = C.row_count
						) as Q2_4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.5' AND T1.row_count = C.row_count
						) as Q2_5,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.6' AND T1.row_count = C.row_count
						) as Q2_6,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
						) as Q3
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
	ELSE IF(@CAMPAIGN_ID = 120)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.customer_id,T.points,T.created_at,
					T.Q1,
					isnull(T.Q2_1,'') as Q2_1, isnull(T.Q2_2,'') as Q2_2, isnull(T.Q2_3,'') as Q2_3,isnull(T.Q2_4,'') as Q2_4, isnull(T.Q2_5,'') as Q2_5,
					isnull(T.Q2_6,'') as Q2_6,
					T.Q3, T.Q4
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT customer_id,0 as points,created_at, '' as Q1, 
						'' as Q2_1, '' as Q2_2,'' as Q2_3,'' as Q2_4,'' as Q2_5,'' as Q2_6,
						'' as Q3, '' as Q4
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.1' AND T1.row_count = C.row_count
						) as Q2_1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.2' AND T1.row_count = C.row_count
						) as Q2_2,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.3' AND T1.row_count = C.row_count
						) as Q2_3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.4' AND T1.row_count = C.row_count
						) as Q2_4,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.5' AND T1.row_count = C.row_count
						) as Q2_5,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.6' AND T1.row_count = C.row_count
						) as Q2_6,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
						) as Q3,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
						) as Q4
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
	ELSE IF(@CAMPAIGN_ID = 125)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.customer_id,T.points,T.created_at,
					T.Q1,
					isnull(T.Q2_1,'') as Q2_1, isnull(T.Q2_2,'') as Q2_2, isnull(T.Q2_3,'') as Q2_3,isnull(T.Q2_4,'') as Q2_4, isnull(T.Q2_5,'') as Q2_5,
					isnull(T.Q2_6,'') as Q2_6,
					isnull(T.Q3_1,'') as Q3_1,isnull(T.Q3_2,'') as Q3_2,isnull(T.Q3_3,'') as Q3_3,isnull(T.Q3_4,'') as Q3_4,
					ISNULL(T.Q3_5,'') as Q3_5,isnull(T.Q3_6,'') as Q3_6,isnull(T.Q3_7,'') as Q3_7,isnull(T.Q3_8,'') as Q3_8,
					 T.Q4,T.Q5,T.Q6
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT customer_id,0 as points,created_at, '' as Q1, 
						'' as Q2_1, '' as Q2_2,'' as Q2_3,'' as Q2_4,'' as Q2_5,'' as Q2_6,
						'' as Q3_1,'' as Q3_2, '' as Q3_3,'' as Q3_4,'' as Q3_5,'' as Q3_6,'' as Q3_7,'' as Q3_8,
						'' as Q4,'' as Q5,'' as Q6
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.1' AND T1.row_count = C.row_count
						) as Q2_1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.2' AND T1.row_count = C.row_count
						) as Q2_2,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.3' AND T1.row_count = C.row_count
						) as Q2_3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.4' AND T1.row_count = C.row_count
						) as Q2_4,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.5' AND T1.row_count = C.row_count
						) as Q2_5,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.6' AND T1.row_count = C.row_count
						) as Q2_6,
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
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.6' AND T1.row_count = C.row_count
						) as Q3_6,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.7' AND T1.row_count = C.row_count
						) as Q3_7,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.8' AND T1.row_count = C.row_count
						) as Q3_8,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' AND T1.row_count = C.row_count
						) as Q4,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5' AND T1.row_count = C.row_count
						) as Q5,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q6' AND T1.row_count = C.row_count
						) as Q6
						
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
		ELSE IF(@CAMPAIGN_ID = 157)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
					T.Q1, T.Q2, T.Q3, T.Q4, T.Q5, correct_answers 
			
					FROM

					(
						-----table1
						SELECT * from
						(SELECT customer_id,0 as points,location as GPS_location,ip_address,created_at, 
						'' as Q1,'' as Q2 ,'' as Q3,'' as Q4, '' as Q5, 0 as correct_answers
						

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' 
						) as Q1,
						

						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' 
						) as Q2,

						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3'
						) as Q3,

						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' 
						) as Q4,

						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5' 
						) as Q5,

						(
							select count(*) from winktag_customer_survey_answer_detail as T1
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID  
							AND(answer='book1_1_atomic.jpg' or answer='book2_2_investor.jpg' 
							or answer='book3_1_keepgoing.jpg' or answer='book4_3_goodbye.jpg' or answer='book5_2_saltfat.jpg')

							
						) as correct_answers
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
					WHERE @validity is null 
							or (@validity = 'Yes' AND T.Q5 != '')  
							or (@validity = '0' AND T.Q5 = '')						
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

        RETURN
END
