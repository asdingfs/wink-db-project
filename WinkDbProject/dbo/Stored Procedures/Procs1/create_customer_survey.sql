CREATE PROCEDURE [dbo].[create_customer_survey]
(
 @token_id varchar(150)
 

)
AS
BEGIN
declare @customer_id int
If Exists (select 1 from customer where customer.auth_token =@token_id)
begin

select @customer_id=customer_id from customer where customer.auth_token =@token_id
IF Not exists (select 1 from wink_survey where customer_id =@customer_id)
BEGIN
insert into wink_survey (customer_id,servey_code,survey_name,create_at)
values (@customer_id,'test','test',GETDATE())
IF(@@ROWCOUNT>0)
BEGIN
select '1' as success , 'Successfully earned 5 points' as response_message

END

END
ELSE 
BEGIN
select '0' as success , 'You have completed the quiz' as response_message

END
end
else 
begin
select '0' as success , 'Invalid customer' as response_message
end
 
 END
--Select * from admin_log


--select * from wink_survey

--truncate table wink_survey