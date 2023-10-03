CREATE PROCEDURE [dbo].[Get_Customer_Winks_Log_By_Customer_ID]
	(@customer_id int)
AS
BEGIN
Select customer_earned_winks.customer_id,customer_earned_winks.merchant_id,

customer_earned_winks.redeemed_points,customer_earned_winks.total_winks,customer_earned_winks.created_at,
merchant.first_name as m_first_name , merchant.last_name as m_last_name,
customer.first_name as c_first_name, customer.last_name as c_last_name,customer.WID as wid
from customer_earned_winks , merchant,customer
Where customer_earned_winks.merchant_id = merchant.merchant_id
AND customer.customer_id = customer_earned_winks.customer_id
And customer_earned_winks.customer_id= @customer_id
Order By customer_earned_winks.earned_winks_id desc

END
