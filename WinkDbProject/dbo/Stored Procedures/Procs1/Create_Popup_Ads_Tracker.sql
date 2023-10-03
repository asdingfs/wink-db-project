CREATE PROCEDURE [dbo].[Create_Popup_Ads_Tracker]
(

 @url_id int,
 @url varchar(250),
 @token_id varchar(150)
 )
As
BEGIN
Declare @customer_id int

select @customer_id =c.customer_id from customer  as c where c.auth_token = @token_id

insert into popup_ads_tracker (url_id ,customer_id , url,created_at,updated_at)
values (@url_id,@customer_id,@url,GETDATE(),GETDATE())

IF(@@ROWCOUNT>0)
select '1' as success , 'success' as response_message
else 
select '0' as success , 'fail' as response_message


END
