CREATE Procedure [dbo].[Authentication_CANID_CIC]
(
 @Can_ID varchar(25)
)
AS
BEGIN
Declare @customer_id int
BEGIN
IF EXISTS (select 1 from can_id where can_id.customer_canid =@Can_ID)
BEGIN
Set @customer_id = (select can_id.customer_id from can_id,customer where 
can_id.customer_id =customer.customer_id
and can_id.customer_canid =@Can_ID
and customer.status ='enable')
IF(@customer_id is not null and @customer_id !='')
BEGIN
select 1 as success , 'Success' as response_message

END
ELSE
BEGIN
select 0 as success , 'Customer account is locked' as response_message

END

END
ELSE
select 0 as success , 'CAN ID not found' as response_message

END
END
 
