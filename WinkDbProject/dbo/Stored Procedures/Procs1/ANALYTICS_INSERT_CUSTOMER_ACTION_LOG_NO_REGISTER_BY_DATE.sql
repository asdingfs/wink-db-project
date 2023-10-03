
CREATE PROC [dbo].[ANALYTICS_INSERT_CUSTOMER_ACTION_LOG_NO_REGISTER_BY_DATE]

AS

BEGIN

	declare @date varchar(20) = LEFT(CONVERT(VARCHAR(10),cast(dateadd(day,-1,(select today from VW_CURRENT_SG_TIME)) as date), 126), 7)

	if not exists (select * from customer_action_log_summary_no_register where cast(customer_action_date as date) = cast(dateadd(day,-1,(select today from VW_CURRENT_SG_TIME)) as date))
	BEGIN

		INSERT INTO customer_action_log_summary_no_register(customer_id,customer_action_date,created)

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
		,count(*) as count 
		from eVoucher_transaction where customer_id is not null and customer_id != ''
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
		,count(*) as count from customer_read_news where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

		) as temp group by temp.customer_id, cast(temp.action_date as date)

		) as temp where cast(temp.customer_action_date as date) = cast(dateadd(day,-1,(select today from VW_CURRENT_SG_TIME)) as date) order by temp.customer_action_date asc

		/*********daily run*************/
		/*
		IF @@ROWCOUNT > 0
		BEGIN

				if exists(select * from Cohort_MAU_Chart where period = @date)
				begin
					delete from Cohort_MAU_Chart where period =  @date
				end

				insert into Cohort_MAU_Chart 

				select year(cast(dateadd(day,-1,(select today from VW_CURRENT_SG_TIME)) as date)),period,new_customer,churned as churned,resurrected,retention, (select cast((t1.new_customer+t1.resurrected)/cast(t1.churned as decimal(12,2)) as decimal (12,2))) as quick_ratio, (select today from VW_CURRENT_SG_TIME),(select today from VW_CURRENT_SG_TIME),active_user from
				(
					select @date as period,

					(
						select count(*) as total_customer FROM customer where LEFT(CONVERT(VARCHAR(10), created_at, 126), 7) = @date
					) new_customer,

					(
						select count(distinct customer_id) from customer_action_log_summary_no_register
						where LEFT(CONVERT(VARCHAR(10), customer_action_date, 126),7) = LEFT(CONVERT(VARCHAR(10), dateadd(MONTH,-1,cast(@date+'-01' as date)), 126),7)
					) active_user,

					(
						select count(distinct customer_id) from VW_ACTIVE_CUSTOMER where cast(created_at as date) <= EOMONTH(DATEADD(MONTH,-4,cast(@date+'-01' as date)))
						and customer_id not in
							(
								select distinct customer_id from VW_ACTIVE_CUSTOMER_SUMMARY_NO_REGISTER
								where customer_action_date >= DATEADD(MONTH,-3,cast((@date+'-01') as date))
								and customer_action_date <= DATEADD(MONTH,-1,EOMONTH(cast((@date+'-01') as date)))
							)
					) as churned,

					(
						select count(distinct customer_id) from VW_ACTIVE_CUSTOMER_SUMMARY_NO_REGISTER
						where LEFT(CONVERT(VARCHAR(10), customer_action_date, 126), 7) = @date
						and customer_id not in
							(
								select customer_id from VW_ACTIVE_CUSTOMER where LEFT(CONVERT(VARCHAR(10), created_at, 126), 7) = @date
							)
						and customer_id in
							(
								select distinct customer_id from VW_ACTIVE_CUSTOMER where cast(created_at as date) <= EOMONTH(DATEADD(MONTH,-4,cast(@date+'-01' as date)))
								and customer_id not in
									(
										select distinct customer_id from VW_ACTIVE_CUSTOMER_SUMMARY_NO_REGISTER
										where customer_action_date >= DATEADD(MONTH,-3,cast((@date+'-01') as date))
										and customer_action_date <= DATEADD(MONTH,-1,EOMONTH(cast((@date+'-01') as date)))
									)
							) 
					) as resurrected,

					(
						cast((
							(
								(
									select count(distinct customer_id) as total from VW_ACTIVE_CUSTOMER
									where cast(created_at as date) <= EOMONTH(DATEADD(month,-1,cast((@date+'-01') as date)))	
								) 
								-
								(
									select count(distinct customer_id) from VW_ACTIVE_CUSTOMER where cast(created_at as date) <= EOMONTH(DATEADD(MONTH,-4,cast(@date+'-01' as date)))
									and customer_id not in
										(
											select distinct customer_id from VW_ACTIVE_CUSTOMER_SUMMARY_NO_REGISTER
											where customer_action_date >= DATEADD(MONTH,-3,cast((@date+'-01') as date))
											and customer_action_date <= DATEADD(MONTH,-1,EOMONTH(cast((@date+'-01') as date)))
										)
								)
							)
							/
							cast((
									select count(distinct customer_id) as total from VW_ACTIVE_CUSTOMER
									where cast(created_at as date) <= EOMONTH(DATEADD(month,-1,cast((@date+'-01') as date)))	
							) as decimal(12,2))
						) as decimal(12,2))
					) as retention
				) as T1

		END
		*/
		/*********daily run*************/
	END

END

