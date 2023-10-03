CREATE PROC [dbo].[GetPushDeviceToken_By_DeviceType]
@device_type VARCHAR(10)

AS

BEGIN

	--production device token
	SELECT distinct device_token 
	FROM push_device_token as push
	JOIN customer 
	ON push.customer_id = customer.customer_id
	where (push.device_token is not null and push.device_token !='')
	AND (@device_type IS NULL OR push.device_type like '%' + @device_type + '%') 
	AND active_status = '1'

END