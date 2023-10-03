
CREATE PROCEDURE [dbo].[Get_Customer_CANID_Log_By_Customer_ID]
	(@customer_id int)
AS
BEGIN

select wink_canid_earned_points.can_id,wink_canid_earned_points.business_date,
wink_canid_earned_points.id,
wink_canid_earned_points.total_tabs,CAST((wink_canid_earned_points.total_points +
ISNULL((select nets.total_points from wink_net_canid_earned_points as nets 
 where nets.customer_id =@customer_id
 and nets.can_id = wink_canid_earned_points.can_id
 and CAST(nets.created_at as Date) = CAST (wink_canid_earned_points.created_at as Date)
 ),0)) as int) as total_points
,
customer.first_name,customer.last_name,customer.customer_id
from wink_canid_earned_points,customer
where wink_canid_earned_points.customer_id=customer.customer_id
And wink_canid_earned_points.customer_id =@customer_id
order by wink_canid_earned_points.business_date desc

END

