
CREATE Proc [dbo].[Get_HOF_Report]
AS

BEGIN
	SELECT a.qr_code,a.created_at,a.points,c.customer_id,c.first_name +' '+c.last_name as name ,c.email from customer_earned_points as a,customer as c 
	WHERE a.customer_id = c.customer_id AND qr_code like 'popo%'
    ORDER BY created_at DESC
END


