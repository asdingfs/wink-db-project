CREATE PROCEDURE [dbo].[Disable_Campaign_And_AsmBooking]
	(@campaign_id int)
AS
BEGIN
	IF EXISTS (SELECT * FROM campaign WHERE campaign.campaign_id = @campaign_id)
		BEGIN
			Update campaign set campaign.campaign_status='disable'
			WHERE campaign.campaign_id = @campaign_id
			IF @@ROWCOUNT>0
				BEGIN
					IF EXISTS (SELECT * FROM asset_management_booking WHERE asset_management_booking.campaign_id =@campaign_id)
					BEGIN
							UPDATE asset_management_booking SET booked_status = 'False'
							WHERE asset_management_booking.campaign_id = @campaign_id
					IF @@ROWCOUNT>0
						BEGIN
							SELECT '1' AS success , 'Campaign is successfully disabled' As response_message
							RETURN
						END
					ELSE
						BEGIN
							SELECT '0' AS success , 'Fail to disable booked assets' As response_message
							RETURN
						END
					END
					ELSE
						BEGIN
							SELECT '1' AS success , 'Campaign is successfully disabled' As response_message
							RETURN
						END
						
				END
				ELSE
					BEGIN
					SELECT '0' AS success , 'Fail to disable campaign' As response_message
					RETURN
					
					
					END
				
				
				
		END
	ELSE 
		BEGIN
		SELECT '0' AS success , 'Invalid Campaign' As response_message
		RETURN
		END 
END

/*select * from campaign where campaign.campaign_id =110

select * from asset_management_booking where qr_code_value='YCK.Testing_Sheet_01.111'

select *  from asset_management_booking where asset_management_booking.campaign_id =110*/
