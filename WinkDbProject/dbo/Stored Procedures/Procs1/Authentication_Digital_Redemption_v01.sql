CREATE Procedure [dbo].[Authentication_Digital_Redemption_v01]
(
 @customer_email varchar(250),
 @event_name varchar(100)
)
AS
BEGIN
Declare @total int

IF (@customer_email is null or @customer_email ='')
BEGIN
select '0' as success, 'Invalid Email' as response_message
RETURN

END 
--Set @customer_id = (select customer.customer_id from customer where customer.email=@customer_email) 
set @total = (select COUNT(*) from event_winner where event_name =@event_name
               and email = @customer_email)

IF @total>0
BEGIN
set @total = (select COUNT(*) from event_winner where event_name =@event_name
               and email = @customer_email)
IF (select COUNT(*) from wink_digital_redemption where email = @customer_email and event_name=@event_name)= @total
BEGIN
select '0' as success, 'Already redeemed under this account' as response_message
RETURN

END
END
ELSE 
BEGIN
select '0' as success, 'Email is not in redemption list' as response_message
RETURN
END

END


