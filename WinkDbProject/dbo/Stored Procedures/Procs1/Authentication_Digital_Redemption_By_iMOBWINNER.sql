CREATE Procedure [dbo].[Authentication_Digital_Redemption_By_iMOBWINNER]
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
Declare @customer_id int 
set @customer_id = (select customer_id from customer where email = @customer_email)

set @total = (select COUNT(*) from imobpurchase_event_winner where event_name =@event_name
                and email = @customer_email)
                
IF (@total>0)
BEGIN


IF (select COUNT(*) from iMOBWINNER_digital_redemption where  email = @customer_email and event_name=@event_name)= @total
BEGIN
select '0' as success, 'Already redeemed under this account' as response_message
RETURN

END

Else 
BEGIN
select '1' as success, 'Email is valid' as response_message
END

END
ELSE 
BEGIN
select '0' as success, 'Email is not in redemption list' as response_message
RETURN
END

END

