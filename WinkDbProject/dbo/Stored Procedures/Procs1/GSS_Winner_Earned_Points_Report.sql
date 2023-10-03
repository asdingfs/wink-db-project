

CREATE Proc [dbo].[GSS_Winner_Earned_Points_Report]

AS

BEGIN
	SELECT customer.customer_id,(customer.first_name+' '+customer.last_name)as name,customer.email,customer_earned_points.qr_code,customer_earned_points.points,customer_earned_points.created_at FROM customer_earned_points,customer WHERE customer_earned_points.customer_id = customer.customer_id and qr_code like 'GSS%'
	return;
END

