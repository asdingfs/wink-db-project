


CREATE VIEW [dbo].[VW_VERIFICATION_CODE]
AS
select CUSTOMER_ID,cast(created_at as date) as date
from eVoucher_verification
GROUP BY cast(created_at as date),customer_id
