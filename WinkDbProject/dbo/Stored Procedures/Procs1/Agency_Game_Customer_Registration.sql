
CREATE PROC [dbo].[Agency_Game_Customer_Registration]
(
  @agency_id int,
  @customer_id int,
  @agency_code varchar(15)
  
)

AS

BEGIN

Declare @phone_no varchar(8)
Declare @created_at datetime
Declare @start_date datetime
Declare @end_date datetime

Declare @agency_name varchar(100)

Set @start_date = '2017-07-24'
set @end_date = '2017-08-30'

-- check customer status

exec GET_CURRENT_SINGAPORT_DATETIME @created_at output

IF exists (select 1 from agency_game_customers where customer_id = @customer_id)
BEGIN
select 0 as response_code , 'You are registered.' as response_message
Return
END
select @agency_name= agency_game.agency_name ,@agency_id = id from agency_game where agency_code = @agency_code

IF(@agency_id = 0 OR @agency_id = '' OR @agency_id IS NULL)
BEGIN

select 0 as response_code , 'Invalid agency code' as response_message

RETURN
END
IF Exists (select 1 from customer where customer.customer_id =@customer_id and customer.status ='enable')
BEGIN
IF Exists (select 1 from agency_game as g where g.agency_code = @agency_code and agency_status =1 and g.group_size >
(select count(*) from agency_game_customers where group_id = @agency_id and customer_id is not null)
)
BEGIN
set @phone_no = (select phone_no from customer where customer_id =@customer_id)
insert into agency_game_customers (group_id , customer_id ,phone_no, created_at)
values (@agency_id,@customer_id,@phone_no,@created_at)

IF(@@ROWCOUNT>0)
BEGIN

select 1 as response_code , Concat('You are now registered <br/> under Team ',@agency_name)  as response_message


END
ELSE

BEGIN
select 0 as response_code , 'Fail to register' as response_message

END


END


ELSE
BEGIN
select 0 as response_code , 'Fully registered' as response_message
Return
END

END
ELse 
BEGIN
select 0 as response_code , 'Invalid account' as response_message
END

END

