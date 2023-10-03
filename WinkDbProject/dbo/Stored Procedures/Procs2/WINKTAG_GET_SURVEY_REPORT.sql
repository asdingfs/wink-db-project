
CREATE PROC [dbo].[WINKTAG_GET_SURVEY_REPORT]
(
	@customer_name varchar(200),
	@email varchar(200),
	@customer_id int,
	@start_date varchar(50),
	@end_date varchar(50),
	@winktag_report varchar(50)
)
AS

BEGIN


	if(@customer_name is null or @customer_name ='')
		set @customer_name = Null

	if(@email is null or @email ='')
		set @email = Null

	if(@customer_id is null or  @customer_id =''  or @customer_id =0)
		set @customer_id = Null

	if(@start_date is null or  @start_date ='')
		set @start_date = Null

	if(@end_date is null or  @end_date ='')
		set @end_date = Null

	DECLARE @CAMPAIGN_ID int;

	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
		RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)

		print @CAMPAIGN_ID

	SELECT * FROM 
	(--1 START
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC) AS no, T.*,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age FROM

		(
			-----table1
			SELECT * from
			(
			SELECT campaign_id,customer_id,0 as points,location as GPS_location,ip_address,created_at,'' as Q1, '' as Q2  from winktag_customer_action_log 
			WHERE campaign_id = @CAMPAIGN_ID and winktag_customer_action_log.customer_id NOT IN (select distinct customer_id from winktag_customer_survey_answer_detail
			where campaign_id = @CAMPAIGN_ID )
			) as T1
			-----table1

			UNION
	
			-----table2
			SELECT C.campaign_id,C.customer_id,0 as points,C.GPS_location,C.ip_address,C.created_at,

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
FROM winktag_customer_survey_answer_detail AS C
WHERE C.campaign_id = @CAMPAIGN_ID 
			--FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID 
			-----table2

		) AS T 
		INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id

	) AS TEMP----1 END
	WHERE (@email is null or TEMP.email like '%'+@email+'%')
	and (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
	and (@customer_id is null or TEMP.customer_id = @customer_id)
	order by temp.no desc
END


