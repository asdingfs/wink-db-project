
CREATE Proc [dbo].[Get_ASM_Report]

AS

BEGIN
	Select a.qr_code,a.created_at,a.points,c.customer_id,c.first_name +' '+c.last_name as name ,c.email from customer_earned_points as a,customer as c where
	a.customer_id = c.customer_id
	and
	
	 qr_code like 'SMA%'
     order by created_at desc
END

