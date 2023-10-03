CREATE Procedure [dbo].[Create_WINK_Gate]
(   @gate_id varchar(100)
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
	--IF(@pin_img is null)
	--BEGIN
	--	SELECT 0 as success,'Please upload an image for the pin' as response_message
	--	return
	--END
	--IF(@bannerImg is null)
	--BEGIN
	--	SELECT 0 as success,'Please upload an image for the banner' as response_message
	--	return
	--END
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

	IF EXISTS (SELECT 1 from wink_gate_asset where gate_id like @gate_id)
	BEGIN
		SELECT 0 as success,'This Gate ID has already been created' as response_message
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
	--IF(@pushMsg is null)
	--BEGIN
	--	SELECT 0 as success,'Please enter a valid push message' as response_message
	--	return
	--END
	--IF(@pushHeader is null)
	--BEGIN
	--	SELECT 0 as success,'Please enter a valid push header' as response_message
	--	return
	--END
	DECLARE @maxID int;
	DECLARE @winkGateId int;
	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT

	INSERT INTO wink_gate_asset
		([gate_id]
        ,[description]
        ,[latitude]
        ,[longitude]
        ,[range]
  --      ,[points]
  --      ,[interval]
		--,[pushHeader]
  --      ,[pushMsg]
  --      ,[linkTo]
  --      ,[pin_img]
  --      ,[banner_img]
  --      ,[banner_hyperlink]
  --      ,[status]
        ,[created_at]
        ,[updated_at]
		)
	VALUES
		(@gate_id
		,@desc
		,@lat
		,@lng
		,@range
		--,@points
		--,@interval
		--,@pushHeader
		--,@pushMsg
		--,@linkTo
		--,@pin_img
		--,@bannerImg
		--,@bannerUrl
		--,@asset_status
		,@CURRENT_DATETIME
		,@CURRENT_DATETIME
		)
     
	SET @maxID = (SELECT @@IDENTITY);
     
	IF (@maxID > 0)
	BEGIN
		SET @winkGateId =  (SELECT SCOPE_IDENTITY());
		Declare @result int
		--- Call WINK+ Gate Campaign Log Store Procedure Function 
		EXEC CreateGateAssetLog
		@winkGateId, @gate_id, @desc, @lat, @lng, @range, @admin_email,'WINK+ GATES Asset','New', @result output ;
		--print (@result)
		if(@result=2)
		BEGIN
			DELETE FROM wink_gate_asset WHERE id = @winkGateId;
			SELECT 0 as success,'Please try again later' as response_message
			return
		END
		ELSE
		BEGIN
			SELECT 1 as success,'A WINK+ GATES asset has been successfully created' as response_message,
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