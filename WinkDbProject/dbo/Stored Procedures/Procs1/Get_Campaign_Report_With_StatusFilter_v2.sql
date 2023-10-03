CREATE PROCEDURE [dbo].[Get_Campaign_Report_With_StatusFilter_v2]
	(@start_date varchar(100),
	 @end_date varchar(100),
	 @status varchar(50),
	 @campaign_name varchar(50),
	 @advertiser_name varchar(50),
	 @mascode varchar(50),
	 @campaign_code varchar(50),
	 @campaign_id int = 0,
	 @no_total_scans int = 0
	 )
AS
BEGIN
    SET NOCOUNT ON
	SET ARITHABORT ON
	DECLARE @current_date datetime
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
	
	IF @campaign_id is null or @campaign_id = 0
		set @campaign_id = NULL
	IF  @start_date  is null or @start_date = '' 
		set @start_date = @current_date
	IF  @end_date is null or @end_date = '' 
		set @end_date = @current_date
	IF @status is null or @status = '' 
		set @status = NULL
	IF @campaign_name is null or @campaign_name = '' 
		set @campaign_name = NULL
	IF @advertiser_name is null or @advertiser_name = '' 
		set @advertiser_name = NULL
	IF @mascode is null or @mascode = '' 
		set @mascode = NULL
	IF @campaign_code is null or @campaign_code = '' 
		set @campaign_code = NULL
	
	

	;with tbl as (
		SELECT campaign.campaign_id,
		campaign.campaign_name,
		merchant.first_name,
		merchant.last_name,
		merchant.mas_code,
		campaign.campaign_code,
		ISNULL(total_scans,0) as total_scans,
		campaign.campaign_amount,
		campaign.total_winks_amount,
		CAST(campaign.total_winks AS INT)+ ISNULL(campaign.total_wink_confiscated,0) As total_winks,
		ISNULL(redeemed_winks,0) as redeemed_winks,
		ISNULL(wink_gates_report.pointsBalance,0) as pointsBalance,
		campaign.agency_comm,
		campaign.campaign_start_date,
		campaign.campaign_end_date,
		campaign.campaign_status,
		campaign.wink_purchase_status,
		campaign.wink_purchase_only
		FROM campaign
		join merchant
		on campaign.merchant_id = merchant.merchant_id
		
		
		left join 
		(
			Select COUNT(*) as total_scans, campaign_id from customer_earned_points 
			where CAST(customer_earned_points.created_at as DATE)>= CAST(@start_date as DATE)      
			AND CAST(customer_earned_points.created_at as DATE)<= CAST(@end_date as DATE)
			AND @no_total_scans = 0
			group by campaign_id

			union 
			Select 0 as total_scans, campaign_id from campaign 
			where (NOT (
		    CAST(campaign.campaign_start_date as DATE) > CAST(@end_date as DATE)
		   OR CAST(campaign.campaign_end_date as DATE)  < CAST(@start_date as DATE) 
		  ))	
			AND @no_total_scans = 1
			--group by campaign_id
		) AS total_scans_report
		
		on campaign.campaign_id = total_scans_report.campaign_id
		
		left join 
		(
			SELECT SUM(ISNULL(customer_earned_winks.total_winks,0)) as redeemed_winks, campaign_id from customer_earned_winks       
			WHERE CAST(customer_earned_winks.created_at as DATE)<= CAST(@end_date as DATE)     
			group by campaign_id
		) AS WINKs
		ON campaign.campaign_id = WINKs.campaign_id
		
		left join 
		(
			SELECT (wgc.total_points - SUM(ISNULL(wge.points,0))) as pointsBalance, wgc.campaign_id
			from wink_gate_campaign as wgc   
			left join wink_gate_booking as wgb
			on wgc.id = wgb.wink_gate_campaign_id
			left join wink_gate_points_earned as wge
			on wge.bookingId = wgb.id 
			WHERE CAST(wge.created_at as DATE)<= CAST(@end_date as DATE)
			group by wgc.campaign_id, wgc.total_points
		) AS wink_gates_report
		ON campaign.campaign_id = wink_gates_report.campaign_id 
		
		-- Filter by Campaign Start date
		where 
		( 
		  NOT (
		    CAST(campaign.campaign_start_date as DATE) > CAST(@end_date as DATE)
		   OR CAST(campaign.campaign_end_date as DATE)  < CAST(@start_date as DATE) 
		  ))		
		AND  ((@campaign_name is null) or Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%') )
		AND ((@advertiser_name is null) or Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%'))
		AND ((@mascode is null) or Lower(merchant.mas_code) LIKE Lower('%'+ @mascode +'%'))
        AND ((@campaign_code is null) or Lower(campaign.campaign_code) LIKE Lower('%'+ @campaign_code +'%'))
		 AND ((@campaign_id is null) or campaign.campaign_id = @campaign_id)
		GROUP BY campaign.campaign_id,campaign.campaign_name,campaign.campaign_amount,campaign.total_winks_amount,
		campaign.wink_purchase_only, campaign.wink_purchase_status,
		campaign.total_winks,campaign.agency_comm,campaign.campaign_status,
		merchant.mas_code,merchant.first_name,merchant.last_name,
		campaign.campaign_start_date,campaign.campaign_end_date,campaign.total_wink_confiscated
		,campaign.campaign_code,total_scans,redeemed_winks, wink_gates_report.pointsBalance
		--ORDER BY campaign.campaign_id DESC
		
	--END
	)

	-- IF STATUS IS NOT NULL
	select * from tbl
	where (@status IS NULL or @status ='')
	 or ( @status='disable' and campaign_status = 'disable')
	  or ( @status='enable' and campaign_status = 'enable')
     or  (@status = 'active' and campaign_status = 'enable'	
		  AND CAST(campaign_start_date AS Date ) <= CAST(@current_date AS DATE)
		  AND CAST(campaign_end_date AS Date ) >= CAST(@current_date AS DATE) )
	 or  (@status = 'inactive' 	and campaign_status = 'enable'	
		  AND wink_purchase_only =0
		  AND CAST(campaign_start_date AS Date ) > CAST(@current_date AS DATE) )
	or  (@status = 'expired' and campaign_status = 'enable'
		  AND wink_purchase_only =0
		  AND CAST(campaign_end_date AS Date ) < CAST(@current_date AS DATE) )
	or  (@status = 'onhold' 	
		  and campaign_status = 'enable'
		  AND wink_purchase_only =1
		  AND wink_purchase_status ='on hold'
		  )
	or  (@status = 'activate' 	
		  and campaign_status = 'enable'
		  AND wink_purchase_only =1
		  AND wink_purchase_status ='activate'
		  )

	order by campaign_id desc
	OPTION (OPTIMIZE for UNKNOWN);
END
