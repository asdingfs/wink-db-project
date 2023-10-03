

CREATE VIEW [dbo].[VW_EVOUCHER]
AS
select CUSTOMER_ID,cast(created_at as date) as date
from eVoucher_transaction
GROUP BY cast(created_at as date),customer_id
