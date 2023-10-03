

CREATE VIEW [dbo].[VW_REGISTER]
AS
select CUSTOMER_ID,cast(created_at as date) as date 
from customer_action_log
where customer_action = 'register'
GROUP BY cast(created_at as date),customer_id 
