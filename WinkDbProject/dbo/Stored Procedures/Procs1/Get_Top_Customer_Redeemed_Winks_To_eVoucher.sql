﻿CREATE PROCEDURE [dbo].[Get_Top_Customer_Redeemed_Winks_To_eVoucher]
AS
BEGIN
Select Top 5 customer_earned_evouchers.eVoucher_code,customer_earned_evouchers.eVoucher_amount,
customer_earned_evouchers.redeemed_winks,customer_earned_evouchers.expired_date,
customer_earned_evouchers.customer_id,customer.first_name,customer.last_name
 from customer_earned_evouchers ,customer
where  customer_earned_evouchers.customer_id = customer.customer_id
ORDER BY customer_earned_evouchers.earned_evoucher_id DESC
END
