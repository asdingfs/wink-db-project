CREATE PROCEDURE [dbo].[Create_Push_Notification]
	(@notification_message varchar(500),
	 @created_on datetime,
	 @url varchar(500)
	 )
AS
BEGIN
	INSERT INTO push_notification (notification_message,created_on,url)
	VALUES (@notification_message,@created_on,@url)
END