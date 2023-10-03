CREATE PROCEDURE [dbo].[Get_Top_Customer_Redeemed_Points_To_Winks]
AS
BEGIN
Select Top 5  customer_earned_winks.earned_winks_id,

customer_earned_winks.total_winks,customer_earned_winks.redeemed_points,
customer_earned_winks.created_at,customer_earned_winks.merchant_id,
merchant.first_name as m_first_name,merchant.last_name as m_last_name,
customer.first_name as c_first_name, customer.last_name as c_last_name
 from customer_earned_winks ,customer,merchant
where customer_earned_winks.merchant_id = merchant.merchant_id
And customer_earned_winks.customer_id = customer.customer_id
ORDER BY customer_earned_winks.earned_winks_id DESC
END
