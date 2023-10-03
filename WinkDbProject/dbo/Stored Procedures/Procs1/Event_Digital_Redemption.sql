CREATE Procedure [dbo].[Event_Digital_Redemption]
(
 @customer_email varchar(250),
 @NRIC varchar(100),
 @dob varchar(100),
 @event_name varchar(100)

)
AS
BEGIN
Declare @valid int
Declare @customer_id int
Declare @current_date datetime
Declare @total_scan int
Declare @maxID int 
Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

Set @customer_id = (select customer.customer_id from customer where customer.email=@customer_email) 

IF Exists (select 1 from wink_digital_redemption  where NRIC =@NRIC and @NRIC!='')
BEGIN
select '0' as success, 'Already redeemed under this NRIC/FIN.' as response_message
RETURN

END

IF (@customer_id is not null or @customer_id !='' or @customer_id !=0)
BEGIN
Declare @CUS_ID int

WITH checking as (select distinct customer_id,qr_code
from customer_earned_points
 where 
 qr_code like '%Starwars%'
 and customer_id =@customer_id
 group by customer_id,qr_code)
 select @CUS_ID= customer_id  from checking
 where 
 --customer_id not in (select distinct customer_id from wink_unentitled_customer_event)
 customer_id in (select customer_id from event_winner)
 group by customer_id 
 having COUNT(*)>=8
 
 IF (@CUS_ID is not null or @CUS_ID !='' or @CUS_ID !=0)
  Begin
  -- Check already redemption
  IF NOT Exists (Select 1 from wink_digital_redemption where customer_id = @CUS_ID)
  BEGIN 
   print ('Not Redeem')
   insert into wink_digital_redemption (email,customer_id , NRIC,dob,redemption_status,event_name,created_at)
   values (@customer_email,@CUS_ID,@NRIC,@dob,1,@event_name,@current_date)
   
   IF(@@ERROR=0)
   Begin
   select '1' as success, 'Successfully Redeemed' as response_message
   End
   else 
   Begin
   select '0' as success, 'Fail to redeem' as response_message
   END
   
   END
   ELSE 
   BEGIN
    print ('Already')
    select '0' as success, 'Already redeemed' as response_message
   END
   
   END
  ELSE
BEGIN
select '0' as success, 'Not valid to redeem' as response_message

END 

  END
ELSE
BEGIN
select '0' as success, 'Invalid email' as response_message

END


END

 
