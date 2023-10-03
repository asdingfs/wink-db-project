
CREATE PROC [dbo].[ANALYTICS_INSERT_CUSTOMER_ACTION_LOG_BY_DATE]

AS

BEGIN
	
	declare @business_date date = cast(dateadd(day,-1,(select today from VW_CURRENT_SG_TIME)) as date)
	declare @date varchar(20) = LEFT(CONVERT(VARCHAR(10),@business_date, 126), 7)


	truncate table customer_action_log_summary--clear customer action log data
	
	if not exists(select * from customer_action_log_summary)
	BEGIN

		INSERT INTO customer_action_log_summary(customer_id,customer_action_date,created)

		select temp.customer_id,temp.customer_action_date,(select today from VW_CURRENT_SG_TIME) as created_at from
		(
		select temp.customer_id,cast(temp.action_date as date) as customer_action_date,count(*) as action_date from
		(

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from customer_action_log where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp 

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from customer_action_log_a where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp 

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from customer_action_log_b where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp 

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from customer_action_log_c where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp 

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from customer_action_log_d where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp 

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from customer_earned_points where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp 

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from customer_earned_winks where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from customer_earned_evouchers where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from wink_gate_points_earned where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from
		eVoucher_transaction where customer_id is not null and customer_id != ''
		group by customer_id, cast(created_at as date)
		-- customer_earned_evouchers where customer_id is not null and customer_id != '' and used_status = 1 group by customer_id, cast(created_at as date)
		) as temp

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from eVoucher_verification where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

		union

		select * from (
		select customer_id,cast(business_date as date) as action_date
		,count(*) as count from wink_canid_earned_points where customer_id is not null and customer_id != '' group by customer_id, cast(business_date as date)) as temp

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from can_id where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from footer_ads_tracker where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from popup_ads_tracker where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from largebanner_ads_tracker where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from winktag_ads_tracker where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from winktag_customer_action_log where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from customer_read_news where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from wink_app_customer_action_log where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

		union

		select * from (
		select customer_id,cast(created_at as date) as action_date
		,count(*) as count from customer where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

		) as temp group by temp.customer_id, cast(temp.action_date as date)

		) as temp where cast(temp.customer_action_date as date) <= @business_date order by temp.customer_action_date asc

		/*********daily run*************/
		IF @@ROWCOUNT > 0
		BEGIN

				if exists(select * from Cohort_MAU_Chart where period = @date)
				begin
					delete from Cohort_MAU_Chart where period =  @date
				end

				EXEC ANALYTICS_CALCULATE_BY_MONTH @date

		END
		/*********daily run*************/
	END

END
