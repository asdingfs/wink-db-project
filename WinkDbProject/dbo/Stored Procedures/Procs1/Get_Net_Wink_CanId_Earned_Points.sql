
CREATE PROCEDURE Get_Net_Wink_CanId_Earned_Points
(@fromdate datetime,
 @todate datetime
 )
AS
BEGIN
	IF(@fromdate IS NOT NULL and @todate IS NOT Null)
	BEGIN
	Select w.id,w.can_id,w.business_date,w.total_tabs,w.total_points,w.created_at,
	w.customer_id,c.email,(c.first_name+''+c.last_name)as name from wink_net_canid_earned_points as w,customer as c
	where w.customer_id = c.customer_id
	
	END
	Else 
	BEGIN
		Select w.id,w.can_id,w.business_date,w.total_tabs,w.total_points,w.created_at,
	w.customer_id,c.email,(c.first_name+''+c.last_name)as name from wink_net_canid_earned_points as w,customer as c
	where w.customer_id = c.customer_id
	And CAST(w.created_at as date) >= CAST(@fromdate as date)
	And  CAST(w.created_at as date) <= CAST(@todate as date)
	END
END
