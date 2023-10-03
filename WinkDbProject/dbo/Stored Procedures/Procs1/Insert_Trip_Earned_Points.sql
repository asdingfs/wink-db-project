
CREATE PROCEDURE [dbo].[Insert_Trip_Earned_Points]
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

			IF(@@ROWCOUNT>0)
			BEGIN
				DECLARE @counter int=1;
				SET NOCOUNT OFF
				WHILE @counter<=@total_points
				BEGIN
					insert into nonstop_net_canid_earned_points 
					(customer_id ,created_at,business_date,can_id,card_type,total_tabs,total_points,updated_at,campaign_id)
					values (@customer_id,@created_at,@business_date,@can_id,'10',1,1,@current_date,201)
					set @counter = @counter + 1
				END
					select '1' as response_code , 'Successfully inserted' as response_message
					RETURN
			END

		END
	END

   
	select '0' as response_code , 'Data inserted already for today' as response_message


END
