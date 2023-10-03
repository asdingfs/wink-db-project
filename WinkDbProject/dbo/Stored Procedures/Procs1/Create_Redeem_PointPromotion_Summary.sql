Create PROCEDURE [dbo].[Create_Redeem_PointPromotion_Summary]
	( 
	 @auth_token varchar(150),
	 @redeemed_points int,
	 @event_id int,
	 @redeemed_qty int
	 )
AS
BEGIN
Declare @current_date datetime
Declare @customer_id int

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

--- Get Current Event 

Set @event_id = (select event_id from winkpoint_promotion where 
CAST(@current_date as date) between CAST(event_start_date as date) and 
CAST(event_end_date as date) and event_status =1)

IF NOT EXISTS (select 1 from customer where customer.auth_token = @auth_token and status='enable')
BEGIN
select 0 as success , 'Customer is not authorized' as response_message
RETURN

END

IF( @event_id is not null and @event_id !=0)
BEGIN

     
    select @customer_id = customer_id from customer where customer.auth_token =@auth_token 
     insert into winkpoint_promotion_redemption_summary  (event_id,redeemed_points,customer_id,redeemed_qty,created_at)
	 values (@event_id,@redeemed_points,@customer_id,@redeemed_qty,@current_date)	
	
	
	
	--select @to

END




END


