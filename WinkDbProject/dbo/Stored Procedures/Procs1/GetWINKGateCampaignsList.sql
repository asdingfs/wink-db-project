CREATE PROCEDURE [dbo].[GetWINKGateCampaignsList]
(
	@winkGateCampaignId int,
	@campaignName varchar(250),
	@advName varchar(200),
	@campaignStatus varchar(5)
)
	
AS
BEGIN
	DECLARE @CURRENT_DATE date;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT
	IF(@winkGateCampaignId = 0)
		SET @winkGateCampaignId = NULL;

	IF(@campaignName is null or @campaignName = '')
	BEGIN
		set @campaignName = null;
	END

	IF(@advName is null or @advName = '')
	BEGIN
		set @advName = null;
	END

	IF(@campaignStatus is null or @campaignStatus = '')
	BEGIN
		set @campaignStatus = null;
	END

	SELECT * FROM(
	SELECT g.[id] as winkGateCampaignId
      ,c.campaign_name as campaignName
	  ,g.total_points as totalPoints
      ,c.campaign_start_date as startDate
	  ,c.campaign_end_date as endDate
      ,g.[created_at] as createdOn
	  , m.first_name + ' ' + m.last_name as merName
      ,CASE WHEN (cast(c.campaign_end_date as date) < @CURRENT_DATE)
	  THEN 2
	  ELSE g.[status] END as campaignStatus
	FROM [winkwink].[dbo].[wink_gate_campaign] as g, campaign as c, merchant as m
	WHERE g.campaign_id = c.campaign_id
	AND c.merchant_id = m.merchant_id
	)
	AS T
	WHERE (@winkGateCampaignId is null or T.winkGateCampaignId = @winkGateCampaignId)
	AND (@campaignName is null or T.campaignName like '%'+@campaignName+'%')
	AND (@advName is null or T.merName like '%'+@advName+'%')
	AND (@campaignStatus is null or T.campaignStatus like @campaignStatus)
	order by T.startDate desc
END
