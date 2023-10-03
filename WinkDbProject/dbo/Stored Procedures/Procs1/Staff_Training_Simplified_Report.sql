CREATE PROC [dbo].[Staff_Training_Simplified_Report]
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
			SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status],
			T.customer_id,T.GPS_location,T.ip_address,T.created_at,
			T.Q1, T.score, T.progress
			FROM(
				SELECT  * FROM  
					(
						SELECT customer_id, [location] as GPS_location,ip_address,created_at, '' as Q1, 0 as score, 0 as progress
						from winktag_customer_action_log 
						WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0 

					) as T1
							-----table1
					UNION 

					SELECT C.customer_id,C.GPS_location,C.ip_address,C.created_at,

					(
						SELECT TOP(1) answer
						FROM winktag_customer_survey_answer_detail AS T1 
						WHERE T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1'
						AND T1.created_at >= C.created_at
						AND T1.customer_id = C.customer_id
						ORDER BY T1.created_at
					) as Q1,
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
					)  as score,
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
			AND (@wid is null or TEMP.wid like '%'+@wid+'%')
			AND (@gender is null or TEMP.gender like @gender+'%')
			AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
			AND (@status is null or TEMP.[status] = @status)
			AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date)
		)
		order by temp.no desc
	END
	
END



