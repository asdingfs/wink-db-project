
CREATE PROCEDURE [dbo].[Insert_CanId_Earned_Points]
	(@can_id varchar (150),
	  @business_date datetime ,
	  @total_tabs int ,
	  @total_points int,
	  @created_at datetime
	  )
	  
AS
BEGIN
DECLARE @customer_id  int 
DECLARE @current_date datetime
EXEC dbo.GET_CURRENT_SINGAPORT_DATETIME @current_date output
    IF NOT EXISTS (select 1 from wink_canid_earned_points where can_id =@can_id and CAST (business_date as DATE) = CAST (@business_date as DATE))
	BEGIN
	IF EXISTS (select can_id.customer_id from can_id where can_id.customer_canid = @can_id
	and can_id.customer_id IN (select customer.customer_id from customer where customer.status='enable')
	)
		BEGIN
		set @customer_id = (select can_id.customer_id from can_id where can_id.customer_canid = @can_id)
	INSERT INTO wink_canid_earned_points 
    (can_id,business_date,total_tabs,total_points,created_at,customer_id)
    VALUES (@can_id,@business_date,@total_tabs,@total_points,@created_at,@customer_id)
		END
	END
END

