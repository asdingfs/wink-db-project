

CREATE VIEW [dbo].[VW_FULL_PAGE]
AS
select CUSTOMER_ID,cast(created_at as date) as date
from popup_ads_tracker
GROUP BY cast(created_at as date),customer_id
