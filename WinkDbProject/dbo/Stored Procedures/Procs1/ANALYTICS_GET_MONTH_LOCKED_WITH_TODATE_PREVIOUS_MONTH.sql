CREATE PROC [dbo].[ANALYTICS_GET_MONTH_LOCKED_WITH_TODATE_PREVIOUS_MONTH]
@month varchar(10),--for example, 2016-02
@total_locked int output

AS

BEGIN

declare @date varchar(20)= @month
declare @current_month varchar(10) = @date --for example, 2016-02
declare @end_date_of_prev_month date = EOMONTH(DATEADD(MONTH,-1,cast(@date+'-01' as date)))
declare @end_date_of_current_month date = EOMONTH(cast(@date+'-01' as date))

SET @total_locked = 
(
	select count(distinct locked.customer_id) from
	(
		--1) locked customer to date
		select distinct locked.customer_id from
		(
			select distinct temp_disable.customer_id from
			(
				select T1.customer_id,action_time
						from custmer_old_detail_log T1 
						inner join action_log T2
						on T1.action_id = T2.action_id
						inner join custmer_deletion_log T3
						on T3.action_id = T1.action_id
						and T1.Status = 'enable'
						and cast(action_time as date) <= @end_date_of_current_month
						and T3.Status = 'disable'

						union

						select customer_id,created_at from System_Log where action_status = 'disable'
						and cast(created_at as date) <= @end_date_of_current_month
			) as temp_disable left join

			(
				select * from
				(
					select T1.customer_id,action_time
							from custmer_old_detail_log T1 
							inner join action_log T2
							on T1.action_id = T2.action_id
							inner join custmer_deletion_log T3
							on T3.action_id = T1.action_id
							and T1.Status = 'disable'
							and cast(action_time as date) <= @end_date_of_current_month
							and T3.Status = 'enable'
				) as temp2
			) temp_enable 
			on temp_disable.customer_id = temp_enable.customer_id
			where (temp_disable.action_time > temp_enable.action_time or temp_enable.customer_id is null)
		) as locked inner join customer
		on locked.customer_id = customer.customer_id
		where customer.group_id in (13,14) and cast(created_at as date)<=cast(@end_date_of_prev_month as date)
	) locked left join

	--exclude active user for current month
	(
		select distinct temp_action.customer_id from
		--1) customer action
		(
			select cust.customer_id,summ.customer_action_date from customer as cust left join customer_action_log_summary as summ
			on cust.customer_id = summ.customer_id
			where cast(cust.created_at as date) <= @end_date_of_prev_month 
			and cust.group_id in (13,14)
			and LEFT(CONVERT(VARCHAR(10), customer_action_date, 126), 7) = @current_month
		) as temp_action left join

		--2) locked customer for the month
		(
			select * from
			(
				select temp_disable.customer_id,temp_disable.action_time from
				(
					select T1.customer_id,action_time
										from custmer_old_detail_log T1 
										inner join action_log T2
										on T1.action_id = T2.action_id
										inner join custmer_deletion_log T3
										on T3.action_id = T1.action_id
										and T1.Status = 'enable'
										and LEFT(CONVERT(VARCHAR(10), action_time, 126), 7) = @date
										and T3.Status = 'disable'

										union

										select customer_id,created_at from System_Log where action_status = 'disable'
										and LEFT(CONVERT(VARCHAR(10), created_at, 126), 7) = @date
				) as temp_disable left join

				(
					select * from
					(
						select T1.customer_id,action_time
											from custmer_old_detail_log T1 
											inner join action_log T2
											on T1.action_id = T2.action_id
											inner join custmer_deletion_log T3
											on T3.action_id = T1.action_id
											and T1.Status = 'disable'
											and LEFT(CONVERT(VARCHAR(10), action_time, 126), 7) = @date
											and T3.Status = 'enable'
					) as temp2
				) temp_enable 
				on temp_disable.customer_id = temp_enable.customer_id
				where (temp_disable.action_time > temp_enable.action_time or temp_enable.customer_id is null)
			) as current_month_locked

		) current_month_locked
		on temp_action.customer_id = current_month_locked.customer_id
		where ((cast(temp_action.customer_action_date as date) > cast(current_month_locked.action_time as date)) or current_month_locked.customer_id is null)
	) active on locked.customer_id = active.customer_id
	where active.customer_id is null
)

END
