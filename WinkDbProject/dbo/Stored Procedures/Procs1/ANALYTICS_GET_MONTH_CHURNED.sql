CREATE PROC [dbo].[ANALYTICS_GET_MONTH_CHURNED]
@month varchar(10),--for example, 2016-02
@total_churned int output

AS

BEGIN

declare @date varchar(20)= @month
declare @current_month varchar(10) = @date --for example, 2016-02
declare @end_date_of_prev_month date = EOMONTH(DATEADD(MONTH,-1,cast(@date+'-01' as date)))
declare @end_date_of_current_month date = EOMONTH(cast(@date+'-01' as date))

SET @total_churned =
(
	select count(distinct active_user.customer_id) from
	(
		select distinct customer_id from customer 
		where cast(created_at as date) <= @end_date_of_prev_month and group_id in (13,14)
		and customer_id not in
		(
			select distinct customer_id from customer_action_log_summary where LEFT(CONVERT(VARCHAR(10), customer_action_date, 126), 7) = @current_month
		)
	) active_user left join

	(
		--2) locked customer to date
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
	) locked
	on active_user.customer_id = locked.customer_id
	where locked.customer_id is null
)

END
