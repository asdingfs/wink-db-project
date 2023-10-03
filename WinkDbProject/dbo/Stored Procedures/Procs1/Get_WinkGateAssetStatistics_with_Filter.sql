CREATE PROCEDURE [dbo].[Get_WinkGateAssetStatistics_with_Filter]
(
	@from_date datetime,
	@to_date datetime,
	@gate_id VARCHAR(100),
	@pin_description VARCHAR(100),
	@campaign_name VARCHAR(100) = NULL,
	@campaign_id int = NULL,
	@intPage int = 1,
	@intPageSize int = 0
)
	
AS
BEGIN
	DECLARE @CURRENT_DATE date;     
	DECLARE @reach_multipler int 
	DECLARE @intStartRow int;
    DECLARE @intEndRow int;

	--SET ARITHABORT ON
	IF @intPageSize = 0
		set @intPageSize = 1000000
    SET @intStartRow = (@intPage -1) * @intPageSize + 1;
    SET @intEndRow = @intPage * @intPageSize;

	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT
	set @reach_multipler = 50

	IF(@from_date ='' OR @to_date ='' or @from_date = NULL or @to_date = NULL )
	BEGIN
	set @from_date= NULL
	set @to_date = NULL
	
	END
	IF(@gate_id is null or @gate_id ='')
	
		SET @gate_id = NULL;
	ELSE
		SET @gate_id = UPPER(@gate_id)
	
   
   IF(@pin_description is null or @pin_description ='')
		SET @pin_description = NULL;
	ELSE
		SET @pin_description = UPPER(@pin_description)

	IF(@campaign_name is null or @campaign_name ='')
		SET  @campaign_name = NULL;
	ELSE
		SET  @campaign_name = UPPER( @campaign_name)

	IF(@campaign_id is null or @campaign_id = 0)
		SET @campaign_id = 0;

 ;with tbl as (
	SELECT * FROM(
		SELECT MAX(a.id) as assetId, MAX(a.latitude+', '+a.longitude) as coordinates, MAX(a.[range]) as radius,
		MAX(a.gate_id) as gate_id, MAX(a.[description]) as gate_description,	
		-- b.pushHeader,b.pushMsg, b.linkTo, 
		MAX(wp.image_url) as pinImg, 
		MAX(wp.[description]) as pinDesc,
		MAX(c.campaign_id) as campaign_id,
		MAX(c.campaign_name) as campaign_name,
		MAX(b.[status]) as book_status
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
		--AND b.id = wbanner.wink_gate_booking_id
		AND wc.status = '1'
		AND (@gate_id is null or UPPER(a.gate_id) like '%'+@gate_id+'%')
		AND (@pin_description is null or UPPER(wp.[description]) like '%'+@pin_description+'%')
		AND (@campaign_name is null or UPPER(c.[campaign_name]) like '%'+@campaign_name+'%')
		AND (@campaign_id = 0 or c.campaign_id = @campaign_id)
		AND (@from_date is null or  not (  @from_date > c.campaign_end_date or @to_date < c.campaign_start_date ))

		group by  a.id, c.campaign_id

		
	) as T
	--//order by T.assetId
	)

	--get 'hits' and 'impressions'
	,tbl2 as (
	
		select a.assetId, c.campaign_id, count(a.assetId) as "total_hits", (sum(a.points)*2 + count(a.assetId)) as "impressions"  from wink_gate_points_earned as a,
		wink_gate_booking as b,
		wink_gate_campaign as wc,
		campaign as c
		WHERE 
		
			
		a.bookingId = b.id
		AND b.wink_gate_campaign_id = wc.id
		AND wc.campaign_id = c.campaign_id
		AND (@campaign_name is null or UPPER(c.[campaign_name]) like '%'+@campaign_name+'%')
		AND  (@from_date is null or @to_date is null or (cast(a.created_at as date) >=  cast (@from_date as date)
					and cast (a.created_at as date) <=  cast (@to_date as date)))
		AND (@campaign_id = 0 or c.campaign_id = @campaign_id)
		AND (@from_date is null or  not (  @from_date > c.campaign_end_date or @to_date < c.campaign_start_date ))
	
		group by  a.assetId, c.campaign_id
	 )
	 --get 'respondents', 'engagement'

	 ,tbl3 as (
	
		select  COUNT(DISTINCT ( CONCAT(customer_id, '_', business_date)))  AS "respondents" ,  COUNT ( * ) + COUNT(DISTINCT ( CONCAT(customer_id, '_', business_date)))  AS "engagements" , 
	
		b.wink_gate_asset_id as assetId, c.campaign_id from nonstop_net_canid_earned_points as a,
		 wink_gate_booking as b,
		 
		wink_gate_campaign as wc,
		campaign as c
		 where a.wink_gate_asset_id = b.id  
		 AND b.wink_gate_campaign_id = wc.id
		AND wc.campaign_id = c.campaign_id
		AND (@campaign_name is null or UPPER(c.[campaign_name]) like '%'+@campaign_name+'%')
		AND  (@from_date is null or @to_date is null or (cast(a.created_at as date) >=  cast (@from_date as date)
					and cast (a.created_at as date) <=  cast (@to_date as date)))
		AND (@campaign_id = 0 or c.campaign_id = @campaign_id)
		AND (@from_date is null or  not (  @from_date > c.campaign_end_date or @to_date < c.campaign_start_date ))
		and a.points_credit_status = 1
		group by b.wink_gate_asset_id,  c.campaign_id
	 )
	 
	
	 ,tbl4 as (
	
		select   COUNT ( * )  AS "total_points" , 
	
		b.wink_gate_asset_id as assetId, c.campaign_id from nonstop_net_canid_earned_points as a,
		 wink_gate_booking as b,
		 
		wink_gate_campaign as wc,
		campaign as c
		 where a.wink_gate_asset_id = b.id  
		 AND b.wink_gate_campaign_id = wc.id
		AND wc.campaign_id = c.campaign_id
		AND (@campaign_name is null or UPPER(c.[campaign_name]) like '%'+@campaign_name+'%')
		AND  (@from_date is null or @to_date is null or (cast(a.created_at as date) >=  cast (@from_date as date)
					and cast (a.created_at as date) <=  cast (@to_date as date)))
		AND (@campaign_id = 0 or c.campaign_id = @campaign_id)
		AND (@from_date is null or  not (  @from_date > c.campaign_end_date or @to_date < c.campaign_start_date ))
	
		group by b.wink_gate_asset_id,  c.campaign_id
	 )
	
	
	
	--select * from tbl2
	,tbl5 as (

	 select
	 ROW_NUMBER() OVER(order by b.total_hits desc) as intRow, 
	COUNT(a.assetId) OVER() AS total_count ,   
	a.book_status,
	 a.assetId as asset_id, a.pinImg as img_url, a.pinDesc as pin_description,a.coordinates, a.gate_id,a.gate_description, a.radius, 
	 b.total_hits,
	 (b.total_hits*@reach_multipler) as total_reach,
	 (b.total_hits*(@reach_multipler+1) ) as total_footfall,
	  b.impressions, 
	   a.campaign_id,
	   a.campaign_name,
	   c.respondents ,
	   c.engagements,
	   d.total_points,
	   case when (b.impressions is null or b.impressions = 0 ) then 0 else c.engagements*100/b.impressions  end as engagement_rate,
	   case when (d.total_points is null or d.total_points =0) then 0 else (c.engagements-c.respondents)*100/d.total_points  end as point_redemption_rate
	  
	   from tbl as a 
	   left join tbl2 as b on (a.assetId = b.assetId and a.campaign_id = b.campaign_id)
	   left join tbl3 as c on (a.assetId = c.assetId and a.campaign_id = c.campaign_id)
		left join tbl4 as d on (a.assetId = d.assetId and a.campaign_id = d.campaign_id)
	   --order by b.total_hits desc
	    where not (b.total_hits=0 and a.book_status = 0)
	   )

	    ,tbl6 as 
	  (
	  
		 select sum(total_hits) as sum_total_hits,
				sum(Total_reach) as sum_total_reach,
				sum(Total_footfall) as sum_total_footfall,
				sum(Respondents) as sum_respondents,
				sum(Impressions) as sum_impressions,
				sum(Engagements) as sum_engagements,
				sum(Total_points) as sum_total_points
				 from tbl5
	  )
	  
	   select tbl6.*, tbl5.* from tbl5, tbl6 where tbl5.intRow  between @intStartRow and @intEndRow order by tbl5.intRow

	
END