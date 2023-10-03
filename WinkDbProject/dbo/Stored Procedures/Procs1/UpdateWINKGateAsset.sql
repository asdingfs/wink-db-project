CREATE Procedure [dbo].[UpdateWINKGateAsset]
(   @winkGateId int
	,@gate_id varchar(100)
	,@desc varchar(250)
	,@lat varchar(50)
	,@lng varchar(50)
	,@range int
	--,@points int
	--,@interval int
	--,@pushHeader varchar(250)
	--,@pushMsg varchar(500)
	--,@linkTo int
	--,@asset_status int
	--,@pin_img varchar(1000)
	--,@bannerImg varchar(1000)
	--,@bannerUrl varchar(1000)
	,@admin_email varchar(100)
)
AS
BEGIN
	IF(@admin_email is null)
	BEGIN
		SELECT 0 as success,'You are not authorised to create the campaign' as response_message
		return
	END

	IF(@winkGateId = 0)
	BEGIN
		SELECT 0 as success,'This WINK+ GATES asset does not exist' as response_message
		return
	END
	--IF(@bannerUrl is null)
	--BEGIN
	--	SELECT 0 as success,'Please enter a valid URL for the banner' as response_message
	--	return
	--END
	IF(@gate_id is null)
	BEGIN
		SELECT 0 as success,'Please enter a valid Gate ID' as response_message
		return
	END

	IF(@desc is null)
	BEGIN
		SELECT 0 as success,'Please enter a valid description' as response_message
		return
	END

	IF NOT EXISTS (SELECT 1 from wink_gate_asset where id like @winkGateId)
	BEGIN
		SELECT 0 as success,'This WINK+ GATES asset does not exist' as response_message
		return
	END

	IF(@range <= 0)
	BEGIN
		SELECT 0 as success,'Invalid sensing range' as response_message
		return
	END

	--IF(@points <= 0)
	--BEGIN
	--	SELECT 0 as success,'Invalid points value' as response_message
	--	return
	--END

	--IF(@interval <= 0)
	--BEGIN
	--	SELECT 0 as success,'Invalid interval' as response_message
	--	return
	--END
	--IF(@pushHeader is null)
	--BEGIN
	--	SELECT 0 as success,'Please enter a valid push header' as response_message
	--	return
	--END
	--IF(@pushMsg is null)
	--BEGIN
	--	SELECT 0 as success,'Please enter a valid push message' as response_message
	--	return
	--END

	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT

	DECLARE @old_desc varchar(250),
	@old_lat varchar(50),
	@old_lng varchar(50),
	@old_range int;
	--@old_points int,
	--@old_interval int,
	--@old_push_header varchar(250),
	--@old_push_msg varchar(500),
	--@old_link_to int,
	--@old_asset_status int,
	--@old_pin_img varchar(1000),
	--@old_banner_img varchar(1000),
	--@old_banner_url varchar(1000);

	SELECT @old_desc = [description],
	@old_lat = [latitude],
	@old_lng = [longitude],
	@old_range = [range]
	--@old_points = [points],
	--@old_interval = [interval],
	--@old_push_header = [pushHeader],
	--@old_push_msg = [pushMsg],
	--@old_link_to = [linkTo],
	--@old_asset_status = [status],
	--@old_pin_img = [pin_img],
	--@old_banner_img = [banner_img],
	--@old_banner_url = [banner_hyperlink]
	FROM [dbo].[wink_gate_asset]
	WHERE id = @winkGateId;

	UPDATE [dbo].[wink_gate_asset]
	SET [description] = @desc
		,[latitude] = @lat
		,[longitude] = @lng
		,[range] = @range
		--,[points] = @points
		--,[interval] = @interval
		--,[pushHeader] = @pushHeader
		--,[pushMsg] = @pushMsg
		--,[linkTo] = @linkTo
		--,[status] = @asset_status
		--,[banner_hyperlink] = @bannerUrl
 		,[updated_at] = @CURRENT_DATETIME
	WHERE id = @winkGateId;
     
	IF (@@ROWCOUNT>0)
	BEGIN
		--IF(@pin_img is not null)
		--BEGIN
		--	UPDATE [dbo].[wink_gate_asset]
		--	SET [pin_img] = @pin_img
		--		,[updated_at] = @CURRENT_DATETIME
		--	WHERE id = @winkGateId;

		--	IF(@@ROWCOUNT=0)
		--	BEGIN
		--		SELECT 0 as success,'Please try again later' as response_message
		--		return
		--	END
		--END

		--IF(@bannerImg is not null)
		--BEGIN
		--	UPDATE [dbo].[wink_gate_asset]
		--	SET [banner_img] = @bannerImg
		--		,[updated_at] = @CURRENT_DATETIME
		--	WHERE id = @winkGateId;

		--	IF(@@ROWCOUNT=0)
		--	BEGIN
		--		SELECT 0 as success,'Please try again later' as response_message
		--		return
		--	END
		--END

		Declare @result int
		--- Call WINK+ Gate Campaign Log Store Procedure Function 
		EXEC CreateGateAssetLog
		@winkGateId, @gate_id, @old_desc, @old_lat, @old_lng, @old_range, 
		--@old_points, @old_interval, @old_push_header,
		--@old_push_msg, @old_link_to, @old_asset_status, @old_pin_img, @old_banner_img, @old_banner_url,
		@admin_email,'WINK+ GATES Asset','Edit', @result output ;
		--print (@result)
		if(@result=2)
		BEGIN
			UPDATE [dbo].[wink_gate_asset]
			SET [description] = @old_desc
				,[latitude] = @old_lat
				,[longitude] = @old_lng
				,[range] = @old_range
				--,[points] = @old_points
				--,[interval] = @old_interval
				--,[pushHeader] = @old_push_header
				--,[pushMsg] = @old_push_msg
				--,[linkTo] = @old_link_to
				--,[status] = @old_asset_status
				--,[pin_img] = @old_pin_img
				--,[banner_img] = @old_banner_img
				--,[banner_hyperlink] = @old_banner_url
				,[updated_at] = @CURRENT_DATETIME
			WHERE id = @winkGateId;
			SELECT 0 as success,'Please try again later' as response_message
			return
		END
		ELSE
		BEGIN
			SELECT 1 as success,'This WINK+ GATES asset has been successfully updated' as response_message,
			@winkGateId as wink_gate_id
			return
		END
		
	END
	ELSE
	BEGIN
		SELECT 0 as success,'Please try again later' as response_message
		return
	END
END