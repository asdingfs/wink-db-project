CREATE PROC [dbo].[ANALYTICS_CALCULATE_BY_MONTH]
@date varchar(20)--e.g 2016-02

AS

BEGIN

	declare @registered_customer_todate int
	declare @new_customer int
	declare @active_user int
	declare @churned int
	declare @resurrected int
	declare @locked_todate_prev_month int
	declare @locked_todate_current_month int
	declare @retention decimal(10,2)
	declare @quick_ratio decimal(10,2)
	
	declare @tmp int

	declare @current_month varchar(10) = @date
	declare @end_date_of_current_month date = EOMONTH(cast(@current_month+'-01' as date))
	declare @business_date date = cast(dateadd(day,-1,(select today from VW_CURRENT_SG_TIME)) as date)

	----------------------
	EXEC ANALYTICS_GET_MONTH_TOTAL_REGISTERED_CUSTOMER_TODATE @current_month,@registered_customer_todate output

	EXEC ANALYTICS_GET_MONTH_NEW @current_month,@new_customer output

	EXEC ANALYTICS_GET_MONTH_ACTIVE @current_month,@active_user output

	EXEC ANALYTICS_GET_MONTH_CHURNED @current_month,@churned output

	EXEC ANALYTICS_GET_MONTH_RESURRECTED @current_month,@resurrected output

	EXEC ANALYTICS_GET_MONTH_LOCKED_WITH_TODATE_PREVIOUS_MONTH @current_month,@locked_todate_prev_month output

	EXEC ANALYTICS_GET_MONTH_LOCKED_WITH_TODATE_CURRENT_MONTH @current_month,@locked_todate_current_month output

	-->churned---------------------------------------
	/*check end of the month or not*/
	
	if @date = LEFT(CONVERT(VARCHAR(10), @business_date, 126), 7)
	begin
		if @business_date != EOMONTH(cast(@date+'-01' as date))--end of the month
			set @churned = 0
		else
			EXEC ANALYTICS_GET_MONTH_INSERT_CHURNED_PREV_MONTH @current_month
	end
	
	/*check end of the month or not*/
	-------------------------------------------------


	/*for trip*/
	EXEC ANALYTICS_GET_CHURNED_FOR_TRIP @current_month
	/*for trip*/



	set @tmp = 
		(
			select count(distinct customer_id) as total from customer
			where cast(created_at as date) <= EOMONTH(DATEADD(month,-1,cast((@date+'-01') as date)))
			and group_id in (13,14)	
		)
	
	-->retention---------------------------------------
	if @tmp = 0
		set @retention = 0.0
	else
	begin
		set @retention = 
		(
			cast(((@tmp - @churned)/cast(@tmp as decimal(12,2))) as decimal(12,2))	
		)
	end

	-->quick ratio---------------------------------------
	if @churned = 0
		set @quick_ratio = 0.00
	else
		set @quick_ratio = (select cast((@new_customer+@resurrected)/cast(@churned as decimal(12,2)) as decimal (12,2)))
	------------------------------------------------------------------------------------------------------------------------------

	select year(@end_date_of_current_month) as year, @current_month as period, @registered_customer_todate as registered_customer_todate, @new_customer as new_customer, @active_user as active_user, @churned as churned, @resurrected as resurrected, @locked_todate_prev_month as locked_todate_prev_month, @locked_todate_current_month as locked_todate_current_month, @retention as retention, @quick_ratio as quick_ratio,(select today from VW_CURRENT_SG_TIME) as created_at,(select today from VW_CURRENT_SG_TIME) as updated_at

	
	IF NOT EXISTS (SELECT * FROM Cohort_MAU_Chart WHERE period = @current_month)
	BEGIN

		INSERT INTO [dbo].[Cohort_MAU_Chart]
           ([year]
           ,[period]
           ,[registered_customer_todate]
           ,[new_customer]
           ,[active_user]
           ,[churned]
           ,[resurrected]
           ,[locked_todate_prev_month]
           ,[locked_todate_current_month]
           ,[retention]
           ,[quick_ratio]
           ,[created_at]
           ,[updated_at])
		VALUES
           (year(@end_date_of_current_month),@current_month,@registered_customer_todate,@new_customer,@active_user,@churned,@resurrected,@locked_todate_prev_month,@locked_todate_current_month,@retention,@quick_ratio,(select today from VW_CURRENT_SG_TIME),(select today from VW_CURRENT_SG_TIME))

	END
	
END