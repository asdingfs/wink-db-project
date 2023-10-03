CREATE FUNCTION VW_Get_Disabled_Account (@created_from  datetime, @created_to datetime)
RETURNS TABLE
AS
RETURN
select distinct customer.customer_id  from customer where
				status = 'disable'
				and 
				(( customer_id in 
				 (select c.customer_id from action_log as a
				join custmer_old_detail_log as b
				on a.action_id = b.action_id 
				and b.Status ='enable'
				join custmer_deletion_log as c
				on c.action_id = a.action_id
				and c.Status = 'disable'
				where cast(a.action_time as date) >= CAST(@created_from as date)
				and cast(a.action_time as date) <= CAST(@created_to as date)))

				OR (customer_id in (select customer_id from System_Log where action_status ='disable'
				and  cast(created_at as date) >= CAST(@created_from as date)
				and cast(created_at as date) <= CAST(@created_to as date))))