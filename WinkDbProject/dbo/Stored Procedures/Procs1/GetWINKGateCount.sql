CREATE PROCEDURE [dbo].[GetWINKGateCount]
(
	@authToken VARCHAR(255)
)
	
AS
BEGIN
	DECLARE @CURRENT_DATE date;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT
	DECLARE @customerId INT


    IF EXISTS (select 1 from customer where customer.auth_token = @authToken and status ='disable')
    BEGIN
		RETURN 
	END-- END
	
    
	IF NOT EXISTS (SELECT 1 FROM CUSTOMER WHERE auth_token = @authToken )
	BEGIN
		RETURN 
	END 

	SELECT @customerId = customer_id from customer WHERE auth_token = @authToken;

	DECLARE @tlDemoQr int = 0
	IF EXISTS(SELECT 1 FROM customer_earned_points WHERE qr_code like 'TL_Demo_01%' and customer_id = @customerId)
	BEGIN
		SET @tlDemoQr = 1;
	END

	DECLARE @rtsQrScanned int = 0
	IF EXISTS(SELECT 1 FROM customer_earned_points WHERE qr_code like 'RTSA_Event_%' and customer_id = @customerId)
	BEGIN
		SET @rtsQrScanned = 1;
	END


	--DECLARE @NHBWGCampaignId int = 42;
	--DECLARE @NHBDailyInventory int = 3;

	DECLARE @validOTTLMC int = 0;
	DECLARE @validMCTLMC int = 0;
	DECLARE @TLMCWinkPlayCampaignId int = 170;

	DECLARE @tlMCAns varchar(50);
	SELECT @tlMCAns = answer FROM winktag_customer_survey_answer_detail 
	WHERE campaign_id = @TLMCWinkPlayCampaignId 
	AND customer_id = @customerId;

	print('tl answer');
	print(@tlMCAns);

	IF (@tlMCAns IS NOT NULL)
	BEGIN
		SET @validOTTLMC = 1;

		IF(@tlMCAns like 'MC%' OR @tlMCAns like '%,MC%')
		BEGIN
			SET @validMCTLMC = 1;
		END
	END
	print(@validOTTLMC);
	print(@validMCTLMC);

	DECLARE @TLMCSilverCampaignId int = 44;
	DECLARE @TLMCGoldenCampaignId int = 45;
	DECLARE @RTSGateCampaignId int = 50;

	--DECLARE @TLMCSapphireCampaignId int = 43;
	--DECLARE @TLMCSapphireInventory int = 300;
	--DECLARE @TLMCSapphireWinnerEntry int = 28;

	--DECLARE @TLMCDiamondCampaignId int = 46;
	--DECLARE @TLMCDiamondInventory int = 120;
	--DECLARE @TLMCDiamondWinnerEntry int = 29;

	IF OBJECT_ID('tempdb..#ActiveWINKGATECount') IS NOT NULL DROP TABLE #ActiveWINKGATECount
	CREATE TABLE #ActiveWINKGATECount
	(
		pointsAllocated int,
		winkGateCampaignId int,
		totalPoints int
	)
	INSERT INTO #ActiveWINKGATECount (pointsAllocated, winkGateCampaignId, totalPoints)
	SELECT * from (
		SELECT ISNULL(sum(e.points),0) as points, wc.id as winkGateCampaign, wc.total_points
		FROM wink_gate_booking as wb
		left join wink_gate_campaign as wc
		on wb.wink_gate_campaign_id = wc.id
		left join campaign as c
		on wc.campaign_id = c.campaign_id
		left join wink_gate_points_earned as e
		on e.bookingId = wb.id
		WHERE (@CURRENT_DATE between c.campaign_start_date and c.campaign_end_date)
		AND (
				wc.id != @TLMCSilverCampaignId 
				AND wc.id != @TLMCGoldenCampaignId
				AND wc.id != @RTSGateCampaignId
				--AND wc.id != @TLMCSapphireCampaignId
				--AND wc.id != @TLMCDiamondCampaignId
			)
		AND wc.[status] = 1
		AND wb.[status] = 1
		GROUP BY wc.id, wc.total_points
		HAVING ISNULL(SUM(e.points),0) < wc.total_points

		--TransitLink MasterCard Silver Gates
		union

		SELECT ISNULL(sum(e.points),0) as points, wc.id as winkGateCampaign, wc.total_points
		FROM wink_gate_booking as wb
		left join wink_gate_campaign as wc
		on wb.wink_gate_campaign_id = wc.id
		left join campaign as c
		on wc.campaign_id = c.campaign_id
		left join wink_gate_points_earned as e
		on e.bookingId = wb.id
		WHERE (@CURRENT_DATE between c.campaign_start_date and c.campaign_end_date)
		AND wc.id = @TLMCSilverCampaignId 
		AND wc.[status] = 1
		AND wb.[status] = 1
		AND @validOTTLMC = 1
		GROUP BY wc.id, wc.total_points
		HAVING ISNULL(SUM(e.points),0) < wc.total_points

		--TransitLink MasterCard Golden Gates
		union

		SELECT ISNULL(sum(e.points),0) as points, wc.id as winkGateCampaign, wc.total_points
		FROM wink_gate_booking as wb
		left join wink_gate_campaign as wc
		on wb.wink_gate_campaign_id = wc.id
		left join campaign as c
		on wc.campaign_id = c.campaign_id
		left join wink_gate_points_earned as e
		on e.bookingId = wb.id
		WHERE (@CURRENT_DATE between c.campaign_start_date and c.campaign_end_date)
		AND wc.id = @TLMCGoldenCampaignId 
		AND wc.[status] = 1
		AND wb.[status] = 1
		AND @validMCTLMC = 1
		GROUP BY wc.id, wc.total_points
		HAVING ISNULL(SUM(e.points),0) < wc.total_points

		-- RTS
		union

		SELECT ISNULL(sum(e.points),0) as points, wc.id as winkGateCampaign, wc.total_points
		FROM wink_gate_booking as wb
		left join wink_gate_campaign as wc
		on wb.wink_gate_campaign_id = wc.id
		left join campaign as c
		on wc.campaign_id = c.campaign_id
		left join wink_gate_points_earned as e
		on e.bookingId = wb.id
		WHERE (@CURRENT_DATE between c.campaign_start_date and c.campaign_end_date)
		AND wc.id = @RTSGateCampaignId 
		AND wc.[status] = 1
		AND wb.[status] = 1
		AND @rtsQrScanned = 1
		GROUP BY wc.id, wc.total_points
		HAVING ISNULL(SUM(e.points),0) < wc.total_points

		----TransitLink MasterCard Sapphire Gates
		--union

		--SELECT ISNULL(sum(e.points),0) as points, wc.id as winkGateCampaign, wc.total_points
		--FROM wink_gate_booking as wb
		--left join wink_gate_campaign as wc
		--on wb.wink_gate_campaign_id = wc.id
		--left join campaign as c
		--on wc.campaign_id = c.campaign_id
		--left join wink_gate_points_earned as e
		--on e.bookingId = wb.id
		--WHERE (@CURRENT_DATE between c.campaign_start_date and c.campaign_end_date)
		--AND wc.id = @TLMCSapphireCampaignId
		--AND wc.[status] = 1
		--AND wb.[status] = 1
		--AND @validOTTLMC = 1
		--AND @TLMCSapphireInventory >
		--(
		--	SELECT COUNT(*) FROM winners_points 
		--	WHERE entry_id = @TLMCSapphireWinnerEntry
		--)
		--GROUP BY wc.id, wc.total_points

		----TransitLink MasterCard Diamond Gates
		--union

		--SELECT ISNULL(sum(e.points),0) as points, wc.id as winkGateCampaign, wc.total_points
		--FROM wink_gate_booking as wb
		--left join wink_gate_campaign as wc
		--on wb.wink_gate_campaign_id = wc.id
		--left join campaign as c
		--on wc.campaign_id = c.campaign_id
		--left join wink_gate_points_earned as e
		--on e.bookingId = wb.id
		--WHERE (@CURRENT_DATE between c.campaign_start_date and c.campaign_end_date)
		--AND wc.id = @TLMCDiamondCampaignId
		--AND wc.[status] = 1
		--AND wb.[status] = 1
		--AND @validMCTLMC = 1
		--AND @TLMCDiamondInventory >
		--(
		--	SELECT COUNT(*) FROM winners_points 
		--	WHERE entry_id = @TLMCDiamondWinnerEntry
		--)
		--GROUP BY wc.id, wc.total_points

		--union

		--SELECT ISNULL(sum(e.points),0) as points, wc.id as winkGateCampaign, wc.total_points
		--FROM wink_gate_booking as wb
		--left join wink_gate_campaign as wc
		--on wb.wink_gate_campaign_id = wc.id
		--left join campaign as c
		--on wc.campaign_id = c.campaign_id
		--left join wink_gate_points_earned as e
		--on e.bookingId = wb.id
		--AND cast(e.created_at as date) = @CURRENT_DATE
		--WHERE (@CURRENT_DATE between c.campaign_start_date and c.campaign_end_date)
		--AND wc.[status] = 1
		--AND wb.[status] = 1
		--AND wc.id = @NHBWGCampaignId
		--GROUP BY wc.id, wc.total_points
		--HAVING ISNULL(SUM(e.points),0) < @NHBDailyInventory

	) as T


	IF(@customerId != 6)
	BEGIN
		SELECT count(*) as winkGateCount FROM(
			SELECT 1 as records
			FROM wink_gate_asset as a, 
			wink_gate_booking as b,
			wink_gate_pin as wp, 
			wink_gate_banner as wbanner,
			wink_gate_campaign as wc,
			campaign as c
			WHERE a.id = b.wink_gate_asset_id
			AND b.wink_gate_campaign_id = wc.id
			AND wc.campaign_id = c.campaign_id
			AND b.id = wp.wink_gate_booking_id
			AND b.id = wbanner.wink_gate_booking_id
			AND (@CURRENT_DATE between c.campaign_start_date and c.campaign_end_date)
			AND wc.[status] = 1
			AND b.[status] = 1
			AND wc.id in
			(SELECT winkGateCampaignId FROM #ActiveWINKGATECount)
			AND wc.id != 41
			AND a.[id] != 362

			union all

			SELECT 1 as records
			FROM wink_gate_asset as a, 
			wink_gate_booking as b,
			wink_gate_pin as wp, 
			wink_gate_banner as wbanner,
			wink_gate_campaign as wc,
			campaign as c
			WHERE a.id = b.wink_gate_asset_id
			AND b.wink_gate_campaign_id = wc.id
			AND wc.campaign_id = c.campaign_id
			AND b.id = wp.wink_gate_booking_id
			AND b.id = wbanner.wink_gate_booking_id
			AND (@CURRENT_DATE between c.campaign_start_date and c.campaign_end_date)
			AND wc.[status] = 1
			AND b.[status] = 1
			AND wc.id = 41
			AND @tlDemoQr = 1
		) as T
	END
	ELSE
	BEGIN
		SELECT count(*) as winkGateCount FROM(
			SELECT 1 as records
			FROM wink_gate_asset as a, 
			wink_gate_booking as b,
			wink_gate_pin as wp, 
			wink_gate_banner as wbanner,
			wink_gate_campaign as wc,
			campaign as c
			WHERE a.id = b.wink_gate_asset_id
			AND b.wink_gate_campaign_id = wc.id
			AND wc.campaign_id = c.campaign_id
			AND b.id = wp.wink_gate_booking_id
			AND b.id = wbanner.wink_gate_booking_id
			AND (@CURRENT_DATE between c.campaign_start_date and c.campaign_end_date)
			AND wc.[status] = 1
			AND b.[status] = 1
			AND wc.id in
			(SELECT winkGateCampaignId FROM #ActiveWINKGATECount)
			AND wc.id != 41

			union all

			SELECT 1 as records
			FROM wink_gate_asset as a, 
			wink_gate_booking as b,
			wink_gate_pin as wp, 
			wink_gate_banner as wbanner,
			wink_gate_campaign as wc,
			campaign as c
			WHERE a.id = b.wink_gate_asset_id
			AND b.wink_gate_campaign_id = wc.id
			AND wc.campaign_id = c.campaign_id
			AND b.id = wp.wink_gate_booking_id
			AND b.id = wbanner.wink_gate_booking_id
			AND (@CURRENT_DATE between c.campaign_start_date and c.campaign_end_date)
			AND wc.[status] = 1
			AND b.[status] = 1
			AND wc.id = 41
			AND @tlDemoQr = 1
		) as T
	END
	--ELSE
	--BEGIN
	--	SELECT 0 as winkGateCount;
	--END
END
