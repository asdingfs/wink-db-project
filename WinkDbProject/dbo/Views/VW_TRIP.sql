

CREATE VIEW [dbo].[VW_TRIP]
AS
select CUSTOMER_ID,cast(business_date as date) as date 
from wink_canid_earned_points
GROUP BY cast(business_date as date),customer_id
