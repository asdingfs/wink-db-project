CREATE PROC [dbo].[Auth_AgencyGame_AcessCode]          
(@access_code varchar(10),
 @customer_id int 
)                                                                                                                          

AS
BEGIN
DECLARE @agency_name varchar(100)
IF Exists (select 1 from agency_game_customers where customer_id = @customer_id )
BEGIN
select 0 as response_code , 'You are registered.' as response_message

END
Else
BEGIN
IF (@access_code is not null and @access_code !='' and @access_code !='0')
BEGIN
IF (@customer_id is not null and @customer_id !=0 and @customer_id !='')
BEGIN
IF EXISTS (select 1 from agency_game where agency_code = @access_code)
BEGIN
select @agency_name = agency_name  from agency_game where agency_code = @access_code 

select 1 as response_code , Concat('You have selected team<br/> ',@agency_name,'.') as response_message
END
ELSE
BEGIN
select 0 as response_code , 'Invalid agency code' as response_message
END
END
ELSE
BEGIN
select 0 as response_code , 'Invalid Request' as response_message
Return
END

END
ELSE
BEGIN
select 1 as response_code , 'Go to register' as response_message
END


END
END
