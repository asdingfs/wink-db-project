CREATE Procedure [dbo].[wifiTracker]
(
@ap_id varchar(100),
@mac_addr varchar(150),
@timestamp varchar(100),
@device_type varchar(150)
)

AS 
BEGIN

IF(@ap_id is null or @ap_id ='')
	SET @ap_id = NULL;

IF(@mac_addr is null or @mac_addr ='')
	SET @mac_addr = NULL;

IF(@timestamp is null or @timestamp ='')
	SET @timestamp = NULL;

IF(@device_type is null or @device_type ='')
	SET @device_type = NULL;

DECLARE @CURRENT_DATETIME Datetime ;     
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

	INSERT INTO WiFi_tracker
           ([ap_id]
		   ,[mac_address]
           ,[created_at]
           ,[device_type]
           ,[timestamp])
     VALUES
          (
			@ap_id,
			@mac_addr,
			@CURRENT_DATETIME,
			@device_type,
			@timestamp
			);

	If(@@ROWCOUNT>0)
	BEGIN
		
		SELECT '1' AS response_code , 'The record has been inserted successfully.' AS response_message
		RETURN		
	END
	ELSE 
	BEGIN
		SELECT '0' AS response_code , 'The insertion of the record is unsuccessful.' AS response_message,0 AS merchant_id
		RETURN
	END

END


