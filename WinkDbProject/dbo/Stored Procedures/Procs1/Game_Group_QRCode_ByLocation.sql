CREATE PROC Game_Group_QRCode_ByLocation
(
@TableVar as GameQRCodeVariable readonly,
@event_date_id int,
@location_id int
)

AS
BEGIN
	IF EXISTS (SELECT * FROM game_checkpoint_detail_1 WHERE event_id = @event_date_id)
	BEGIN
		UPDATE game_checkpoint_detail_1 set location_id = @location_id WHERE qr_code in (SELECT qr_code FROM @TableVar)
		SELECT '1' as response_code,'Successfully created' as response_message
		RETURN; 
	END
	ELSE
	BEGIN  
		SELECT '0' as response_code,'Invalid event date' as response_message
		RETURN;
	END
END