
CREATE PROCEDURE [dbo].[Customer_Travel_Report_performance_testing]
	(@customer_id int,
	@WID varchar(20),
	@customer_name varchar(200),
	@email varchar(200),
	@card_type int,
	@bank int,
	@can_id varchar(50),
	@source varchar(5),
	@start_date varchar(50),
	@end_date varchar(50))
AS
BEGIN

   -- disable ' xxx rows selcted'
	SET NOCOUNT ON
	-- use local variable to improve query performance.
	declare @start_date_local datetime,
	@end_date_local datetime

	IF (@start_date is null or @start_date = '')
		EXEC GET_CURRENT_SINGAPORT_DATETIME @start_date_local OUTPUT;
	ELSE
		set @start_date_local = @start_date
	IF (@end_date is null or @end_date = '')
		EXEC GET_CURRENT_SINGAPORT_DATETIME @end_date_local OUTPUT;;
	ELSE
		set @end_date_local = @end_date

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

SELECT * FROM(
SELECT ROW_NUMBER() OVER (Order by T.created_at DESC)AS no, 
		c.wid, c.customer_id, c.first_name +' '+c.last_name as customer_name, c.email,
		T.can_id, T.card_type, T.bank, T.[source], T.total_points, T.total_tabs, T.business_date, T.created_at

		FROM (
			select trip.can_id as can_id,trip.customer_id as customer_id, trip.id, null as card_type, null as bank, trip.total_tabs,

			CAST((trip.total_points +
			ISNULL((select nets.total_points from wink_net_canid_earned_points as nets 
			 where  (nets.customer_id =@customer_id)
			 and nets.can_id = trip.can_id
			 and CAST(nets.created_at as Date) = CAST (trip.created_at as Date)
			 ),0)) as int) as total_points,
			 'trip' as [source],
			 trip.business_date, trip.created_at
			from wink_canid_earned_points as trip
			where (@customer_id is null or trip.customer_id = @customer_id)
			AND ( @start_date_local is null or CAST(trip.business_date as Date) >= CAST(@start_date_local as Date))
			AND (  @end_date_local is null or CAST(trip.business_date as Date) <= CAST(@end_date_local as Date))
			
			UNION

			SELECT '' as can_id, spg.customer_id as customer_id,spg.id, spg.card_type as card_type, spg.bank as bank, spg.total_tabs, 
			spg.total_points as total_points,spg.[source] as [source],spg.business_date, spg.created_at
			FROM spg_earned_points as spg
			where (@customer_id is null or spg.customer_id = @customer_id)
			AND (@start_date_local is null or CAST(spg.business_date as Date) >= CAST(@start_date_local as Date))
			AND ( @end_date_local is null or CAST(spg.business_date as Date) <= CAST(@end_date_local as Date))
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
	
	
	order by TEMP.created_at desc

	



END

