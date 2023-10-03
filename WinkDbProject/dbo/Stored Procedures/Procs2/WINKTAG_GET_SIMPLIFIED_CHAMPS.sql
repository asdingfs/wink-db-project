CREATE PROC [dbo].[WINKTAG_GET_SIMPLIFIED_CHAMPS]
(
	@customer_name varchar(200),
	@email varchar(200),
	@gender varchar(200),
	@customer_id int,
	@start_date varchar(50),
	@end_date varchar(50),
	@winktag_report varchar(50),
	@wid varchar(50),
	@sticker varchar(50),
	@status varchar(50),
	@registration varchar(10),
	@game varchar(10),
	@leader varchar(10)
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

	IF(@sticker is null or @sticker ='')
		SET @sticker = NULL
	IF(@registration is null or @registration='')
		SET @registration = NULL

	IF(@game is null or @game='')
		SET @game = NULL

	IF(@leader is null or @leader='')
		SET @leader = NULL
	
	
	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
		RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)

		IF(@CAMPAIGN_ID = 109)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT  ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at,
					T.Q1 as pre_registration, T.leader, T.Q2 as sticker
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT customer_id,0 as points,location as GPS_location,ip_address,created_at, 
						
						(
							SELECT answer FROM winktag_customer_survey_answer_detail
							WHERE campaign_id = @CAMPAIGN_ID and question_no = 'Q1' and customer_id = T2.customer_id
						) as Q1, 
						(
							SELECT 'Yes' FROM viral_leaders AS T1
							WHERE customer_id = T2.customer_id and T1.campaign_id = @CAMPAIGN_ID 
						) as leader, 
						'' as Q2
						from winktag_customer_action_log as T2
							WHERE (campaign_id = @CAMPAIGN_ID or campaign_id = 111) and survey_complete_status = 0 and (@customer_id is null or customer_id = @customer_id)
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.customer_id,
						(SELECT points from winktag_customer_earned_points where customer_id = C.customer_id and campaign_id = 111)
						as points,
						MAX(C.GPS_location),MAX(C.ip_address),MAX(C.created_at) as created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' 
						) as Q1,
						(
							SELECT 'Yes' FROM viral_leaders AS T1
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID 
						) as leader,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = 111 and T1.question_no = 'Q1' 
						) as Q2

						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID or C.campaign_id = 111
						group by C.customer_id
						-----table2


					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
					WHERE (
							@registration is null 
							or (@registration = 'Yes' AND T.Q1 = @registration)  
							or (@registration = '0' AND T.Q1 is null)
						)
					AND (
							@game is null 
							or (@game = 'Yes' AND T.Q2 != '')  
							or (@game = '0' AND (T.Q2 = '' or T.Q2 is null))
					)
					AND (@sticker is null or T.Q2 = @sticker)
					AND (
							@leader is null 
							or (@leader = 'Yes' AND T.leader != '')  
							or (@leader = '0' AND (T.leader = '' or T.leader is null))
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
END



