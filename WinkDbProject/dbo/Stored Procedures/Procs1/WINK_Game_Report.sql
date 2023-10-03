CREATE PROC [dbo].[WINK_Game_Report]
(
	@customer_name varchar(200),
	@email varchar(200),
	@gender varchar(15),
	@customer_id int,
	@asset_name varchar(50),
	@start_date varchar(50),
	@end_date varchar(50),
	@winktag_report varchar(50),
	@winner varchar(5),
	@rdp_code varchar(10),
	@redemption_status varchar(5),
	@wid varchar(50),
	@status varchar(50),
	@validity varchar(10),
	@selection varchar(250)
)
AS

BEGIN

	DECLARE @CAMPAIGN_ID int

	SET @asset_name = RTRIM(LTRIM(@asset_name));
	
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

	IF (@asset_name is null or @asset_name = '')
	BEGIN
	 SET @asset_name = NULL;
	END
	ELSE
	BEGIN
	 SET @asset_name = LTRIM(RTRIM(@asset_name))
	END

	IF(@validity is null or @validity='')
		SET @validity = NULL

	IF(@winner is null or @winner ='')
		SET @winner = NULL

	IF(@rdp_code is null or @rdp_code ='')
		SET @rdp_code = NULL

	IF(@redemption_status is null or @redemption_status ='')
		SET @redemption_status = NULL
	IF(@wid is null or @wid ='')
		SET @wid = NULL

	IF(@status is null or @status='')
		SET @status = NULL
	IF(@selection is null or @selection ='')
		SET @selection = NULL
	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
		RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)

	IF(@CAMPAIGN_ID = 165)
	BEGIN
		SELECT * FROM 
		(
			SELECT ROW_NUMBER() OVER (Order by T.created_at ASC)AS no,c.first_name +' '+c.last_name as customer_name,c.gender as gender, (select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age, c.email,c.WID as wid, c.[status] as[status], c.customer_id as customer_id,
			T.points, T.winner, T.Q1, T.created_at
			
			FROM
			(
				-----table1
				SELECT * from
				(SELECT l.customer_id,0 as points, '0' as winner, l.created_at, '' as Q1
				from wink_game_customer_log as l, wink_game_session as s
					WHERE l.campaign_id = @CAMPAIGN_ID and l.session_id = s.id and survey_complete_status = 0
				) as T1
				-----table1

				UNION
	
				-----table2
				SELECT * from(
				select r.customer_id,r.point as points, r.winner as winner, r.created_at, o.option_type as Q1
				FROM wink_game_customer_result AS r, winktag_survey_option as o, wink_game_session as s 
				where r.campaign_id = @CAMPAIGN_ID and r.option_id = o.option_id and r.session_id = s.id
				) as T2
						
				-----table2
			) AS T 
				INNER JOIN customer as c ON T.customer_id = c.customer_id 
				WHERE ( @validity is null  
					or (@validity = 'Yes' AND T.Q1 != '')  
					or (@validity = '0' AND T.Q1 = '')
				)
				AND (@winner IS NULL OR winner like @winner)
				AND (@start_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
				AND (@selection IS NULL OR T.Q1 like '%'+@selection+'%')
		)as temp
		WHERE (@email is null or TEMP.email like '%'+@email+'%')
		and (@gender is null or TEMP.gender = @gender)
		AND (@wid is null or TEMP.wid like '%'+@wid+'%')
		AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
		AND (@customer_id is null or TEMP.customer_id = @customer_id)
		AND (@status is null or TEMP.[status] = @status)
		AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			
		order by temp.no desc
	END
	ELSE IF(@CAMPAIGN_ID = 134)
	BEGIN
		SELECT * FROM 
		(
			SELECT ROW_NUMBER() OVER (Order by T.created_at ASC)AS no,c.first_name +' '+c.last_name as customer_name,c.gender as gender, (select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age, c.email,c.WID as wid, c.status as status, c.customer_id as customer_id,
			T.asset_name, T.points, T.winner, T.Q1, T.created_at, T.redemption_code, T.redemption_status,T.redeemed_on, T.redemption_location
			
			FROM
					(

						-----table1
						SELECT * from
						(SELECT l.customer_id,0 as points, '0' as winner,l.created_at, '' as Q1, s.asset_name,
						'' as redemption_code, '' as redemption_status, NULL as redeemed_on, '' as redemption_location
						from wink_game_customer_log as l, wink_game_session as s
							WHERE l.campaign_id = @CAMPAIGN_ID and l.session_id = s.id and survey_complete_status = 0
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT * from(
						select r.customer_id,r.point as points, r.winner as winner, r.created_at, o.option_answer as Q1, s.asset_name,
						r.redemption_code, r.redemption_status, r.redeemed_on, r.redemption_location
						FROM wink_game_customer_result AS r, winktag_survey_option as o, wink_game_session as s 
						where r.campaign_id = @CAMPAIGN_ID and r.option_id = o.option_id and r.session_id = s.id
						) as T2
						
						-----table2


					) AS T 
					INNER JOIN customer as c ON T.customer_id = c.customer_id 
						WHERE (@validity is null 
							or (@validity = 'Yes' AND T.Q1 != '')  
							or (@validity = '0' AND T.Q1 = ''))
							AND (@winner IS NULL OR winner like @winner)
							AND (@asset_name is null or asset_name  like '%'+@asset_name+'%')
							AND (@redemption_status IS NULL OR redemption_status like @redemption_status)
							AND (@rdp_code IS NULL OR redemption_code like'%'+@rdp_code+'%')
							AND (@start_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			)as temp
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



