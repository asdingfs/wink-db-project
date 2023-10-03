


CREATE PROCEDURE [dbo].[Insert_Nonstop_Net_CanId_Earned_Points]
	(@can_id varchar (50),
	@customer_id int,
	  @business_date datetime ,
	  @total_tabs int ,
	  @total_points decimal(10,2),
	  @created_at datetime,
	  @card_type varchar(50),
	  @campaign_id int = 0
	  )
	  
AS
BEGIN

--- Card type 02 is top up

	--IF EXISTS (select customer.customer_id from customer where customer.status='enable' and customer.customer_id=@customer_id)
	
		--BEGIN
	
	INSERT INTO [dbo].[nonstop_net_canid_earned_points]
    (can_id,business_date,total_tabs,total_points,created_at,customer_id, card_type,points_credit_status,points_expired_status,campaign_id)
    VALUES (@can_id,@business_date,@total_tabs,@total_points,@created_at,@customer_id,@card_type,0,'0',@campaign_id)
		--END
END
