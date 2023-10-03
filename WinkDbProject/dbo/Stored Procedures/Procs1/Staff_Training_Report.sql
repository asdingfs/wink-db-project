CREATE PROC [dbo].[Staff_Training_Report]
(
	@customer_name varchar(200),
	@email varchar(200),
	@gender varchar(200),
	@customer_id int,
	@start_date varchar(50),
	@end_date varchar(50),
	@winktag_report varchar(50),
	@wid varchar(50),
	@validity varchar(10),
	@status varchar(50),
	@progress int
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
	IF(@validity is null or @validity='')
		SET @validity = NULL
	IF(@status is null or @status='')
		SET @status = NULL
	IF(@progress = 2)
		SET @progress = NULL
	
	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
		RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)

	IF(@CAMPAIGN_ID = 169)
	BEGIN
		
	SELECT * FROM 
	(--1 START
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status],
		T.customer_id,T.created_at,
		T.Q1,T.Q2, T.Q3, T.Q4,T.Q5,T.Q6, T.Q7, T.Q8,T.Q9,T.Q10, T.Q11, T.Q12,T.Q13, T.Q14, T.Q15,T.Q16, T.Q17, T.Q18,T.Q19, T.Q20, T.Q21,T.Q22, T.Q23, T.Q24,T.Q25,
		T.score, T.progress
		FROM(
			SELECT * FROM  
			(
				SELECT customer_id, created_at, 
				'' as Q1, '' as Q2, '' as Q3,'' as Q4, '' as Q5, '' as Q6, '' as Q7,'' as Q8, '' as Q9, '' as Q10, '' as Q11,'' as Q12, '' as Q13,
				'' as Q14, '' as Q15,'' as Q16,'' as Q17, '' as Q18,'' as Q19,'' as Q20, '' as Q21,'' as Q22,'' as Q23, '' as Q24,'' as Q25, 0 as score, 0 as progress
				from winktag_customer_action_log 
					WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
				) as T1
					-----table1
				UNION

				SELECT C.customer_id,C.created_at,

				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' 
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q1,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q2,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q3,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q4,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q5' 
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q5,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q6'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q6,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q7'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q7,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q8'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q8,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q9' 
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q9,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q10'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q10,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q11'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q11,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q12'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q12,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q13'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q13,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q14'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q14,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q15'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q15,
	
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q16'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q16,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q17'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q17,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q18'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q18,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q19'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q19,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q20'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q20,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q21'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q21,

				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q22'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q22,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q23'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q23,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q24'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q24,
				(
					SELECT TOP(1) answer FROM winktag_customer_survey_answer_detail AS T1 
					WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q25'
					AND T1.created_at >= C.created_at
					AND T1.customer_id = C.customer_id
					ORDER BY T1.created_at
				) as Q25,
				(
					select ISNULL(sum(cast(total AS INT)),0)
					from(
						select TOP(25)subAns.option_answer as total
						FROM winktag_customer_survey_answer_detail as subAns
						WHERE subAns.campaign_id = @CAMPAIGN_ID
						AND subAns.customer_id = C.customer_id
						AND subAns.created_at >= C.created_at
						order by subAns.created_at
					) as scoreCount
				)
				as score,
				C.additional_point_status as progress
				FROM winktag_customer_earned_points AS C 
				WHERE C.campaign_id = @CAMPAIGN_ID   
				AND (@progress is null or C.additional_point_status = @progress)
			) 
			AS T 
			INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
			WHERE (@validity is null 
				or (@validity = 'Yes' AND T.Q1 != '')  
				or (@validity = '0' AND T.Q1 = ''))
							
			AND (@start_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			AND (@customer_id is null or T.customer_id = @customer_id)
		) AS TEMP----1 END
		WHERE (@email is null or TEMP.email like '%'+@email+'%')
		AND (@gender is null or TEMP.gender like @gender+'%')
		AND (@wid is null or TEMP.wid like '%'+@wid+'%')
		AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
		AND (@status is null or TEMP.status = @status)
		AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			
		order by temp.no desc
	END
	
END



