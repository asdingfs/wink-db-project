

CREATE VIEW [dbo].[VW_SCAN] 
AS
SELECT CUSTOMER_ID,cast(created_at as date) as date 
FROM CUSTOMER_EARNED_POINTS 
GROUP BY cast(created_at as date),customer_id
