CREATE PROCEDURE [dbo].[Create_Popup_Ads_Tracker_v01]
(

 @url_id int,
 @url varchar(250),
 @token_id varchar(150),
 @ip_address varchar(20)
 )
As
BEGIN
Declare @customer_id int
Declare @current_date datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

select @customer_id =c.customer_id from customer  as c where c.auth_token = @token_id
if(@url_id is not null and @url_id !='')
BEGIN
IF EXISTS (select 1 from popup_ads_app  where CAST(to_date as date) >= CAST(@current_date as date) and image_status =1 and id = @url_id)
BEGIN
insert into popup_ads_tracker (url_id ,customer_id , url,created_at,updated_at,ip_address)
values (@url_id,@customer_id,@url,@current_date,@current_date,@ip_address)

IF(@@ROWCOUNT>0)
select '1' as success , 'success' as response_message
else 
select '0' as success , 'fail' as response_message


END 
END
Else 
BEGIN
insert into popup_ads_tracker (url_id ,customer_id , url,created_at,updated_at,ip_address)
values (@url_id,@customer_id,@url,@current_date,@current_date,@ip_address)

IF(@@ROWCOUNT>0)
select '1' as success , 'success' as response_message
else 
select '0' as success , 'fail' as response_message


END 

END


--select id from popup_ads_app   where CAST(to_date as date) >= CAST(getdate() as date) and image_status =1