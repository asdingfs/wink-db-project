CREATE Procedure [dbo].[DelinkWINKGateAsset]
(	@bookingId int,
	@adminEmail varchar(100)
)
AS
BEGIN
	IF(@adminEmail is null)
	BEGIN
		SELECT 0 as success
		--,'You are not authorised to book any WINK+ Gate assets' as response_message
		return
	END
	
	IF(@bookingId = 0 or @bookingId is null)
	BEGIN
		SELECT 0 as success
		return
	END
	
	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT

	DECLARE @winkGateCampaignId int;

	SELECT @winkGateCampaignId = wink_gate_campaign_id
	FROM wink_gate_booking
	WHERE id = @bookingId;

	--- Call WINK+ Gate Booking Log Store Procedure Function 
	Declare @result int
	EXEC CreateGateDelinkLog
	@bookingId, @winkGateCampaignId, @adminEmail,'WINK+ GATES Asset Booking','Delink', @result output ;
	--print (@result)
	if(@result=2)
	BEGIN
		SELECT 0 as success;
		return
	END
	ELSE
	BEGIN
		UPDATE wink_gate_booking 
		SET [status] = 0, updated_at = @CURRENT_DATETIME
		WHERE id = @bookingId;

		IF (@@ROWCOUNT>0)
		BEGIN
			SELECT 1 as success, @winkGateCampaignId as winkGateCampaignId;
			return
		END
		ELSE
		BEGIN
			SELECT 0 as success;
			return
		END
	END
END