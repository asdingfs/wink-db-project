CREATE Procedure [dbo].[BookWINKGateAssets]
(	 @winkGateCampaignId int
	,@gateId varchar(100)
	,@points int
	,@interval int
	,@pushHeader varchar(250)
	,@pushMsg varchar(500)
	,@linkTo int
	,@pinImg varchar(1000)
	,@bannerImg varchar(1000)
	,@bannerUrl varchar(1000)
	,@adminEmail varchar(100)
)
AS
BEGIN
	IF(@adminEmail is null)
	BEGIN
		SELECT 0 as success
		--,'You are not authorised to book any WINK+ Gate assets' as response_message
		return
	END
	IF(@pinImg is null or @pinImg = '')
	BEGIN
		SELECT 0 as success
		--,'Please upload an image for the pin' as response_message
		return
	END
	IF(@bannerImg is null or @bannerImg = '')
	BEGIN
		SELECT 0 as success
		--,'Please upload an image for the banner' as response_message
		return
	END
	IF(@bannerUrl is null or @bannerUrl = '')
	BEGIN
		SELECT 0 as success
		--,'Please enter a valid URL for the banner' as response_message
		return
	END
	IF(@gateId is null or @gateId = '')
	BEGIN
		SELECT 0 as success
		--,'Please enter a valid Gate ID' as response_message
		return
	END

	IF(@winkGateCampaignId = 0 or @winkGateCampaignId is null)
	BEGIN
		SELECT 0 as success
		--,'Invalid WINK+ Gate campaign' as response_message
		return
	END
	--IF(@points = 0 or @points is null)
	--BEGIN
	--	SELECT 0 as success
	--	--,'Invalid points value' as response_message
	--	return
	--END

	IF(@interval = 0 or @interval is null)
	BEGIN
		SELECT 0 as success
		--,'Invalid interval' as response_message
		return
	END
	IF(@pushHeader is null or @pushHeader='')
	BEGIN
		SELECT 0 as success
		--,'Please enter a valid push header' as response_message
		return
	END
	IF(@pushMsg is null or @pushMsg='')
	BEGIN
		SELECT 0 as success
		--,'Please enter a valid push message' as response_message
		return
	END
	DECLARE @maxID int;
	DECLARE @bookingId int;
	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT

	INSERT INTO wink_gate_booking
	([wink_gate_campaign_id]
        ,[wink_gate_asset_id]
        ,[points]
        ,[interval]
		,[pushHeader]
        ,[pushMsg]
        ,[linkTo]
        ,[updated_at]
        ,[created_at]
	)
	VALUES
		(@winkGateCampaignId
		,(SELECT id FROM wink_gate_asset where gate_id like @gateId)
		,@points
		,@interval
		,@pushHeader
		,@pushMsg
		,@linkTo
		,@CURRENT_DATETIME
		,@CURRENT_DATETIME
		)
     
	SET @maxID = (SELECT @@IDENTITY);
     
	IF (@maxID > 0)
	BEGIN
		SET @bookingId =  (SELECT SCOPE_IDENTITY());
		Declare @result int

		DECLARE @pinDesc varchar(250)
		SELECT @pinDesc = [description] 
		FROM wink_gate_asset
		WHERE gate_id like @gateId;

		INSERT INTO [dbo].[wink_gate_pin]
           ([wink_gate_booking_id]
           ,[image_url]
		   ,[description]
           ,[created_at]
           ,[updated_at])
		VALUES
           (@bookingId
           ,@pinImg
		   ,@pinDesc
           ,@CURRENT_DATETIME
           ,@CURRENT_DATETIME);

		IF (@@ROWCOUNT>0)
		BEGIN
			INSERT INTO [dbo].[wink_gate_banner]
			([wink_gate_booking_id]
			,[image_url]
			,[hyperlink]
			,[created_at]
			,[updated_at])
			 VALUES
			(@bookingId
			,@bannerImg
			,@bannerUrl
			,@CURRENT_DATETIME
			,@CURRENT_DATETIME);

			IF (@@ROWCOUNT>0)
			BEGIN
				--- Call WINK+ Gate Booking Log Store Procedure Function 
				EXEC CreateGateBookingLog
				@bookingId,@winkGateCampaignId, @gateId, @points, @interval, @pushHeader, @pushMsg, @linkTo, @pinDesc, @pinImg,
				@bannerImg, @bannerUrl, @adminEmail,'WINK+ GATES Asset Booking','New', @result output ;
				--print (@result)
				if(@result=2)
				BEGIN
					DELETE FROM wink_gate_banner WHERE wink_gate_booking_id = @bookingId;
					DELETE FROM wink_gate_pin WHERE wink_gate_booking_id = @bookingId;
					DELETE FROM wink_gate_booking WHERE id = @bookingId;

					SELECT 0 as success;
					return
				END
				ELSE
				BEGIN
					SELECT 1 as success;
					return
				END
			END
			ELSE
			BEGIN
				SELECT 0 as success;
				return
			END
		END
		ELSE
		BEGIN
			SELECT 0 as success;
			return
		END
		
	END
	ELSE
	BEGIN
		SELECT 0 as success;
		return
	END
END