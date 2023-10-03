CREATE PROCEDURE [dbo].[Redeem_Promotion_By_Points]
	( 
	 @auth_token varchar(150),
	 @redeemed_points int,
	 @event_id int
	 )
AS
BEGIN
Declare @current_date datetime

Declare @redeemed_qty int

Declare @balanced_qty int

Declare @equilvalent_points int
Declare @total_avaiable_qty int

Declare @total_avaiable_points_toredeem int

Declare @customer_id int

Declare @Large_WEBSITE_URL varchar(150)
Declare @Large_IMAGE_Name varchar(200)
Declare @campaign_id int 



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

    SET @CAMPAIGN_ID =1 --- Set Default Global Campagin ID

    SELECT @Large_IMAGE_Name = large_image_name ,@Large_WEBSITE_URL = large_image_url FROM campaign_large_image WHERE CAMPAIGN_ID = @CAMPAIGN_ID
    and large_image_status = '1'
  
    select @customer_id = customer_id from customer where customer.auth_token =@auth_token
	
	Select @equilvalent_points = points,
	@total_avaiable_qty = a.total_quantity - a.redeemed_qty
	 from winkpoint_promotion as a
	
	Set @redeemed_qty = @redeemed_points/@equilvalent_points
	
	
	
	
	if(@redeemed_qty>@total_avaiable_qty)
	BEGIN
	Set @total_avaiable_points_toredeem =@total_avaiable_qty*@equilvalent_points
	
    Select 0 as success , 'Fully redeeemed' as response_message
	

	
	END
	ELSE
	BEGIN
	
	
	update winkpoint_promotion set redeemed_points = ISNULL(redeemed_points,0)+ @redeemed_points,
	redeemed_qty = ISNULL(redeemed_qty,0)+ @redeemed_qty where event_id = @event_id
	and @redeemed_qty <= total_quantity-redeemed_qty
	and (select total_points-used_points-confiscated_points from customer_balance as b where customer_id =@customer_id)
	>=@redeemed_points
	
	IF(@@ROWCOUNT >0)
	BEGIN
	Print ('Update 2')
	Print (@@ROWCOUNT)
	update customer_balance set used_points = used_points+@redeemed_points where customer_id = @customer_id
	and total_points-used_points-confiscated_points >= @redeemed_points 
	END
	
	IF(@@ROWCOUNT >0)
  	BEGIN
  	Print ('Update 3')
	Print (@@ROWCOUNT)
	  insert into winkpoint_promotion_redemption  (event_id,redeemed_points,customer_id,redeemed_qty,created_at)
	  values (@event_id,@redeemed_points,@customer_id,@redeemed_qty,@current_date)
	 if(@@ROWCOUNT > 0)
	  BEGIN
	  
	      SELECT '1' as success, 'Successfully redeemed' as response_message,
	      total_points-used_points-confiscated_points as balanced_points,
	     @Large_IMAGE_Name as  large_image_name,@Large_WEBSITE_URL as large_website_url
	       from customer_balance
	      where customer_balance.customer_id = @customer_id
					
	   return

	  END
	  ELSE
	  BEGIN
	    Select 0 as success , 'Fail to redeem' as response_message
	    return
	  END
	END
	
	END
	
	
	
	
	
	--select @to

END




END


