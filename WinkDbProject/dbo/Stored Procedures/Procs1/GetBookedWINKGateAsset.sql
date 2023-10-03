CREATE Procedure [dbo].[GetBookedWINKGateAsset]
(   @bookingId int,
	@winkgoId int =0,
	@cust_auth varchar(150) = NULL
)
AS
BEGIN

	DECLARE @current_date datetime
	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	--DECLARE @winSapphire int = 0;
	--DECLARE @winDiamond int = 0;

	IF @cust_auth is not NULL
	BEGIN
		print(@cust_auth)

		Declare @customer_id int
		Declare @wink_gate_points_earned_id int


		set @wink_gate_points_earned_id = (select wink_gate_points_earned_id from nonstop_net_canid_earned_points where id = @winkgoId)

		print(CAST(@wink_gate_points_earned_id  as varchar(10)))
		set @customer_id =(select customer_id from customer where auth_token = @cust_auth and [status]='enable')
		print( CAST(@customer_id as varchar(10)))


		--DECLARE @TLMCSapphireWinnerEntry int = 28;
		--DECLARE @TLMCDiamondWinnerEntry int = 29;
		--IF EXISTS (
		--	select * from winners_points 
		--	where entry_id = @TLMCSapphireWinnerEntry and customer_id=@customer_id 
		--	AND [location]=@wink_gate_points_earned_id
		--)
		--BEGIN
		--	SET @winSapphire = 1;
		--END
		--ELSE IF EXISTS (
		--	select * from winners_points 
		--	where entry_id = @TLMCDiamondWinnerEntry and customer_id=@customer_id 
		--	AND [location]=@wink_gate_points_earned_id
		--)
		--BEGIN
		--	SET @winDiamond = 1;
		--END

		--IF EXISTS (select * from winners_points where entry_id = 23 and customer_id=@customer_id 
		--AND [location]=@wink_gate_points_earned_id)
		--BEGIN
		--	SET @isLuckyDraw = 1;
		--END
	END

 -- check lucky draw
	--IF(@winSapphire = 0 AND @winDiamond = 0)
	--BEGIN
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
	--END
	--ELSE IF(@winSapphire = 1)
	--BEGIN
	--	SELECT b.[id] as bookingId
	--	,b.[wink_gate_campaign_id] as winkGateCampaignId
	--	,c.campaign_name as campaignName
	--	,c.campaign_start_date as startDate
	--	,c.campaign_end_date as endDate
	--	,a.gate_id as gateId
	--	,b.[points]
	--	,b.[interval]
	--	,b.[pushHeader]
	--	,b.[pushMsg]
	--	,b.[linkTo]
	--	,p.[description] as pinDesc
	--	,p.image_url as pinImg
	--	, 'https://elasticbeanstalk-ap-southeast-1-548656070925.s3.ap-southeast-1.amazonaws.com/WINKTesting/winkwinkAdmin/Images/WINKGate/TLMCNov_sappire_winner_banner.jpg' as bannerImg
	--	,banner.hyperlink as bannerUrl
	--	FROM [winkwink].[dbo].[wink_gate_booking] as b, 
	--	wink_gate_campaign as w,
	--	wink_gate_asset as a,
	--	campaign as c,
	--	wink_gate_pin as p,
	--	wink_gate_banner as banner 
	--	where b.wink_gate_campaign_id = w.id
	--	AND b.wink_gate_asset_id = a.id
	--	AND b.id = p.wink_gate_booking_id
	--	AND b.id = banner.wink_gate_booking_id
	--	AND w.campaign_id = c.campaign_id
	--	AND b.id = @bookingId
	--END
	--ELSE IF(@winDiamond = 1)
	--BEGIN
	--	SELECT b.[id] as bookingId
	--	,b.[wink_gate_campaign_id] as winkGateCampaignId
	--	,c.campaign_name as campaignName
	--	,c.campaign_start_date as startDate
	--	,c.campaign_end_date as endDate
	--	,a.gate_id as gateId
	--	,b.[points]
	--	,b.[interval]
	--	,b.[pushHeader]
	--	,b.[pushMsg]
	--	,b.[linkTo]
	--	,p.[description] as pinDesc
	--	,p.image_url as pinImg
	--	, 'https://elasticbeanstalk-ap-southeast-1-548656070925.s3.ap-southeast-1.amazonaws.com/WINKTesting/winkwinkAdmin/Images/WINKGate/TLMCNov_diamond_winner_banner.jpg' as bannerImg
	--	,banner.hyperlink as bannerUrl
	--	FROM [winkwink].[dbo].[wink_gate_booking] as b, 
	--	wink_gate_campaign as w,
	--	wink_gate_asset as a,
	--	campaign as c,
	--	wink_gate_pin as p,
	--	wink_gate_banner as banner 
	--	where b.wink_gate_campaign_id = w.id
	--	AND b.wink_gate_asset_id = a.id
	--	AND b.id = p.wink_gate_booking_id
	--	AND b.id = banner.wink_gate_booking_id
	--	AND w.campaign_id = c.campaign_id
	--	AND b.id = @bookingId
	--END
END