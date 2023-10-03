CREATE VIEW [dbo].[VW_WINK_TO_EVOUCHER]
AS
select CUSTOMER_ID,cast(created_at as date) as date  
from customer_earned_evouchers
GROUP BY cast(created_at as date),customer_id
