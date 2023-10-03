CREATE PROCEDURE [dbo].[Get_WinkGateAssets_On_Map]

	
AS
BEGIN
	DECLARE @CURRENT_DATE date;     
	DECLARE @reach_multipler int 

	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT
	set @reach_multipler = 50

	

 ;with tbl as (
	SELECT * FROM(
		SELECT a.id as assetId, a.latitude+', '+a.longitude as coordinates, a.[range] as radius,
		a.gate_id, a.[description] as gate_description,	
		-- b.pushHeader,b.pushMsg, b.linkTo, 
		wp.image_url as pinImg, 
		wp.[description] as pinDesc,
		c.campaign_id,
		c.campaign_name,
		case when (@CURRENT_DATE between c.campaign_start_date and c.campaign_end_date)
		then 1 else 0  end as active_flag
		FROM wink_gate_asset as a, 
		wink_gate_booking as b,
		wink_gate_pin as wp, 
		--wink_gate_banner as wbanner,
		wink_gate_campaign as wc,
		campaign as c
		WHERE a.id = b.wink_gate_asset_id
		AND b.wink_gate_campaign_id = wc.id
		AND wc.campaign_id = c.campaign_id
		AND b.id = wp.wink_gate_booking_id
		
		
		AND (@CURRENT_DATE between c.campaign_start_date and c.campaign_end_date)

		AND wc.status = 1
		AND (b.status = 1 )
		
		--group by  a.id, c.campaign_id
		
	) as T
	--//order by T.assetId
	)
	
	 
	 ,tbl4 as (
	
		select  a.assetId, c.campaign_id, count(a.assetId) as map_total_hits from wink_gate_points_earned  as a,
		wink_gate_booking as b, 
		wink_gate_campaign as wc,
		campaign as c
		
		where  
		a.bookingId = b.id 
		AND b.wink_gate_campaign_id = wc.id
		AND wc.campaign_id = c.campaign_id
	
		AND (cast(a.created_at as date) >=  cast (c.campaign_start_date as date)
					and cast (a.created_at as date) <=  cast (c.campaign_end_date as date))
		

		AND wc.status = 1
		AND b.status = 1
		group by a.assetId,c.campaign_id
	)
	
	
	
	--select * from tbl
	
	 select a.assetId as asset_id, a.pinImg as img_url, a.pinDesc as pin_description,a.coordinates, a.gate_id,a.gate_description, a.radius, 
	
	   (d.map_total_hits*(@reach_multipler+1)) as map_total_footfall,
	   a.campaign_id,
	   a.campaign_name,
	   a.active_flag
	   from tbl as a 
	 
	   left join tbl4 as d on (a.assetId = d.assetId  and a.campaign_id = d.campaign_id)

END