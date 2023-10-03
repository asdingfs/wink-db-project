CREATE PROCEDURE [dbo].[Create_WINKTag_Ads_Tracker]
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

--select @customer_id =c.customer_id from customer  as c where c.auth_token = @token_id
--set @customer_id = @token_id;


insert into winktag_ads_tracker (url_id ,customer_id , url,created_at,updated_at,ip_address)
values (@url_id,@token_id,@url,@current_date,@current_date,@ip_address);

IF(@@ROWCOUNT>0)
BEGIN
	select '1' as success , 'success' as response_message
END
else 
BEGIN
	select '0' as success , 'fail' as response_message
END

END


