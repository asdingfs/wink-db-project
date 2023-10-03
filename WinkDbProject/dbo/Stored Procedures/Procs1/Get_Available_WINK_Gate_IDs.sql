CREATE PROCEDURE [dbo].[Get_Available_WINK_Gate_IDs]
(
	@winkGateCampaignId int
)
AS
BEGIN
	DECLARE @startDate date;
	DECLARE @endDate date;
	DECLARE @campaignId int;
	
	DECLARE @CURRENT_DATE Date;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT

	SELECT @startDate = c.campaign_start_date, @endDate = c.campaign_end_date, @campaignId = c.campaign_id
	FROM campaign as c, wink_gate_campaign as w
	WHERE w.id = @winkGateCampaignId
	AND w.campaign_id = c.campaign_id;
	print(@campaignId);

	-- not global campaign
	IF(@campaignId != 1)
	BEGIN
		Select a.gate_id as gateId
		from wink_gate_asset as a
		where a.id not in
		(
			SELECT b.wink_gate_asset_id 
			FROM wink_gate_booking as b,campaign as c, wink_gate_campaign as w
			WHERE b.wink_gate_campaign_id = w.id
			AND w.campaign_id = c.campaign_id
			AND c.campaign_end_date >= @CURRENT_DATE
			AND b.[status] = 1
			AND (
					(
						(@startDate between c.campaign_start_date AND c.campaign_end_date)
						AND
						(@endDate between c.campaign_start_date AND c.campaign_end_date)
					)
					or
					(
						(c.campaign_start_date between @startDate and @endDate) 
						AND 
						(c.campaign_end_date between @startDate and @endDate)
					)
					or
					(
						(c.campaign_start_date not between @startDate and @endDate) 
						AND 
						(c.campaign_end_date between @startDate and @endDate)
					)
					or
					(
						(c.campaign_start_date between @startDate and @endDate) 
						AND 
						(c.campaign_end_date not between @startDate and @endDate)
					)
			)
			AND (	
					(	
					SELECT ISNULL(sum(e.points),0)
					FROM wink_gate_points_earned as e,	
					wink_gate_booking as wb	
					WHERE e.bookingId = wb.id	
					AND wb.wink_gate_campaign_id = w.id	
				)	
				<	
				w.total_points	
				--OR 
				--w.id = 43 --except TL finale sapphire
				--OR 
				--w.id = 46 --except TL finale diamond
			)
		)
		order by a.gate_id asc
	END
	ELSE
	BEGIN

		Select a.gate_id as gateId
		from wink_gate_asset as a
		where a.id not in
		(
			SELECT b.wink_gate_asset_id 
			FROM wink_gate_booking as b,campaign as c, wink_gate_campaign as w
			WHERE b.wink_gate_campaign_id = w.id
			AND b.[status] = 1
			AND w.campaign_id = c.campaign_id
			AND (@CURRENT_DATE between c.campaign_start_date AND c.campaign_end_date)
		)
		order by a.gate_id asc
	END
END
