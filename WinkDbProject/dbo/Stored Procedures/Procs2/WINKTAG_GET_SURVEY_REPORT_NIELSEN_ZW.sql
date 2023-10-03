CREATE PROC [dbo].[WINKTAG_GET_SURVEY_REPORT_NIELSEN_ZW]
(
	@customer_name varchar(200),
	@email varchar(200),
	@customer_id int,
	@start_date varchar(50),
	@end_date varchar(50),
	@winktag_report varchar(50),
	@winktag_point_status varchar(50)
)
AS

BEGIN

 IF (@start_date is null or @start_date = '')
 BEGIN
 SET @start_date = NULL;
 END

 IF (@end_date is null or @end_date = '')
 BEGIN
 SET @end_date = NULL;
 END

	if(@customer_name is null or @customer_name ='')
		set @customer_name = NULL

	if(@email is null or @email ='')
		set @email = NULL

	if(@customer_id = 0)
		set @customer_id = NULL


	DECLARE @CAMPAIGN_ID int;

	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
		RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)


IF (@winktag_point_status = 'y')
BEGIN
SELECT * FROM 
	(--1 START
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC) AS no, T.*,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age FROM

		(		
			-----table2
			SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' group by T1.row_count, T1.option_answer
			) as Q1,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' group by T1.row_count, T1.option_answer
			) as Q2,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.1' group by T1.row_count, T1.option_answer
			) as Q3_1,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.2' group by T1.row_count, T1.option_answer
			) as Q3_2,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.3' group by T1.row_count, T1.option_answer
			) as Q3_3,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.4' group by T1.row_count, T1.option_answer
			) as Q3_4,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.5' group by T1.row_count, T1.option_answer
			) as Q3_5,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.6' group by T1.row_count, T1.option_answer
			) as Q3_6,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.7' group by T1.row_count, T1.option_answer
			) as Q3_7,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.8' group by T1.row_count, T1.option_answer
			) as Q3_8,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.9' group by T1.row_count, T1.option_answer
			) as Q3_9,

			(
				SELECT distinct answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.10' group by T1.row_count, T1.option_answer, T1.answer
			) as other,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.10' group by T1.row_count, T1.option_answer
			) as rank_for_other,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' group by T1.row_count, T1.option_answer
			) as Q4

			FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID 
			-----table2

		) AS T 
		INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id

	) AS TEMP----1 END
	WHERE (@email is null or TEMP.email like '%'+@email+'%')
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
				SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at,'' as Q1, '' as Q2,'' as Q3_1,'' as Q3_2,'' as Q3_3,'' as Q3_4,'' as Q3_5,'' as Q3_6,'' as Q3_7,'' as Q3_8,'' as Q3_9,'' as other,'' as rank_for_other,'' as Q4  from winktag_customer_action_log 
				WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
			) as T1
			-----table1

		) AS T 
		INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id

	) AS TEMP----1 END
	WHERE (@email is null or TEMP.email like '%'+@email+'%')
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
				SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at,'' as Q1, '' as Q2,'' as Q3_1,'' as Q3_2,'' as Q3_3,'' as Q3_4,'' as Q3_5,'' as Q3_6,'' as Q3_7,'' as Q3_8,'' as Q3_9,'' as other,'' as rank_for_other,'' as Q4  from winktag_customer_action_log 
				WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
			) as T1
			-----table1

			UNION
	
			-----table2
			SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' group by T1.row_count, T1.option_answer
			) as Q1,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q2' group by T1.row_count, T1.option_answer
			) as Q2,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.1' group by T1.row_count, T1.option_answer
			) as Q3_1,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.2' group by T1.row_count, T1.option_answer
			) as Q3_2,

			(
				SELECT  distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.3' group by T1.row_count, T1.option_answer
			) as Q3_3,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.4' group by T1.row_count, T1.option_answer
			) as Q3_4,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.5' group by T1.row_count, T1.option_answer
			) as Q3_5,

			(
				SELECT  distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.6' group by T1.row_count, T1.option_answer
			) as Q3_6,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.7' group by T1.row_count, T1.option_answer
			) as Q3_7,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.8' group by T1.row_count, T1.option_answer
			) as Q3_8,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.9' group by T1.row_count, T1.option_answer
			) as Q3_9,

			(
				SELECT distinct answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.10' group by T1.row_count, T1.option_answer, T1.answer
			) as other,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q3.10' group by T1.row_count, T1.option_answer
			) as rank_for_other,

			(
				SELECT distinct option_answer FROM winktag_customer_survey_answer_detail AS T1 
				WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q4' group by T1.row_count, T1.option_answer
			) as Q4

			FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID 
			-----table2

		) AS T 
		INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id

	) AS TEMP----1 END
	WHERE (@email is null or TEMP.email like '%'+@email+'%')
	AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
	AND (@customer_id is null or TEMP.customer_id = @customer_id)
	AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
	order by temp.no desc
END


	
END



