CREATE PROCEDURE  [dbo].[CreateWINKGateCampaign] 
(
	@campaignId int,
	@totalPoints int,
	@status int,
	@admin_email varchar(100)
)
AS
BEGIN 

	IF(@admin_email is null)
	BEGIN
		SELECT 0 as success,'You are not authorised to create the campaign' as response_message
		return
	END
	IF(@campaignId = 0)
	BEGIN
		SELECT 0 as success,'Please select a valid campaign' as response_message
		return
	END
	--TL campaign finale, with no base points only lucky draw
	--IF(@totalPoints = 0)
	--BEGIN
	--	SELECT 0 as success,'Please enter a valid amount for the points allocation' as response_message
	--	return
	--END
	

	DECLARE @maxID int
	DECLARE @wink_gate_campaign_id int;
	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT
	

	INSERT INTO [dbo].[wink_gate_campaign]
           (
           [campaign_id]
		   ,[total_points]
		   ,[status]
           ,[updated_at]
           ,[created_at])
     VALUES
           (
			@campaignId
			,@totalPoints
			,@status
			,@CURRENT_DATETIME
			,@CURRENT_DATETIME);
	SET @maxID = (SELECT @@IDENTITY);
     
	IF (@maxID > 0)
	BEGIN
		SET @wink_gate_campaign_id  =  (SELECT SCOPE_IDENTITY());
		
		Declare @result int
		--- Call WINK+ Gate Campaign Log Store Procedure Function 
		EXEC CreateGateCampaignLog
		@campaignId, @wink_gate_campaign_id, @totalPoints, @status,
		@admin_email,'WINK+ GATES Campaign','New', @result output ;
		--print (@result)
		if(@result=2)
		BEGIN
			DELETE FROM wink_gate_campaign WHERE id = @wink_gate_campaign_id;
			SELECT 0 as success,'Please try again later' as response_message
			return
		END
		ELSE
		BEGIN
			SELECT 1 as success,'A WINK+ GATES campaign has been successfully created' as response_message,
			@wink_gate_campaign_id as winkGateCampaignId;
			return
		END
	END
	ELSE
	BEGIN
		SELECT 0 as success,'Please try again later.' as response_message
		return
	END

END

