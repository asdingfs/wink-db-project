
CREATE PROCEDURE [dbo].[Get_Customer_CANID_Log_By_Customer_ID_Bak]
	(@customer_id int)
AS
BEGIN

select wink_canid_earned_points.can_id,wink_canid_earned_points.business_date,
wink_canid_earned_points.id,
wink_canid_earned_points.total_tabs,wink_canid_earned_points.total_points,
customer.first_name,customer.last_name,customer.customer_id
from wink_canid_earned_points,customer
where wink_canid_earned_points.customer_id=customer.customer_id
And wink_canid_earned_points.customer_id =@customer_id
order by wink_canid_earned_points.id desc


/*select wink_canid_earned_points.can_id,wink_canid_earned_points.business_date,
wink_canid_earned_points.id,
wink_canid_earned_points.total_tabs,wink_canid_earned_points.total_points,
customer.first_name,customer.last_name,customer.customer_id
from wink_canid_earned_points,can_id,customer
where wink_canid_earned_points.can_id=can_id.customer_canid
And can_id.customer_id=customer.customer_id
And customer.customer_id =@customer_id
order by wink_canid_earned_points.id desc*/

END

