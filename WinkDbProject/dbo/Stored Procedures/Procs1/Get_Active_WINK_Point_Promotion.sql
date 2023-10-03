CREATE PROCEDURE [dbo].[Get_Active_WINK_Point_Promotion]
(@auth_token varchar(150)
)
AS
BEGIN
Declare @current_date datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

Declare @balance_points int
Declare @Large_WEBSITE_URL varchar(150)
Declare @Large_IMAGE_Name varchar(200)
Declare @customer_id int
Declare @campaign_id int
Declare @image_id int 

-- Check account locked
IF EXISTS (select 1 from customer where customer.auth_token = @auth_token and status ='disable')
     BEGIN
   
	 SELECT '3' as response_code, 'Your account is locked. Please contact customer service.' as response_message , 
	 0 as event_id
		RETURN 
	END-- END

---
 

IF Exists (select 1 from winkpoint_promotion where 
CAST(@current_date as date) between CAST(event_start_date as date) and 
CAST(event_end_date as date) and event_status =1)
BEGIN

-- Check Fully Redeemed 
IF Exists (select 1 from winkpoint_promotion where 
CAST(@current_date as date) between CAST(event_start_date as date) and 
CAST(event_end_date as date) and event_status =1 and total_quantity = redeemed_qty)

BEGIN
select 0 as event_id ,'Fully redeemed in current promotion.' as response_message,
'0' as response_code
Return

END

Set @customer_id =(select c.customer_id from customer as c where auth_token = @auth_token and status ='enable')

set @balance_points = (select total_points-used_points-confiscated_points from customer_balance where customer_id =@customer_id)

SET @CAMPAIGN_ID =1 --- Set Default Global Campagin ID

SELECT @Large_IMAGE_Name = large_image_name ,@Large_WEBSITE_URL = large_image_url,@image_id = id FROM campaign_large_image WHERE CAMPAIGN_ID = @CAMPAIGN_ID
and large_image_status = '1'

select w.event_id,Cast(w.points as int) as points ,Cast(@balance_points as int) as customer_balanced_points, @Large_IMAGE_Name as large_image_name, @Large_WEBSITE_URL as large_website_url
 ,@image_id as image_id 
 from winkpoint_promotion as w where 
CAST(@current_date as date) between CAST(event_start_date as date) and 
CAST(event_end_date as date) and event_status =1

END
ELSE
BEGIN
select 0 as event_id ,'No promotion currently.Stay tuned for upcoming promotion.' as response_message,
'0' as response_code

END


END


--select * from winkpoint_promotion

--update winkpoint_promotion set redeemed_qty = 2004

--select * from campaign_large_image




