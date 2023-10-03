CREATE PROCEDURE  [dbo].[UpdateWINKGateCampaign] 
(
	@winkGateCampaignId int,
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
	IF(@winkGateCampaignId = 0)
	BEGIN
		SELECT 0 as success,'Please select a valid campaign' as response_message
		return
	END
	--IF(@totalPoints = 0)
	--BEGIN
	--	SELECT 0 as success,'Please enter a valid amount for the points allocation' as response_message
	--	return
	--END
	
	
	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT
	
	DECLARE @campaign_id int,
	@old_status int,
	@old_totalPoints int;

	SELECT @campaign_id = [campaign_id],
	@old_totalPoints = [total_points],
	@old_status = [status]
	FROM [dbo].[wink_gate_campaign]
	WHERE id = @winkGateCampaignId;

	UPDATE [dbo].[wink_gate_campaign]
    SET [status] = @status
	,[total_points] = @totalPoints
    ,[updated_at] = @CURRENT_DATETIME
	WHERE id = @winkGateCampaignId;

	IF (@@ROWCOUNT>0)
	BEGIN
		Declare @result int
		--- Call WINK+ Gate Campaign Log Store Procedure Function 
		EXEC CreateGateCampaignLog
		@campaign_id, @winkGateCampaignId, @old_totalPoints, @old_status,
		@admin_email,'WINK+ GATES Campaign','Edit', @result output ;
		--print (@result)
		if(@result=2)
		BEGIN
			UPDATE [dbo].[wink_gate_campaign]
			SET [status] = @old_status
			,[total_points] = @old_totalPoints
			,[updated_at] = @CURRENT_DATETIME
			WHERE id = @winkGateCampaignId;
			SELECT 0 as success,'Please try again later' as response_message
			return
		END
		ELSE
		BEGIN
			SELECT 1 as success,'This WINK+ GATES campaign has been successfully updated' as response_message,
			@winkGateCampaignId as winkGateCampaignId
			return
		END
	END
	ELSE
	BEGIN
		SELECT 0 as success,'Please try again later.' as response_message
		return
	END

END

