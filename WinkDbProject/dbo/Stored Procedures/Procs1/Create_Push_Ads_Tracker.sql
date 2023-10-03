CREATE PROCEDURE [dbo].[Create_Push_Ads_Tracker]
(
	@campaignId int,
	@pushType varchar(100),
	@deviceToken varchar(255),
	@ip_address varchar(20)
)
As
BEGIN
	Declare @customer_id int
	Declare @current_datetime datetime
	Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

	select @customer_id = customer_id from push_device_token where device_token like @deviceToken;

	insert into push_ads_tracker(campaign_id,type,customer_id, device_token, created_at, updated_at, ip_address)
	values (@campaignId,@pushType, @customer_id,@deviceToken,@current_datetime,@current_datetime,@ip_address)

	IF(@@ROWCOUNT>0)
	BEGIN
		select '1' as success , 'successful' as response_message;
	END
	ELSE
	BEGIN 
		select '0' as success , 'failed' as response_message;
	END
END