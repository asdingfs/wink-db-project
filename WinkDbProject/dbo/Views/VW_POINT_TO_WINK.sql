

CREATE VIEW [dbo].[VW_POINT_TO_WINK]
AS
select CUSTOMER_ID,cast(created_at as date) as date  
from customer_earned_winks
GROUP BY cast(created_at as date),customer_id 
