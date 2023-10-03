CREATE Procedure [dbo].[Authentication_Digital_Redemption]
(
 @customer_email varchar(250),
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

IF EXISTS (select 1 from wink_digital_redemption where customer_id = @customer_id)
BEGIN
select '0' as success, 'Already redeemed under this account' as response_message
RETURN

END
ELSE IF NOT EXISTS (select 1 from event_winner where event_name =@event_name
and customer_id = @customer_id)
BEGIN
select '0' as success, 'Email is not in redemption list' as response_message
RETURN
END
ELSE 
BEGIN
select '1' as success, 'Email is valid' as response_message
Return
END

END


 
