
CREATE PROC [dbo].[Auth_AgencyGame_Customer]
(
  @campaign_id int,
  @customer_id varchar(10),
  @phone_no varchar(15)
  
)

AS

BEGIN
Declare @start_date datetime
Declare @end_date datetime
Declare @team_id varchar(10)

Declare @agency_code varchar(10)


Set @start_date = '2017-01-01'
set @end_date = '2017-12-30'

set @agency_code = @phone_no

print (@agency_code)

IF EXISTS (select 1 from winktag_approved_phone_list where phone_no in
 (select phone_no from customer where customer_id = @customer_id)
and campaign_id = 10)
BEGIN
 select 1 as response_code , 'Valid' as response_message
 RETURN
END



IF EXISTs (select 1 from agency_game_customers as c,agency_game g 
 where c.group_id = g.id and g.agency_code = @agency_code and g.agency_status =1 and c.customer_id =@customer_id
 )
 BEGIN
 select 1 as response_code , 'Valid' as response_message
 END
 ELSE 
 BEGIN
 select 0 as response_code , 'Incorrect agency code' as response_message
 END

/******************By Access Code**************/

/* By Phone
IF NOT Exists (select 1 from customer where customer.phone_no = @phone_no and customer_id = @customer_id)
BEGIN
select 0 as response_code , 'Phone no. is not valid' as response_message
RETURN 
END
 IF EXISTS (select 1 from agency_game_customers where phone_no = @phone_no 
 and group_id in (select id from agency_game where campaign_id =@campaign_id))
 Begin

 select 1 as response_code , 'Valid' as response_message

End
ELSE
BEGIN
select 0 as response_code , 'Oops! You are not in the invite list' as response_message
END*/

END

select * from winktag_approved_phone_list


select * from winktag_campaign