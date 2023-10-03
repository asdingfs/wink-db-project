CREATE Procedure [dbo].[GetBookedWINKGateAsset_backup]
(   @bookingId int
)
AS
BEGIN
	SELECT b.[id] as bookingId
      ,b.[wink_gate_campaign_id] as winkGateCampaignId
	  ,c.campaign_name as campaignName
	  ,c.campaign_start_date as startDate
	  ,c.campaign_end_date as endDate
	  ,a.gate_id as gateId
      ,b.[points]
      ,b.[interval]
	  ,b.[pushHeader]
      ,b.[pushMsg]
      ,b.[linkTo]
	  ,p.[description] as pinDesc
	  ,p.image_url as pinImg
	  ,banner.image_url as bannerImg
	  ,banner.hyperlink as bannerUrl
  FROM [winkwink].[dbo].[wink_gate_booking] as b, 
  wink_gate_campaign as w,
  wink_gate_asset as a,
  campaign as c,
  wink_gate_pin as p,
  wink_gate_banner as banner 
  where b.wink_gate_campaign_id = w.id
  AND b.wink_gate_asset_id = a.id
  AND b.id = p.wink_gate_booking_id
  AND b.id = banner.wink_gate_booking_id
  AND w.campaign_id = c.campaign_id
  AND b.id = @bookingId
END