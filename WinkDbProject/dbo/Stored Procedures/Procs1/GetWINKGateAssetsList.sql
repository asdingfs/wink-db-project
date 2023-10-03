CREATE PROCEDURE [dbo].[GetWINKGateAssetsList]
(
	@gateId varchar(100),
	@desc varchar(250),
	@bookedStatus varchar(5)
)
	
AS
BEGIN
	DECLARE @CURRENT_DATE date;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT
	
	if(@gateId is null or @gateId = '')
	BEGIN
		set @gateId = null;
	END

	if(@desc is null or @desc = '')
	BEGIN
		set @desc = null;
	END
	if(@bookedStatus is null or @bookedStatus = '')
	BEGIN
		set @bookedStatus = null;
	END

	IF(@bookedStatus is null)
	BEGIN
		SELECT a.id as assetId, a.gate_id, a.[description], a.latitude+', '+a.longitude as coordinates, 
		a.[range],
		CASE WHEN EXISTS (
			SELECT 1 
			FROM wink_gate_booking as cb,
			campaign as cc,
			wink_gate_campaign as cwc
			where cb.wink_gate_asset_id = a.id
			AND cwc.campaign_id = cc.campaign_id
			AND cb.wink_gate_campaign_id = cwc.id
			AND cb.[status] = 1
			AND (@CURRENT_DATE between cc.campaign_start_date AND cc.campaign_end_date)
			AND (
					(
					SELECT ISNULL(sum(e.points),0)
					FROM wink_gate_points_earned as e,
					wink_gate_booking as wb
					WHERE e.bookingId = wb.id
					AND wb.wink_gate_campaign_id = cwc.id
				)
				<
				cwc.total_points
			)
		) THEN 1
		ELSE 0 END 
		AS bookedStatus 
		FROM wink_gate_asset as a
		WHERE (@gateId is null or a.gate_id like '%'+@gateId+'%')
		AND (@desc is null or a.[description] like '%'+@desc+'%')
	
		order by a.created_at desc
	END
	ELSE IF(@bookedStatus like '1')
	BEGIN
		SELECT a.id as assetId, a.gate_id, a.[description], a.latitude+', '+a.longitude as coordinates, 
		a.[range],
		1 AS bookedStatus 
		FROM wink_gate_asset as a, 
		wink_gate_booking as b,
		wink_gate_campaign as wc,
		campaign as c

		WHERE a.id = b.wink_gate_asset_id
		AND b.wink_gate_campaign_id = wc.id
		AND wc.campaign_id = c.campaign_id
		AND b.[status] = 1
		AND (@gateId is null or a.gate_id like '%'+@gateId+'%')
		AND (@desc is null or a.[description] like '%'+@desc+'%')
		AND (@CURRENT_DATE between c.campaign_start_date and c.campaign_end_date)
		AND (
				(
				SELECT ISNULL(sum(e.points),0)
				FROM wink_gate_points_earned as e,
				wink_gate_booking as wb
				WHERE e.bookingId = wb.id
				AND wb.wink_gate_campaign_id = wc.id
			)
			<
			wc.total_points
		)
		order by a.created_at desc
	END
	ELSE IF(@bookedStatus like '0')
	BEGIN
		SELECT a.id as assetId, a.gate_id, a.[description], a.latitude+', '+a.longitude as coordinates, 
		a.[range],
		0 AS bookedStatus 
		FROM wink_gate_asset as a
		WHERE (@gateId is null or a.gate_id like '%'+@gateId+'%')
		AND (@desc is null or a.[description] like '%'+@desc+'%')
		AND a.id not in (
			SELECT sa.id
			FROM wink_gate_asset as sa, 
			wink_gate_booking as sb,
			wink_gate_campaign as swc,
			campaign as sc

			WHERE sa.id = sb.wink_gate_asset_id
			AND sb.wink_gate_campaign_id = swc.id
			AND swc.campaign_id = sc.campaign_id
			AND sb.[status] = 1
			AND (@CURRENT_DATE between sc.campaign_start_date and sc.campaign_end_date)
			AND (
					(
					SELECT ISNULL(sum(e.points),0)
					FROM wink_gate_points_earned as e,
					wink_gate_booking as wb
					WHERE e.bookingId = wb.id
					AND wb.wink_gate_campaign_id = swc.id
				)
				<
				swc.total_points
			)
		)
		order by a.created_at desc
	END
	
END
