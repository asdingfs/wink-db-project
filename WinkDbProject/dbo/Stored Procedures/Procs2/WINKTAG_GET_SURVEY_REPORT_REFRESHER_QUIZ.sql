CREATE PROC [dbo].[WINKTAG_GET_SURVEY_REPORT_REFRESHER_QUIZ]
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

	DECLARE @CAMPAIGN_ID int
	
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

	IF(@CAMPAIGN_ID = 142)
	BEGIN
		
	SELECT * FROM 
	(--1 START
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
		T.campaign_id,T.customer_id,T.GPS_location,T.ip_address,T.created_at,
		T.Q1,T.Q2, T.Q3, T.Q4,T.Q5,T.Q6, T.Q7, T.Q8,T.Q9,T.Q10, T.Q11, T.Q12,T.Q13, T.Q14, T.Q15,T.Q16, T.Q17, T.Q18,T.Q19, T.Q20, T.Q21,T.Q22, T.Q23, T.Q24,T.Q25
		FROM(
			SELECT * FROM  
			(SELECT campaign_id,customer_id, location as GPS_location,ip_address,created_at, 
			'' as Q1, '' as Q2, '' as Q3,'' as Q4, '' as Q5, '' as Q6, '' as Q7,'' as Q8, '' as Q9, '' as Q10, '' as Q11,'' as Q12, '' as Q13,
			'' as Q14, '' as Q15,'' as Q16,'' as Q17, '' as Q18,'' as Q19,'' as Q20, '' as Q21,'' as Q22,'' as Q23, '' as Q24,'' as Q25
			from winktag_customer_action_log 
				WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
			) as T1
					-----table1

			UNION

			SELECT C.campaign_id, C.customer_id,C.GPS_location,C.ip_address,C.created_at,

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
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q6'
			) as Q6,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q7'
			) as Q7,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q8'
			) as Q8,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q9' 
			) as Q9,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q10'
			) as Q10,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q11'
			) as Q11,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q12'
			) as Q12,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q13'
			) as Q13,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q14'
			) as Q14,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q15'
			) as Q15,
	
	(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q16'
			) as Q16,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q17'
			) as Q17,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q18'
			) as Q18,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q19'
			) as Q19,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q20'
			) as Q20,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q21'
			) as Q21,

			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q22'
			) as Q22,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q23'
			) as Q23,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q24'
			) as Q24,
			(
				SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q25'
			) as Q25
			FROM qr_campaign AS C WHERE C.campaign_id = @CAMPAIGN_ID   

			) AS T 
				INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 

		) AS TEMP----1 END
		WHERE (@email is null or TEMP.email like '%'+@email+'%')
		AND (@gender is null or TEMP.gender like @gender+'%')
		AND (@wid is null or TEMP.wid like '%'+@wid+'%')
		AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
		AND (@customer_id is null or TEMP.customer_id = @customer_id)
		AND (@status is null or TEMP.status = @status)
		AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			
		order by temp.no desc
	END
	ELSE IF(@CAMPAIGN_ID = 102)
	BEGIN
	SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.campaign_id,T.customer_id,T.GPS_location,T.ip_address,T.created_at,
					T.Q1,T.Q2,T.Q3,T.Q4
					
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,location as GPS_location,ip_address,created_at, '' as Q1, '' as Q2, '' as Q3,'' as Q4
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT  C.campaign_id,C.customer_id,C.GPS_location,C.ip_address,C.created_at,
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
						) as Q4
						FROM qr_campaign AS C WHERE C.campaign_id = @CAMPAIGN_ID   
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



