Create PROCEDURE [dbo].[Get_Campaign_Report_With_StatusFilter_v2_bak4June2021]
	(@start_date varchar(100),
	 @end_date varchar(100),
	 @status varchar(50),
	 @campaign_name varchar(50),
	 @advertiser_name varchar(50),
	 @mascode varchar(50),
	 @campaign_code varchar(50)

	 )
AS
BEGIN
	set ARITHABORT ON
	set NOCOUNT ON
	DECLARE @current_date datetime
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
	
	CREATE TABLE #temp
	(
		campaign_id int,
		campaign_name varchar(200),
		first_name varchar(50),
		last_name varchar(50),
		mas_code varchar(50),
		campaign_code varchar(50),
		total_scans int,
		campaign_amount decimal(10,2),
		total_winks_amount decimal(10,2),
		total_winks int,
		redeemed_winks int,
		pointsBalance int,
		agency_comm decimal(10,2),
		campaign_start_date varchar(80),
		campaign_end_date varchar(80),
		campaign_status varchar(10),
		wink_purchase_status varchar(10),
		wink_purchase_only int
	)	
	-- No Filter With Start Date And End Date
	IF (@start_date IS NOT NULL AND @end_date IS NOT NUll And @start_date !='' AND @end_date !='')
	BEGIN
		Print('Not NuLL')
		INSERT INTO #temp (
			#temp.campaign_id,
			#temp.campaign_name,
			#temp.first_name,
			#temp.last_name,
			#temp.mas_code,
			#temp.campaign_code,
			#temp.total_scans,
			#temp.campaign_amount,
			#temp.total_winks_amount,
			#temp.total_winks,
			#temp.redeemed_winks,
			#temp.pointsBalance,
			#temp.agency_comm,
			#temp.campaign_start_date,
			#temp.campaign_end_date,
			#temp.campaign_status,
			#temp.wink_purchase_status,
			#temp.wink_purchase_only
		)
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
			Select COUNT(customer_earned_points.campaign_id) as total_scans, campaign_id from customer_earned_points 
			where CAST(customer_earned_points.created_at as DATE)>= CAST(@start_date as DATE)      
			AND CAST(customer_earned_points.created_at as DATE)<= CAST(@end_date as DATE)
			group by campaign_id
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
		(CAST(campaign.campaign_start_date as DATE) Between CAST(@start_date as DATE) and CAST(@end_date as DATE))
		AND Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%') 
		AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%')
		AND Lower(merchant.mas_code) LIKE Lower('%'+ @mascode +'%')
        AND Lower(campaign.campaign_code) LIKE Lower('%'+ @campaign_code +'%')

		GROUP BY campaign.campaign_id,campaign.campaign_name,campaign.campaign_amount,campaign.total_winks_amount,
		campaign.wink_purchase_only, campaign.wink_purchase_status,
		campaign.total_winks,campaign.agency_comm,campaign.campaign_status,
		merchant.mas_code,merchant.first_name,merchant.last_name,
		campaign.campaign_start_date,campaign.campaign_end_date,campaign.total_wink_confiscated
		,campaign.campaign_code,total_scans,redeemed_winks, wink_gates_report.pointsBalance
		ORDER BY campaign.campaign_id DESC
		
	END
	ELSE IF (@start_date IS NULL OR @end_date IS NUll OR @start_date ='' OR @end_date ='')
	BEGIN
		Print('NuLL')
		INSERT INTO #temp (
			#temp.campaign_id,
			#temp.campaign_name,
			#temp.first_name,
			#temp.last_name,
			#temp.mas_code,
			#temp.campaign_code,
			#temp.total_scans,
			#temp.campaign_amount,
			#temp.total_winks_amount,
			#temp.total_winks,
			#temp.redeemed_winks,
			#temp.pointsBalance,
			#temp.agency_comm,
			#temp.campaign_start_date,
			#temp.campaign_end_date,
			#temp.campaign_status,
			#temp.wink_purchase_status,
			#temp.wink_purchase_only
		)
		SELECT campaign.campaign_id,
		campaign.campaign_name,
		merchant.first_name,
		merchant.last_name,
		merchant.mas_code,
		campaign.campaign_code,
		(	
			Select COUNT(customer_earned_points.campaign_id) 
			from customer_earned_points 
			where customer_earned_points.campaign_id =campaign.campaign_id
		)AS total_scans,
		campaign.campaign_amount,
		campaign.total_winks_amount,
		CAST(campaign.total_winks AS INT)+ ISNULL(campaign.total_wink_confiscated,0) As total_winks,
		(
			Select SUM(isnull(customer_earned_winks.total_winks,0)) 
			from customer_earned_winks 
			where campaign.campaign_id =customer_earned_winks.campaign_id
			group by customer_earned_winks.campaign_id
		) AS redeemed_winks,
		ISNULL(wink_gates_report.pointsBalance,0) as pointsBalance,
		campaign.agency_comm,
		campaign.campaign_start_date,
		campaign.campaign_end_date,
		campaign.campaign_status,
		campaign.wink_purchase_status,
		campaign.wink_purchase_only
		FROM campaign
		left join merchant 
		ON campaign.merchant_id = merchant.merchant_id
		left join 
		(
			SELECT (wgc.total_points - SUM(ISNULL(wge.points,0))) as pointsBalance, wgc.campaign_id
			from wink_gate_campaign as wgc   
			left join wink_gate_booking as wgb
			on wgc.id = wgb.wink_gate_campaign_id
			left join wink_gate_points_earned as wge
			on wge.bookingId = wgb.id 
			group by wgc.campaign_id, wgc.total_points
		) AS wink_gates_report
		ON campaign.campaign_id = wink_gates_report.campaign_id   
		WHERE Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%') 
		AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%')
		AND Lower(merchant.mas_code) LIKE Lower('%'+ @mascode +'%')
		AND Lower(campaign.campaign_code) LIKE Lower('%'+ @campaign_code +'%')
		GROUP BY campaign.campaign_id,campaign.campaign_name,campaign.campaign_amount,campaign.total_winks_amount,
		campaign.wink_purchase_only,campaign.wink_purchase_status,
		campaign.total_winks,campaign.agency_comm,campaign.campaign_status,
		merchant.mas_code,merchant.first_name,merchant.last_name,
		campaign.campaign_start_date,campaign.campaign_end_date,campaign.total_wink_confiscated,
		campaign.campaign_code, wink_gates_report.pointsBalance
		ORDER BY campaign.campaign_id DESC
	END
		
	-- IF STATUS IS NOT NULL
		
	IF (@status='disable')
	BEGIN
		SELECT * FROM #temp WHERE #temp.campaign_status ='disable'
		ORDER BY #temp.campaign_id DESC
	END
	ELSE IF (@status='enable')
	BEGIN
		SELECT * FROM #temp WHERE #temp.campaign_status ='enable'
		ORDER BY #temp.campaign_id DESC
	END
	ELSE IF (@status ='active')
	BEGIN
		SELECT * FROM #temp WHERE #temp.campaign_status ='enable'
		AND CAST(#temp.campaign_start_date AS Date ) <= CAST(@current_date AS DATE)
		AND CAST(#temp.campaign_end_date AS Date ) >= CAST(@current_date AS DATE)
		ORDER BY #temp.campaign_id DESC
	END
	ELSE IF (@status = 'inactive')
	BEGIN
		SELECT * FROM #temp WHERE #temp.campaign_status ='enable'
		AND #temp.wink_purchase_only =0
		AND CAST(#temp.campaign_start_date AS Date ) > CAST(@current_date AS DATE)
		ORDER BY #temp.campaign_id DESC
	END
	ELSE IF (@status = 'inactive')
	BEGIN
		SELECT * FROM #temp WHERE #temp.campaign_status ='enable'
		AND #temp.wink_purchase_only =0
		AND CAST(#temp.campaign_start_date AS Date ) > CAST(@current_date AS DATE)
		ORDER BY #temp.campaign_id DESC
	END
	ELSE IF (@status = 'expired')
	BEGIN
		SELECT * FROM #temp WHERE #temp.campaign_status ='enable'
		AND #temp.wink_purchase_only =0
		AND CAST(#temp.campaign_end_date AS Date ) < CAST(@current_date AS DATE)
		ORDER BY #temp.campaign_id DESC
	END
	ELSE IF (@status = 'onhold')
	BEGIN
		SELECT * FROM #temp WHERE #temp.campaign_status ='enable'
		AND #temp.wink_purchase_only =1 
		AND #temp.wink_purchase_status ='on hold'
		ORDER BY #temp.campaign_id DESC
	END
	ELSE IF (@status = 'activate')
	BEGIN
		SELECT * FROM #temp WHERE #temp.campaign_status ='enable'
		AND #temp.wink_purchase_only =1 
		AND #temp.wink_purchase_status ='activate'
		ORDER BY #temp.campaign_id DESC
	END
	ELSE IF (@status ='' OR @status IS NULL)
	BEGIN
		Select * From #temp
		ORDER BY #temp.campaign_id DESC
	END
END
