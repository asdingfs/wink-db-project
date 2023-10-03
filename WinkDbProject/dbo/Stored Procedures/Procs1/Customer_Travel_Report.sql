
CREATE PROCEDURE [dbo].[Customer_Travel_Report]
	(@customer_id int,
	@WID varchar(20),
	@customer_name varchar(200),
	@email varchar(200),
	@card_type int,
	@bank int,
	@can_id varchar(50),
	@source varchar(5),
	@start_date varchar(50),
	@end_date varchar(50),
	@points_credit_status varchar(10),
	@points_expired_status varchar(10),
	@campaign_name varchar(250))
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


	IF(@customer_id = 0)
		SET @customer_id = NULL

	IF(@card_type = 0)
		SET @card_type = NULL

	IF(@bank = 0)
		SET @bank = NULL

	IF(@wid is null or @wid ='')
		SET @wid = NULL

	IF(@can_id is null or @can_id ='')
		SET @can_id = NULL

	IF(@source is null or @source ='')
		SET @source = NULL

	IF (@campaign_name = '' or @campaign_name = NULL)
		set @campaign_name = NULL;

	IF(@points_credit_status ='' or @points_credit_status =NULL)
	BEGIN
		SET @points_credit_status= NULL;
	END

	IF(@points_expired_status ='' or @points_expired_status =NULL)
	BEGIN
		SET @points_expired_status= NULL;
	END

	declare @points_expired_interval int = 24;
	DECLARE @current_date datetime
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

	SELECT * FROM(
		SELECT ROW_NUMBER() OVER (Order by T.created_at DESC)AS no, 
		c.wid, c.customer_id, c.first_name +' '+c.last_name as customer_name, c.email,
		T.can_id, T.card_type, T.bank, T.[source], T.total_points, T.total_tabs, T.business_date, T.created_at,
		T.points_credit_status, T.point_redemption_date, T.points_expired_on, T.points_expired_status, T.campaign_name
		FROM (
			select A.can_id, A.customer_id, A.id, null as card_type, null as bank, A.total_tabs,A.total_points,
			'trip' as [source], A.business_date, A.created_at,
			A.points_credit_status,A.point_redemption_date,(select dateadd(hh, @points_expired_interval, A.created_at)) as points_expired_on,A.points_expired_status,
			campaign.campaign_name
			from nonstop_net_canid_earned_points AS A, campaign as campaign
			where A.card_type like '10'
			AND A.campaign_id = campaign.campaign_id
			AND (@campaign_name IS NULL or campaign.campaign_name like '%'+@campaign_name +'%')
			AND (@customer_id is null or A.customer_id = @customer_id)
			AND (@start_date IS NULL OR CAST(A.business_date as Date) >= CAST(@start_date as Date))
			AND (@end_date IS NULL OR CAST(A.business_date as Date) <= CAST(@end_date as Date))
			AND (@can_id IS NULL or A.can_id like '%'+@can_id+'%')
			AND (@points_credit_status is null or A.points_credit_status = @points_credit_status)
			AND 
			(
				@points_expired_status is null  
				OR
				CASE WHEN @points_expired_status = '1' THEN (select dateadd(hh, @points_expired_interval, A.created_at))  END <= @current_date and A.points_credit_status = 0
				OR 
				CASE WHEN @points_expired_status = '0' THEN (select dateadd(hh, @points_expired_interval, A.created_at))  END > @current_date
			)

			UNION 

			select trip.can_id as can_id,trip.customer_id as customer_id, trip.id, null as card_type, null as bank, trip.total_tabs,
			CAST((trip.total_points +
			ISNULL((select nets.total_points from wink_net_canid_earned_points as nets 
			 where nets.customer_id =@customer_id
			 and nets.can_id = trip.can_id
			 and CAST(nets.created_at as Date) = CAST (trip.created_at as Date)
			 and card_type not like '10'
			 ),0)) as int) as total_points,
			 'trip' as [source],
			 trip.business_date, trip.created_at,
			0 as points_credit_status, NULL as point_redemption_date, NULL as points_expired_on, '' as points_expired_status, '' as campaign_name
			from wink_canid_earned_points as trip
			where (@customer_id is null or trip.customer_id = @customer_id)
			--start of wink go CMS (24 May onwards)
			AND (CAST(trip.business_date as Date)<='2022-05-23')
			--manual upload with wink go CMS
			AND (CAST(trip.business_date as Date)!='2022-05-19')
			AND (@start_date IS NULL OR CAST(trip.business_date as Date) >= CAST(@start_date as Date))
			AND (@end_date IS NULL OR CAST(trip.business_date as Date) <= CAST(@end_date as Date))
	

			UNION

			SELECT '' as can_id, spg.customer_id as customer_id,spg.id, spg.card_type as card_type, spg.bank as bank, spg.total_tabs, 
			spg.total_points as total_points,spg.[source] as [source],spg.business_date, spg.created_at,
			0 as points_credit_status, NULL as point_redemption_date, NULL as points_expired_on, '' as points_expired_status, '' as campaign_name
			FROM spg_earned_points as spg
			where (@customer_id is null or spg.customer_id = @customer_id)
			AND (@start_date IS NULL OR CAST(spg.business_date as Date) >= CAST(@start_date as Date))
			AND (@end_date IS NULL OR CAST(spg.business_date as Date) <= CAST(@end_date as Date))

		) as T
		INNER JOIN CUSTOMER as c ON T.customer_id = c.customer_id
	)
	AS TEMP

	WHERE (@customer_name is null or customer_name like '%'+@customer_name+'%') 
	AND (@customer_id is null or TEMP.customer_id = @customer_id)
	AND (@wid is null or TEMP.wid like '%'+@wid+'%')
	AND (@email is null or TEMP.email like '%'+@email+'%')
	AND (@card_type is null or TEMP.card_type = @card_type)
	AND (@bank is null or TEMP.bank = @bank)
	AND (@can_id is null or TEMP.can_id like '%'+@can_id+'%')
	AND (@source is null or TEMP.[source] like '%'+@source+'%')
	

	order by TEMP.[no] desc

	
	OPTION (OPTIMIZE for UNKNOWN);



END

