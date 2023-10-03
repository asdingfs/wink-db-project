CREATE procedure [dbo].[Get_Motoring_List]
(
 @cust_auth varchar(150)
 )
AS
BEGIN

Declare @customer_id int
DECLARE @current_date datetime
DECLARE @time_limit decimal

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

----PRODUCTION 24 HOURS CHECK
   SET @time_limit =24

----TESTING HOUR CHECK
--SET @time_limit =100000


 

IF EXISTs (select 1 from customer where auth_token = @cust_auth and status='disable')
BEGIN

	select 2 as response_code , 'Account locked. Please contact customer service.' as response_message
END 

set @customer_id =(select customer_id from customer where auth_token = @cust_auth and status='enable')
-- Customer -----
IF (@customer_id is null and @customer_id ='')
BEGIN
select 0 as response_code , 'Invalid Customer' as response_message

RETURN

END

--PRINT (@CUSTOMER_ID)

IF EXISTS (select 1 from nonstop_net_canid_earned_points as a  where a.points_credit_status =0 and a.customer_id =@customer_id
and (a.card_type = '07' or a.card_type = '08' or a.card_type = '09' or a.card_type='10' or a.card_type='11') 
and DATEDIFF(hh, Cast(a.created_at as datetime),Cast(@current_date as datetime)) < @time_limit
)
BEGIN

  select sum(a.total_points) as points ,'aa' as qr_code,
   1 as response_code,'success' as response_message   
  from nonstop_net_canid_earned_points as a  where a.points_credit_status =0 
  and a.customer_id = @customer_id
  and (a.card_type = '07' or a.card_type = '08' or a.card_type = '09' or a.card_type='10' or a.card_type='11')
  and DATEDIFF(hh, Cast(a.created_at as datetime),Cast(@current_date as datetime)) <  @time_limit
  
END
ELSE
BEGIN

select 0 as response_code , 'No points available' as response_message

END


END

--SELECT * FROM nonstop_net_canid_earned_points ORDER BY ID DESC

