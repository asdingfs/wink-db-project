CREATE PROCEDURE [dbo].[SMRTConnect_Ads_Tracker]
(
 @url varchar(250),
 @ip_address varchar(20),
 @os varchar(100)
 )
As
BEGIN
	Declare @current_date datetime

	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	BEGIN
		insert into smrtconnect_app_tracker (url,created_at,updated_at,ip_address,os)
		values (@url,@current_date,@current_date,@ip_address,@os)

		IF(@@ROWCOUNT>0)
		select '1' as success , 'success' as response_message
		else 
		select '0' as success , 'fail' as response_message
	END 

END