CREATE PROCEDURE [dbo].[Create_Microsite_Ads_Tracker]
(
 @source varchar(250),
 @url varchar(250),
 @ip_address varchar(20)
 )
As
BEGIN
	Declare @current_date datetime

	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	BEGIN
		insert into microsite_ads_tracker(source, url,created_at,updated_at,ip_address)
		values (@source, @url,@current_date,@current_date,@ip_address)

		IF(@@ROWCOUNT>0)
		select '1' as success , 'success' as response_message
		else 
		select '0' as success , 'fail' as response_message
	END 

END