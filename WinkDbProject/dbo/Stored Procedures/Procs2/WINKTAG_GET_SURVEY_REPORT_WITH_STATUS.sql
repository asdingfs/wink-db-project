CREATE PROC [dbo].[WINKTAG_GET_SURVEY_REPORT_WITH_STATUS]
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

	DECLARE @CAMPAIGN_ID int;

	IF (@start_date is null or @start_date = '')
		SET @start_date = NULL;

	IF (@end_date is null or @end_date = '')
		SET @end_date = NULL;

	IF(@customer_name is null or @customer_name ='')
		SET @customer_name = Null

	IF(@email is null or @email ='')
		SET @email = Null

	IF(@customer_id is null or  @customer_id =''  or @customer_id =0)
		SET @customer_id = Null

	IF(@start_date is null or  @start_date ='')
		SET @start_date = Null

	IF(@end_date is null or  @end_date ='')
		SET @end_date = Null

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

				(SELECT Q1 FROM
							(
								SELECT T1.customer_id  ,('Q' + CAST(ROW_NUMBER() OVER(PARTITION BY T1.CUSTOMER_ID ORDER BY option_answer DESC) AS VARCHAR(50))) AS Q_NAME,option_answer
								FROM winktag_customer_survey_answer_detail AS T1 WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID
							) AS T
							PIVOT (MAX(option_answer) FOR Q_NAME IN (Q1, Q2)) AS T2) as Q1,

				(SELECT Q2 FROM
							(
								SELECT T1.customer_id  ,('Q' + CAST(ROW_NUMBER() OVER(PARTITION BY T1.CUSTOMER_ID ORDER BY option_answer DESC) AS VARCHAR(50))) AS Q_NAME,option_answer
								FROM winktag_customer_survey_answer_detail AS T1 WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID
							) AS T
							PIVOT (MAX(option_answer) FOR Q_NAME IN (Q1, Q2)) AS T2) as Q2

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
				SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at,'' as Q1, '' as Q2  from winktag_customer_action_log 
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
				SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at,'' as Q1, '' as Q2  from winktag_customer_action_log 
				WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
				) as T1
				-----table1

				UNION
	
				-----table2
				SELECT C.campaign_id,C.customer_id,C.points,C.GPS_location,C.ip_address,C.created_at,

				(SELECT Q1 FROM
							(
								SELECT T1.customer_id  ,('Q' + CAST(ROW_NUMBER() OVER(PARTITION BY T1.CUSTOMER_ID ORDER BY option_answer DESC) AS VARCHAR(50))) AS Q_NAME,option_answer
								FROM winktag_customer_survey_answer_detail AS T1 WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID
							) AS T
							PIVOT (MAX(option_answer) FOR Q_NAME IN (Q1, Q2)) AS T2) as Q1,

				(SELECT Q2 FROM
							(
								SELECT T1.customer_id  ,('Q' + CAST(ROW_NUMBER() OVER(PARTITION BY T1.CUSTOMER_ID ORDER BY option_answer DESC) AS VARCHAR(50))) AS Q_NAME,option_answer
								FROM winktag_customer_survey_answer_detail AS T1 WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID
							) AS T
							PIVOT (MAX(option_answer) FOR Q_NAME IN (Q1, Q2)) AS T2) as Q2

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
END



