CREATE Procedure [dbo].[GetWinkGateCampaignById]
(   @winkGateCampaignId int
)
AS
BEGIN
	DECLARE @campaignId int
			,@status int
			,@totalPoints int;

	SELECT @campaignId = [campaign_id],@totalPoints = [total_points], @status = [status]
	FROM [winkwink].[dbo].[wink_gate_campaign]
	WHERE id = @winkGateCampaignId;

	SELECT @status as campaignStatus,
	@campaignId as campaignId, campaign_name, @totalPoints as totalPoints, campaign_start_date, campaign_end_date 
	FROM campaign
	WHERE campaign_id = @campaignId;

END