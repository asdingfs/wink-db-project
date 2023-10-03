CREATE PROCEDURE [dbo].[Disable_Campaign_And_AsmBooking_v2]
	(@campaign_id int,
	 @admin_email varchar(50))
AS
BEGIN
	DECLARE @old_campaign_status varchar(10)
	DECLARE @old_booked_status varchar(10)
	IF EXISTS (SELECT * FROM campaign WHERE campaign.campaign_id = @campaign_id)
	BEGIN
		-- get old data
		set @old_campaign_status = (select campaign.campaign_status from campaign
		WHERE campaign.campaign_id = @campaign_id)
		   
		UPDATE campaign 
		SET campaign.campaign_status='disable'
		WHERE campaign.campaign_id = @campaign_id;

		IF @@ROWCOUNT>0
		BEGIN
			---Start Create Log 
            Declare @result int
				--- Call Campaign Log Storeprocedure Function 
			EXEC CreateCampaigLog
			@campaign_id ,
	        0,'', '', 0,0,0,'',0,0,0, 0,'', 0 ,'','', '',NULL ,@admin_email,'Campaign','Disable',@result output ;
							
	        if(@result=2)
			BEGIN
				Update campaign set campaign.campaign_status=@old_campaign_status
				WHERE campaign.campaign_id = @campaign_id;

				SELECT '0' AS success , 'Failed to disable the campaign' As response_message
				RETURN
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT * FROM asset_management_booking WHERE asset_management_booking.campaign_id =@campaign_id)
				BEGIN
					UPDATE asset_management_booking 
					SET booked_status = 'False'
					WHERE asset_management_booking.campaign_id = @campaign_id

					IF @@ROWCOUNT>0
					BEGIN     
						SELECT '1' AS success , 'Campaign is successfully disabled' As response_message
						RETURN
					END
					ELSE
					BEGIN
						SELECT '0' AS success , 'Campaign is successfully disabled. However, disabling of booked assets is unsuccessful.' As response_message
						RETURN
					END
				END
				ELSE
				BEGIN
					SELECT '1' AS success , 'Campaign is successfully disabled' As response_message
					RETURN
				END
			END	
		END
		ELSE
		BEGIN
			SELECT '0' AS success , 'Failed to disable the campaign' As response_message
			RETURN	
		END	
	END
	ELSE 
	BEGIN
		SELECT '0' AS success , 'Invalid Campaign' As response_message
		RETURN
	END 
END

