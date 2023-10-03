

CREATE PROCEDURE [dbo].[Insert_Nets_CanId_Earned_Points]
	(@can_id varchar (150),
	  @business_date datetime ,
	  @total_tabs int ,
	  @total_points decimal(10,2),
	  @created_at datetime
	  )
	  
AS
BEGIN
DECLARE @customer_id  int 

--- Card type 02 is top up
	--IF EXISTS (select can_id.customer_id from can_id where can_id.customer_canid = @can_id)
	IF EXISTS (select can_id.customer_id from can_id where can_id.customer_canid = @can_id
	and can_id.customer_id IN (select customer.customer_id from customer where customer.status='enable')
	)
		BEGIN
		set @customer_id = (select can_id.customer_id from can_id where can_id.customer_canid = @can_id)
	INSERT INTO nonstop_net_canid_earned_points 
    (can_id,business_date,total_tabs,total_points,created_at,customer_id)
    VALUES (@can_id,@business_date,@total_tabs,@total_points,@created_at,@customer_id)
		END
END



