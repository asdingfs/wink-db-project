CREATE PROC GAME_GROUP_QR_BY_EVENTDATE_LOCATION
@event_date_id int,
@no_of_booth int

AS
BEGIN
	IF EXISTS (SELECT * FROM GAME_EVENT_DATE WHERE event_date_id = @event_date_id)
	BEGIN
		IF NOT EXISTS(SELECT * FROM game_checkpoint_detail WHERE event_id = @event_date_id)
		BEGIN
			INSERT INTO game_checkpoint_detail 
			(event_id,qr_code,created_at)
			SELECT @event_date_id, qr_code_value,getdate()FROM asset_management_booking WHERE event_status = 1  
			
			IF @@ROWCOUNT > 0
			BEGIN 
				declare @location_id int
				declare curr cursor local for select location_id from game_location
				
				OPEN curr
				FETCH NEXT FROM curr INTO @location_id

				WHILE (@@FETCH_STATUS = 0)
				BEGIN
					UPDATE TOP(@no_of_booth)game_checkpoint_detail SET LOCATION_ID = @location_id WHERE LOCATION_ID IS NULL AND EVENT_ID =@event_date_id
					FETCH NEXT FROM curr INTO @location_id
				END
				close curr
				deallocate curr
						
				
				SELECT '1' as response_code,'success' as response_message 
				RETURN;
			END
			ELSE
			BEGIN
				SELECT '0' as response_code,'Invalid inputs' as response_message 
				RETURN;
			END
		END
	END
	BEGIN  
		SELECT '0' as response_code,'Invalid event date' as response_message
		RETURN;
	END
END