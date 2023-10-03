create PROC [dbo].[ANALYTICS_INSERT_CURRENT_MONTH_RESURRECTED_USER_FOR_TRIP] 
@month varchar(10)--for example, 2016-02

AS

BEGIN

declare @date varchar(20)= @month
declare @current_month varchar(10) = @date --for example, 2016-02
declare @prev_month varchar(10) = LEFT(CONVERT(VARCHAR(10), EOMONTH(DATEADD(MONTH,-1,cast(@date+'-01' as date))), 126), 7)
declare @end_date_of_prev_month date = EOMONTH(DATEADD(MONTH,-1,cast(@date+'-01' as date)))

	truncate table customer_resurrected

	insert into customer_resurrected (customer_id,period,create_at)

	select distinct temp_action.customer_id,@date,(select * from VW_CURRENT_SG_TIME) from
	--1) total customer who has action in the current month are from pervious month churned customer
	(
		select prev.customer_id,current_month_active_user.customer_action_date from
		(
			select cust.customer_id,summ.customer_action_date from customer as cust left join customer_action_log_summary as summ
			on cust.customer_id = summ.customer_id
			where cast(cust.created_at as date) <= @end_date_of_prev_month 
			and cust.group_id in (13,14)
			and LEFT(CONVERT(VARCHAR(10), customer_action_date, 126), 7) = @current_month
		)current_month_active_user
		inner join analytics_pre_month_churned as prev
		on current_month_active_user.customer_id = prev.customer_id
		where prev.period = @prev_month
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

END