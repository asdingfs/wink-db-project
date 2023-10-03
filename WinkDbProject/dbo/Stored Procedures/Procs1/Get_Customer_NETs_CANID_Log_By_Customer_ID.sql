
CREATE PROCEDURE [dbo].[Get_Customer_NETs_CANID_Log_By_Customer_ID]
	(@customer_id int)
AS
BEGIN

select wink_net_canid_earned_points.can_id,wink_net_canid_earned_points.business_date,
wink_net_canid_earned_points.id,
wink_net_canid_earned_points.total_tabs,wink_net_canid_earned_points.total_points,
customer.first_name,customer.last_name,customer.customer_id
from wink_net_canid_earned_points,customer
where wink_net_canid_earned_points.customer_id=customer.customer_id
And wink_net_canid_earned_points.customer_id =@customer_id
order by wink_net_canid_earned_points.id desc

END

