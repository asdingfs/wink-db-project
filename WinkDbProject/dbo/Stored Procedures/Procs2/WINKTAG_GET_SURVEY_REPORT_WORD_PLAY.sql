CREATE PROC [dbo].[WINKTAG_GET_SURVEY_REPORT_WORD_PLAY]
(
	@customer_name varchar(200),
	@email varchar(200),
	@customer_id int,
	@start_date varchar(50),
	@end_date varchar(50),
	@winktag_report varchar(50),
	@wid varchar(50),
	@winner varchar(5),
	@day date,
	@status varchar(50)
)
AS

BEGIN

	DECLARE @CAMPAIGN_ID int
	
	IF (@start_date is null or @start_date = '')
		SET @start_date = NULL;

	IF (@end_date is null or @end_date = '')
		SET @end_date = NULL;

	IF(@customer_name is null or @customer_name ='')
		SET @customer_name = NULL

	IF(@email is null or @email ='')
		SET @email = NULL

	
	IF(@customer_id = 0)
		SET @customer_id = NULL

	IF(@wid is null or @wid ='')
		SET @wid = NULL

	IF(@winner is null or @winner ='')
		SET @winner = NULL

	IF(@day is null or @day ='')
		SET @day = NULL

	IF(@status is null or @status='')
		SET @status = NULL
	
	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
		RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)

	IF(@CAMPAIGN_ID = 46)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.GPS_location,T.ip_address,T.created_at,T.Q1, T.winner
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at, '' as Q1, '' as winner
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0 and (@day IS NULL or CAST(created_at as date) = @day)
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,

						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
							AND(@winner IS NULL OR option_answer like @winner)
						) as Q1,
						(
							SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
							AND(@winner IS NULL OR option_answer like @winner)
						
						) as winner


						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID	AND (@day IS NULL OR CAST(C.created_at as Date) = CAST (@day as date))
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

				) AS TEMP----1 END
				WHERE (@email is null or TEMP.email like '%'+@email+'%')
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@status is null or TEMP.status = @status)
				AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			
				order by temp.no desc
		END
	ELSE IF(@CAMPAIGN_ID = 48)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.GPS_location,T.ip_address,T.created_at,T.Q1, T.winner
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at, '' as Q1, '' as winner
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0 and (@day IS NULL or CAST(created_at as date) = @day)
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,

						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
							AND(@winner IS NULL OR option_answer like @winner)
						) as Q1,
						(
							SELECT option_answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
							AND(@winner IS NULL OR option_answer like @winner)
						
						) as winner


						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID	AND (@day IS NULL OR CAST(C.created_at as Date) = CAST (@day as date))
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

				) AS TEMP----1 END
				WHERE (@email is null or TEMP.email like '%'+@email+'%')
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@status is null or TEMP.status = @status)
				AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			
				order by temp.no desc
		END
	
	ELSE IF(@CAMPAIGN_ID = 54)
		BEGIN
			DECLARE @surveyStart varchar(50);
			DECLARE @surveyEnd varchar(50);

			DECLARE @LWMStart varchar(50);
			DECLARE @LWMEnd varchar(50);
			SET @LWMStart = '2019-01-11';
			SET @LWMEnd = '2019-01-12';

			DECLARE @NYSSStart varchar(50);
			DECLARE @NYSSEnd varchar(50);
			SET @NYSSStart = '2019-01-13';
			SET @NYSSEnd = '2019-01-18';

			DECLARE @YNHCStart varchar(50);
			DECLARE @YNHCEnd varchar(50);
			SET @YNHCStart = '2019-01-19';
			SET @YNHCEnd = '2019-01-24';

			DECLARE @JPSStart varchar(50);
			DECLARE @JPSEnd varchar(50);
			SET @JPSStart = '2019-01-25';
			SET @JPSEnd = '2019-02-01';

			DECLARE @NYSSTwoStart varchar(50);
			DECLARE @NYSSTwoEnd varchar(50);
			SET @NYSSTwoStart = '2019-02-01';
			SET @NYSSTwoEnd = '2019-02-12';

			DECLARE @VictoriaStart varchar(50);
			DECLARE @VictoriaEnd varchar(50);
			SET @VictoriaStart = '2019-02-08';
			SET @VictoriaEnd = '2019-02-12';

			DECLARE @ShakuraStart varchar(50);
			DECLARE @ShakuraEnd varchar(50);
			SET @ShakuraStart = '2019-02-13';
			SET @ShakuraEnd = '2019-02-28';

			IF (@status = '291')
				BEGIN
					SET @surveyStart = @LWMStart;
					SET @surveyEnd = @LWMEnd;
				END
			ELSE IF (@status = '282')
				BEGIN
					SET @surveyStart = @NYSSStart;
					SET @surveyEnd = @NYSSEnd;
				END
			ELSE IF (@status = '321')
				BEGIN
					SET @surveyStart = @YNHCStart;
					SET @surveyEnd = @YNHCEnd;
				END
			ELSE IF (@status = '330')
				BEGIN
					SET @surveyStart = @JPSStart;
					SET @surveyEnd = @JPSEnd;
				END
			ELSE IF (@status = '360')
				BEGIN
					SET @surveyStart = @NYSSTwoStart;
					SET @surveyEnd = @NYSSTwoEnd;
				END
			ELSE IF (@status = '375')
				BEGIN
					SET @surveyStart = @VictoriaStart;
					SET @surveyEnd = @VictoriaEnd;
				END
			ELSE IF (@status = '384')
				BEGIN
					SET @surveyStart = @ShakuraStart;
					SET @surveyEnd = @ShakuraEnd;
				END
			ELSE 
				BEGIN
					SET @surveyStart = NULL;
					SET @surveyEnd = NULL;
				END

			PRINT ('Survey Start: ' + @surveyStart);
			PRINT ('Survey End: ' + @surveyEnd);

			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no
						, CUSTOMER.first_name +' '+CUSTOMER.last_name AS customer_name
						, CUSTOMER.email
						, CUSTOMER.gender
						, (select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) AS age
						, Customer.WID AS wid 
						, T.campaign_id
						, T.customer_id
						, T.points
						, T.GPS_location
						, T.ip_address
						, T.created_at
						, isnull(T.Q1,'') AS Q1
						, isnull(T.Q1_1,'') AS Q1_1
						, isnull(T.Q1_2,'') AS Q1_2
						, isnull(T.Q1_3,'') AS Q1_3
						, isnull(T.Q1_4,'') AS Q1_4
						, isnull(T.Q1_5,'') AS Q1_5
						, isnull(T.Q1_6,'') AS Q1_6
						, isnull(T.Q1_7,'') AS Q1_7
						, isnull(T.Q1_8,'') AS Q1_8
						, isnull(T.Q1_9,'') AS Q1_9
						, T.Q2
						, isnull(T.Q2_1,'') AS Q2_1
						, isnull(T.Q2_2,'') AS Q2_2
						, isnull(T.Q2_3,'') AS Q2_3
						, isnull(T.Q2_4,'') AS Q2_4
						, isnull(T.Q2_5,'') AS Q2_5
						, isnull(T.Q2_6,'') AS Q2_6
						, isnull(T.Q2_7,'') AS Q2_7
						, T.Q3
						, isnull(T.Q3_1,'') AS Q3_1
						, isnull(T.Q3_2,'') AS Q3_2
						, isnull(T.Q3_3,'') as Q3_3
						, isnull(T.Q3_4,'') AS Q3_4
						, isnull(T.Q3_5,'') AS Q3_5
						, isnull(T.Q3_6,'') AS Q3_6
						, isnull(T.Q3_7,'') AS Q3_7
						, isnull(T.Q3_8,'') AS Q3_8
						, T.category
						, T.status
	
					FROM
					(
						-----table1
						SELECT * from
						(
							SELECT campaign_id
								, customer_id
								, 0 AS points
								, location AS GPS_location
								, ip_address
								, created_at
								, '' AS Q1
 								, '' AS Q1_1
								, '' as Q1_2
								, '' AS Q1_3
								, '' AS Q1_4
								, '' AS Q1_5
								, '' AS Q1_6
								, '' AS Q1_7
								, '' AS Q1_8
								, '' AS Q1_9
								, '' AS Q2
								, '' AS Q2_1
								, '' as Q2_2
								, '' AS Q2_3
								, '' AS Q2_4
								, '' AS Q2_5
								, '' AS Q2_6
								, '' AS Q2_7
								, '' AS Q3
								, '' AS Q3_1
								, '' AS Q3_2
								, '' AS Q3_3
								, '' AS Q3_4
								, '' AS Q3_5
								, '' AS Q3_6
								, '' AS Q3_7
								, '' AS Q3_8
								, '' AS category
								, '' AS status
							FROM winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID 
								AND survey_complete_status = 0
								AND ( @surveyStart IS NULL OR @surveyEnd IS NULL
									OR CAST(created_at as Date) BETWEEN CAST(@surveyStart as Date) AND CAST(@surveyEnd as Date)
								)
								
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id
							, C.customer_id
							, C.points
							, C.GPS_location
							, C.ip_address
							, C.created_at,

						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q1'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q1.1'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q1_1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q1.2'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q1_2,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q1.3'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q1_3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q1.4'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q1_4,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q1.5'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q1_5,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q1.6'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q1_6,
						
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q1.7'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q1_7,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q1.8'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q1_8,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q1.9'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q1_9,

						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q2'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q2,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q2.1'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q2_1,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q2.2'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q2_2,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q2.3'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q2_3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q2.4'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q2_4,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q2.5'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q2_5,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q2.6'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q2_6,
						
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q2.7'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q2_7,
						
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q3'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q3,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q3.1'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q3_1,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q3.2'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q3_2,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q3.3'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q3_3,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q3.4'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q3_4,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q3.5'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q3_5,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q3.6'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q3_6,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q3.7'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q3_7,

						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q3.8'
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						) as Q3_8,

						(
							SELECT TOP(1) option_answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.row_count = C.row_count
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
						
						) as category,

						(
							SELECT SUM(DISTINCT(question_id) ) FROM winktag_customer_survey_answer_detail AS T1
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
								AND T1.row_count = C.row_count
						) as status

						FROM winktag_customer_earned_points AS C 
						WHERE C.campaign_id = @CAMPAIGN_ID
						AND (@status IS NULL OR @status LIKE '0' OR @status LIKE '1' OR (
							SELECT SUM(DISTINCT(question_id) ) FROM winktag_customer_survey_answer_detail AS T1
							WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
								AND T1.row_count = C.row_count
						) LIKE @status)
						AND (@winner IS NULL OR @winner LIKE '0' OR EXISTS (
								SELECT '1' FROM winktag_customer_survey_answer_detail AS T1
								WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND(@winner IS NULL OR @winner LIKE '0' OR option_answer like @winner)
								AND T1.row_count = C.row_count
							)
						)
						AND ( @surveyStart IS NULL OR @surveyEnd IS NULL
							OR CAST(created_at as Date) BETWEEN CAST(@surveyStart as Date) AND CAST(@surveyEnd as Date)
						)
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

				) AS TEMP----1 END
				WHERE (@email is null or TEMP.email like '%'+@email+'%')
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
				order by temp.no desc
		END
	
	ELSE IF(@CAMPAIGN_ID = 59)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
					T.Q1,
					isnull(T.Q2_1,'') as Q2_1,
					isnull(T.Q2_2,'') as Q2_2,
					isnull(T.Q2_3,'') as Q2_3,
					isnull(T.Q2_4,'') as Q2_4,
					isnull(T.Q2_5,'') as Q2_5,
					isnull(T.Q2_6,'') as Q2_6,
					isnull(T.Q2_7,'') as Q2_7,
					isnull(T.Q2_8,'') as Q2_8,
					T.Q3
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at
						, '' as Q1
						, '' AS Q2_1
						, '' AS Q2_2
						, '' AS Q2_3
						, '' AS Q2_4
						, '' AS Q2_5
						, '' AS Q2_6
						, '' AS Q2_7
						, '' AS Q2_8
						, '' AS Q3
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
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.6' AND T1.row_count = C.row_count
						) as Q2_6,
						(
							SELECT '1' FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.7' AND T1.row_count = C.row_count
						) as Q2_7,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2.8' AND T1.row_count = C.row_count
						) as Q2_8,
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
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@status is null or TEMP.status = @status)
				AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
				order by temp.no desc
		END

	ELSE IF(@CAMPAIGN_ID = 60)
		BEGIN
			DECLARE @valid_answer varchar(20);
			SET @valid_answer = 'Liam Neeson';
			IF(@winner = 1)
				BEGIN
					SELECT * FROM 
					(--1 START
						SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
						T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at
						, T.Q1
						, T.Q2
					
						FROM

						(
							-----table1
							SELECT * from
							(
								SELECT campaign_id
								,customer_id,0 as points
								,location as GPS_location
								,ip_address
								,created_at
								, '' as Q1
								, '' as Q2
							from winktag_customer_action_log 
								WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
							) as T1
							-----table1

							UNION
	
							-----table2
							SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,

							(
								SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
								WHERE T1.customer_id = C.customer_id 
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q1'
								AND T1.row_count = C.row_count
							) as Q1,

							(
								SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
								WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q2'
								AND T1.row_count = C.row_count
							) as Q2

							FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID
							-----table2

						) AS T 
						INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

					) AS TEMP----1 END
					WHERE (@email is null or TEMP.email like '%'+@email+'%')
					AND (@wid is null or TEMP.wid like '%'+@wid+'%')
					AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
					AND (@customer_id is null or TEMP.customer_id = @customer_id)
					AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
					AND TEMP.Q1 like @valid_answer
					AND (@status IS NULL OR @status LIKE '0' OR TEMP.status like @status) 
					order by temp.no desc
		
				END

			ELSE IF(@winner = 2)
				BEGIN
					SELECT * FROM 
					(--1 START
						SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
						T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at
						, T.Q1
						, T.Q2
					
						FROM

						(
							-----table1
							SELECT * from
							(
								SELECT campaign_id
								,customer_id,0 as points
								,location as GPS_location
								,ip_address
								,created_at
								, '' as Q1
								, '' as Q2
							from winktag_customer_action_log 
								WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
							) as T1
							-----table1

							UNION
	
							-----table2
							SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,

							(
								SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
								WHERE T1.customer_id = C.customer_id 
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q1'
								AND T1.row_count = C.row_count
							) as Q1,

							(
								SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
								WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q2'
								AND T1.row_count = C.row_count
							) as Q2

							FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID
							-----table2

						) AS T 
						INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

					) AS TEMP----1 END
					WHERE (@email is null or TEMP.email like '%'+@email+'%')
					AND (@wid is null or TEMP.wid like '%'+@wid+'%')
					AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
					AND (@customer_id is null or TEMP.customer_id = @customer_id)
					AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
					AND TEMP.Q1 NOT LIKE @valid_answer
					AND (@status IS NULL OR @status LIKE '0' OR TEMP.status like @status) 
					order by temp.no desc
		
				END

			ELSE
				BEGIN
					SELECT * FROM 
					(--1 START
						SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
						T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at
						, T.Q1
						, T.Q2
					
						FROM

						(
							-----table1
							SELECT * from
							(
								SELECT campaign_id
								,customer_id,0 as points
								,location as GPS_location
								,ip_address
								,created_at
								, '' as Q1
								, '' as Q2
							from winktag_customer_action_log 
								WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
							) as T1
							-----table1

							UNION
	
							-----table2
							SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,

							(
								SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
								WHERE T1.customer_id = C.customer_id 
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q1'
								AND T1.row_count = C.row_count
							) as Q1,

							(
								SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
								WHERE T1.customer_id = C.customer_id
								AND T1.campaign_id = @CAMPAIGN_ID
								AND T1.question_no = 'Q2'
								AND T1.row_count = C.row_count
							) as Q2

							FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID
							-----table2

						) AS T 
						INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

					) AS TEMP----1 END
					WHERE (@email is null or TEMP.email like '%'+@email+'%')
					AND (@wid is null or TEMP.wid like '%'+@wid+'%')
					AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
					AND (@customer_id is null or TEMP.customer_id = @customer_id)
					AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
					AND (@status IS NULL OR @status LIKE '0' OR TEMP.status like @status) 
					order by temp.no desc

				END
		END
	
	ELSE IF(@CAMPAIGN_ID = 62)
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
						(SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at
						, '' as Q1
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
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@status is null or TEMP.status = @status)
				AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
				order by temp.no desc
		END

	ELSE IF(@CAMPAIGN_ID = 143 or @CAMPAIGN_ID = 63 or @CAMPAIGN_ID = 99 or @CAMPAIGN_ID = 135)
		BEGIN
			WITH microsite AS (
				SELECT RANK() OVER (ORDER BY id) Rank
				, '' AS customer_id
				, campaign_id
				, 0 AS points
				, GPS_location
				, ip_address
				, created_at
				, question_no
				, answer
				FROM winktag_customer_survey_answer_detail
				WHERE campaign_id = @CAMPAIGN_ID
				AND customer_id = 0
			)
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
					T.Q1
					, T.Q2
					, T.Q3
					, T.Q4_1
					, T.Q4_2
					, T.Q4_3
					, T.Q4_4
					
					FROM

					(
						-----table1
						SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,

						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1

						, (
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' AND T1.row_count = C.row_count
						) as Q2

						, (
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3' AND T1.row_count = C.row_count
						) as Q3

						, (
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.1' AND T1.row_count = C.row_count
						) as Q4_1

						, (
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.2' AND T1.row_count = C.row_count
						) as Q4_2

						, (
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.3' AND T1.row_count = C.row_count
						) as Q4_3

						, (
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4.4' AND T1.row_count = C.row_count
						) as Q4_4

						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						-----table1

						--- microsite
						UNION
						SELECT
							
							MIN(microsite.campaign_id) AS campaign_id
							, MIN(microsite.customer_id) AS customer_id
							, MIN(microsite.points) AS points
							, MIN(microsite.GPS_location) AS GPS_location
							, MIN(microsite.ip_address) AS ip_address
							, MIN(microsite.created_at) AS created_at
							, MIN(CASE question_no When 'Q1' Then answer END) Q1
							, MIN(CASE question_no When 'Q2' Then answer END) Q2
							, MIN(CASE question_no When 'Q3' Then answer END) Q3
							, MIN(CASE question_no When 'Q4.1' Then answer END) Q4_1
							, MIN(CASE question_no When 'Q4.2' Then answer END) Q4_2
							, MIN(CASE question_no When 'Q4.3' Then answer END) Q4_3
							, MIN(CASE question_no When 'Q4.4' Then answer END) Q4_4
						FROM microsite
						GROUP BY ((Rank-1) / 7)
					) AS T 
					LEFT JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id

				) AS TEMP----1 END
				WHERE (@email is null or TEMP.Q3 like '%'+@email+'%')
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.Q1 like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@status is null or TEMP.status = @status)
				AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
				order by temp.no desc
		END

END



