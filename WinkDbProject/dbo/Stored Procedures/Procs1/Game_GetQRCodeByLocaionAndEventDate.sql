CREATE PROC Game_GetQRCodeByLocaionAndEventDate
(@event_date_id int,
@location_id int
)
AS

BEGIN
	IF EXISTS (SELECT * FROM GAME_EVENT_DATE WHERE event_date_id = @event_date_id)
	BEGIN
		IF EXISTS (SELECT * FROM GAME_LOCATION WHERE location_id = @location_id)
		BEGIN
			IF EXISTS(SELECT * FROM game_checkpoint_detail_1 WHERE event_id = @event_date_id)
			BEGIN
				SELECT '1' as response_code,'success' as response_message 
				SELECT qr_code FROM game_checkpoint_detail_1 WHERE location_id IS NULL AND event_id = @event_date_id ORDER BY QR_CODE ASC
				RETURN;
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT * FROM asset_management_booking WHERE event_status = 1)
				BEGIN
					INSERT INTO game_checkpoint_detail_1 
					(event_id,qr_code,created_at)
					SELECT @event_date_id, qr_code_value,getdate()FROM asset_management_booking WHERE event_status = 1  
					
					IF @@ROWCOUNT > 0
					BEGIN
						SELECT '1' as response_code,'success' as response_message 
						SELECT qr_code FROM game_checkpoint_detail_1 WHERE location_id IS NULL AND event_id = @event_date_id ORDER BY QR_CODE ASC
						RETURN;
					END
					ELSE
					BEGIN
						SELECT '0' as response_code,'Invalid inputs' as response_message 
						RETURN;
					END
				END
				ELSE
				BEGIN
					SELECT '0' as response_code,'QR codes do not exist' as response_message
					RETURN;
				END
			END
		END
		ELSE
		BEGIN  
			SELECT '0' as response_code,'Invalid location' as response_message
			RETURN;
		END
	END
	ELSE
	BEGIN  
		SELECT '0' as response_code,'Invalid event date' as response_message
		RETURN;
	END
END






