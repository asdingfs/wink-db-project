CREATE PROC [dbo].[WINKTAG_GET_SIMPLIFIED_REFERRAL_REPORT]
(
	@customer_name varchar(200),
	@email varchar(200),
	@gender varchar(200),
	@customer_id int,
	@start_date varchar(50),
	@end_date varchar(50),
	@campaign_id int,
	@wid varchar(50),
	@referrerWid varchar(50),
	@referrerName varchar(200),
	@status varchar(50),
	@selectedWeek  varchar(10)
)
AS

BEGIN

	
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

	IF(@referrerWid is null or @referrerWid ='')
		SET @referrerWid = NULL

	IF(@referrerName is null or @referrerName='')
		SET @referrerName = NULL

	IF (@selectedWeek is null or @selectedWeek = '')
		SET @selectedWeek = NULL;

	
	IF(@campaign_id = 151)
	BEGIN
		DECLARE @selectedStartDate datetime,
		@selectedEndDate datetime

		IF(@selectedWeek like '1')
		BEGIN
			SET @selectedStartDate = '2020-08-18 09:00:00.000';
			SET @selectedEndDate = '2020-08-24 08:59:59.999';
		END
		ELSE IF(@selectedWeek like '2')
		BEGIN
			SET @selectedStartDate = '2020-08-24 09:00:00.000';
			SET @selectedEndDate = '2020-08-25 08:59:59.999';
		END
		ELSE IF(@selectedWeek like '3')
		BEGIN
			SET @selectedStartDate = '2020-08-25 09:00:00.000';
			SET @selectedEndDate = '2020-08-26 08:59:59.999';
		END
		ELSE IF(@selectedWeek like '4')
		BEGIN
			SET @selectedStartDate = '2020-08-26 09:00:00.000';
			SET @selectedEndDate = '2020-08-27 08:59:59.999';
		END

		SELECT * FROM(
			SELECT  ROW_NUMBER() OVER (Order by a.CREATED_AT ASC)AS no,
			c.customer_id as customer_id, c.first_name +' '+c.last_name as customer_name,c.email,c.gender,
			(select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,c.WID as wid, c.[status] as [status],
			e.points as points, e.GPS_location as GPS_location, e.ip_address as ip_address,
			a.answer as referrerWid, a.created_at as created_at,
			(
				SELECT cc.first_name +' '+cc.last_name
				FROM customer as cc
				WHERE cc.WID like a.answer
			) as referrerName
			FROM customer as c,
			winktag_customer_survey_answer_detail as a,
			winktag_customer_earned_points as e
			WHERE a.campaign_id = @campaign_id
			AND e.campaign_id = @campaign_id
			AND c.customer_id = a.customer_id
			AND c.customer_id = e.customer_id
			AND (@selectedStartDate IS NULL OR (a.created_at BETWEEN @selectedStartDate AND @selectedEndDate))
		) as T
		WHERE (@email is null or T.email like '%'+@email+'%')
		and (@gender is null or T.gender = @gender)
		AND (@wid is null or T.wid like '%'+@wid+'%')
		AND (@customer_name is null or T.customer_name like '%'+@customer_name+'%') 
		AND (@customer_id is null or T.customer_id = @customer_id)
		AND (@status is null or T.[status] = @status)
		AND (@start_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
		AND (@referrerWid is null or T.referrerWid like '%'+@referrerWid+'%')
		AND (@referrerName is null or T.referrerName like '%'+@referrerName+'%')
		order by T.no desc
				
	END
END



