CREATE Procedure [dbo].[UpdateBookedWINKGateAsset]
(    @bookingId int
	,@points int
	,@interval int
	,@pushHeader varchar(250)
	,@pushMsg varchar(500)
	,@linkTo int
	,@pin_desc varchar(250)
	,@pin_img varchar(1000)
	,@bannerImg varchar(1000)
	,@bannerUrl varchar(1000)
	,@admin_email varchar(100)
)
AS
BEGIN
	IF(@admin_email is null)
	BEGIN
		SELECT 0 as success,'You are not authorised to create the campaign' as response_message;
		return
	END

	IF(@bookingId = 0)
	BEGIN
		SELECT 0 as success,'Invalid booking ID' as response_message;
		return
	END
	IF(@bannerUrl is null)
	BEGIN
		SELECT 0 as success,'Please enter a valid URL for the banner' as response_message;
		return
	END

	IF NOT EXISTS (SELECT 1 from wink_gate_booking where id like @bookingId)
	BEGIN
		SELECT 0 as success,'This booking does not exist' as response_message;
		return
	END

	--IF(@points <= 0)
	--BEGIN
	--	SELECT 0 as success,'Invalid points value' as response_message;
	--	return
	--END

	IF(@interval <= 0)
	BEGIN
		SELECT 0 as success,'Invalid interval' as response_message;
		return
	END
	IF(@pushHeader is null)
	BEGIN
		SELECT 0 as success,'Please enter a valid push header' as response_message;
		return
	END
	IF(@pushMsg is null)
	BEGIN
		SELECT 0 as success,'Please enter a valid push message' as response_message;
		return
	END
	IF(@pin_desc is null)
	BEGIN
		SELECT 0 as success,'Please enter a valid pin description' as response_message;
		return
	END
	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT

	DECLARE @winkGateCampaignId int,
	@gateId varchar(100),
	@old_points int,
	@old_interval int,
	@old_push_header varchar(250),
	@old_push_msg varchar(500),
	@old_link_to int,
	@old_pin_desc varchar(250),
	@old_pin_img varchar(1000),
	@old_banner_img varchar(1000),
	@old_banner_url varchar(1000);

	SELECT @old_banner_img = image_url, @old_banner_url = hyperlink 
	FROM wink_gate_banner 
	WHERE wink_gate_booking_id = @bookingId;

	SELECT @old_pin_img = image_url, @old_pin_desc = [description] 
	FROM wink_gate_pin 
	where wink_gate_booking_id = @bookingId;

	SELECT @winkGateCampaignId = [wink_gate_campaign_id],
	@old_points = [points],
	@old_interval = [interval],
	@old_push_header = [pushHeader],
	@old_push_msg = [pushMsg],
	@old_link_to = [linkTo]
	FROM [dbo].[wink_gate_booking]
	WHERE id = @bookingId;

	SELECT @gateId = a.gate_id
	FROM wink_gate_booking as b, wink_gate_asset as a
	WHERE b.wink_gate_asset_id = a.id
	AND b.id = @bookingId;

	UPDATE [dbo].[wink_gate_booking]
	SET [points] = @points
		,[interval] = @interval
		,[pushHeader] = @pushHeader
		,[pushMsg] = @pushMsg
		,[linkTo] = @linkTo
 		,[updated_at] = @CURRENT_DATETIME
	WHERE id = @bookingId;
     
	IF (@@ROWCOUNT>0)
	BEGIN
		IF(@pin_img is not null)
		BEGIN
			UPDATE [dbo].[wink_gate_pin]
			SET image_url = @pin_img,
			description = @pin_desc,
			[updated_at] = @CURRENT_DATETIME
			WHERE wink_gate_booking_id = @bookingId;

			IF(@@ROWCOUNT=0)
			BEGIN
				SELECT 0 as success,'Please try again later' as response_message;
				return
			END
		END
		ELSE
		BEGIN
			UPDATE [dbo].[wink_gate_pin]
			SET description = @pin_desc,
			[updated_at] = @CURRENT_DATETIME
			WHERE wink_gate_booking_id = @bookingId;

			IF(@@ROWCOUNT=0)
			BEGIN
				SELECT 0 as success,'Please try again later' as response_message;
				return
			END
		END

		IF(@bannerImg is not null)
		BEGIN
			UPDATE [dbo].[wink_gate_banner]
			SET [image_url] = @bannerImg
				,hyperlink = @bannerUrl
				,[updated_at] = @CURRENT_DATETIME
			WHERE wink_gate_booking_id = @bookingId;

			IF(@@ROWCOUNT=0)
			BEGIN
				SELECT 0 as success,'Please try again later' as response_message;
				return
			END
		END

		Declare @result int
		
		--- Call WINK+ Gate Booking Log Store Procedure Function 
		EXEC CreateGateBookingLog
		@bookingId, @winkGateCampaignId, @gateId, @old_points, @old_interval, @old_push_header,
		@old_push_msg, @old_link_to, @old_pin_desc, @old_pin_img, @old_banner_img, @old_banner_url,
		@admin_email,'WINK+ GATES Asset Booking','Edit', @result output ;
		--print (@result)
		if(@result=2)
		BEGIN
			UPDATE [dbo].[wink_gate_booking]
			SET [points] = @old_points
				,[interval] = @old_interval
				,[pushHeader] = @old_push_header
				,[pushMsg] = @old_push_msg
				,[linkTo] = @old_link_to
				,[updated_at] = @CURRENT_DATETIME
			WHERE id = @bookingId;

			UPDATE wink_gate_pin
			SET image_url = @old_pin_img,
			[description] = @old_pin_desc,
			[updated_at] = @CURRENT_DATETIME
			WHERE wink_gate_booking_id = @bookingId;

			UPDATE wink_gate_banner
			SET image_url = @old_banner_img,
			hyperlink = @old_banner_url
			,[updated_at] = @CURRENT_DATETIME
			WHERE wink_gate_booking_id = @bookingId;

			SELECT 0 as success,'Please try again later' as response_message;
			return
		END
		ELSE
		BEGIN
			SELECT 1 as success,'The WINK+ GATES booking has been successfully updated' as response_message;
			return
		END
		
	END
	ELSE
	BEGIN
		SELECT 0 as success,'Please try again later' as response_message;
		return
	END
END