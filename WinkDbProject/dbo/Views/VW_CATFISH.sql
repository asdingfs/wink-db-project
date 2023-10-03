

CREATE VIEW [dbo].[VW_CATFISH]
AS
select CUSTOMER_ID,cast(created_at as date) as date
from footer_ads_tracker
GROUP BY cast(created_at as date),customer_id
