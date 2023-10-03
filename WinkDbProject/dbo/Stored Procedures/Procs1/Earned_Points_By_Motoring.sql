CREATE procedure [dbo].[Earned_Points_By_Motoring]
(
 @cust_auth varchar(150),
 @qr_code varchar(150),
 @id int,
 @gps_location varchar(150),
 @ip_address varchar(10)
 )
AS
BEGIN

Declare @customer_id int
Declare @current_date datetime
Declare @response_code int
Declare @earned_points int
Declare @small_image varchar(100)
Declare @url varchar(250)
Declare @timer_interval_second int
Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

set @small_image ='YueHwaSmall.jpg'
set @url = 'https://www.winkwink.sg'
set @timer_interval_second = 3


--- Check Account Locked--------
   IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @cust_auth and customer.status='disable') --CUSTOMER EXISTS                           
    BEGIN
    select 6 as response_code ,'Your account is locked. Please contact customer service.'  as response_message,@timer_interval_second as timer_interval_second
	
		RETURN 
   END-- END

set @customer_id =(select customer_id from customer where auth_token = @cust_auth and status='enable')
-- Customer -----
IF (@customer_id is null OR @customer_id ='')
BEGIN
select 0 as response_code , 'Invalid Customer' as response_message
RETURN

END

IF EXISTS (select 1 from nonstop_net_canid_earned_points as a where a.points_credit_status =0 and id=@id)
BEGIN

SET @earned_points = (select a.total_points from nonstop_net_canid_earned_points as a where a.points_credit_status =0 and id=@id) 

update nonstop_net_canid_earned_points set points_credit_status = 1 where id =@id and points_credit_status =0

	IF(@@ROWCOUNT>0)
			BEGIN

	INSERT INTO [dbo].[wink_net_canid_earned_points]
			   ([can_id]
			   ,[business_date]
			   ,[total_tabs]
			   ,[total_points]
			   ,[created_at]
			   ,[customer_id]
			   ,[card_type]
			   ,location
			   )
	  select a.can_id,@current_date,a.total_tabs,@earned_points,@current_date,@customer_id,a.card_type,@gps_location from nonstop_net_canid_earned_points as a
	  where a.customer_id =@customer_id and a.id =@id


			IF(@@ROWCOUNT>0)
			BEGIN

			Update customer_balance set total_points = total_points+@earned_points where customer_id = @customer_id

				IF(@@ROWCOUNT>0)
				BEGIN
				set @response_code =1 
				GOTO Result;

				END

				BEGIN
				set @response_code =5 
				GOTO Result;

				END
			END

			Else 
			BEGIN
			set @response_code =4
		     GOTO Result;

			END



END
		ELSE
		BEGIN

		set @response_code =3
		GOTO Result;
		END

END
ELSE
BEGIN

set @response_code =2
GOTO Result;


END

Result:
if(@response_code =1)
BEGIN
select 1 as response_code ,1 as response_message, @earned_points as points ,@url as small_website_url,
@small_image as small_banner_url,@timer_interval_second as timer_interval_second

END
ELSE IF (@response_code =2)
BEGIN
select 0 as response_code ,'No point to redeem'  as response_message, @earned_points as points,@timer_interval_second as timer_interval_second

END
ELSE IF (@response_code =3)
BEGIN
select 0 as response_code ,'Fail to redeem'  as response_message, @earned_points as points,@timer_interval_second as timer_interval_second

END

ELSE IF (@response_code =4)
BEGIN
select 0 as response_code ,'Fail to insert to nets can id'  as response_message, @earned_points as points,@timer_interval_second as timer_interval_second

END

ELSE IF (@response_code =5)
BEGIN
select 0 as response_code ,'Fail to add to customer points balance'  as response_message, @earned_points as points,@timer_interval_second as timer_interval_second

END


END




