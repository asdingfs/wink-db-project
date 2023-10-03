
CREATE PROCEDURE [dbo].[Game_Create_QRcodes_Mapping]
	(@from_qr varchar(150),
	 @to_qr varchar(150),
	 @event_id int
	 
	 )
AS
BEGIN
DECLARE @date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @date output
	IF NOT EXISTS (select * from game_checkpoint_mapping 
	where game_checkpoint_mapping.from_checkpoint_qr =@from_qr AND to_checkpoint_qr = @to_qr and event_id = @event_id )
	BEGIN
		Insert into game_checkpoint_mapping (from_checkpoint_qr,to_checkpoint_qr,created_at,updated_at,event_id)
		values (@from_qr,@to_qr,@date,@date,@event_id)
		IF(@@ROWCOUNT>0)
		Select '1' as success , 'Successfully mapped' as response_message
	END
	ELSE
		BEGIN
				Select '0' as success , 'Already Exists' as response_message

		
		END
	
	
END
