CREATE PROC [dbo].[WINKTAG_SCRATCH_CARD_REPORT]
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
	@winner varchar(50),
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

	IF(@gender is null or @gender ='')
	SET @gender = NULL

	IF(@customer_id = 0)
		SET @customer_id = NULL

	IF(@wid is null or @wid ='')
		SET @wid = NULL

	IF(@validity is null or @validity ='')
		SET @validity = NULL

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
	
	IF(@CAMPAIGN_ID = 110)
		BEGIN
			SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.customer_id,T.created_at,T.Q1, T.validity
					
					FROM

					(
						SELECT AL.customer_id, AL.created_at, '0' as validity,
						'' as Q1
						from winktag_customer_action_log as AL
						WHERE AL.campaign_id = @CAMPAIGN_ID
						AND AL.survey_complete_status = 0
						AND (@day IS NULL OR CAST(AL.created_at as Date) = CAST (@day as date))

				union

				SELECT C.customer_id,C.created_at, '1' as validity,
					

						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
							
						) as Q1


						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID	
						AND (@day IS NULL OR CAST(C.created_at as Date) = CAST (@day as date))
						AND C.additional_point_status = 0
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
					where  (@validity is null or T.validity like @validity)
					and (@winner is null or T.Q1 like '%'+@winner+'%')
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


