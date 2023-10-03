CREATE PROCEDURE [dbo].[Get_CampaignPieChart]
	
AS
BEGIN
	DECLARE @CURRENT_DATE datetime 
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
-- Campaign Temp Table
	IF OBJECT_ID('tempdb..#CAMPAIGN_Temp1') IS NOT NULL DROP TABLE #CAMPAIGN_Temp1
    -- Total Campaign
	CREATE TABLE #CAMPAIGN_Temp1
	(
			total int Default 0,
			normal_active int Default 0,
			po_active int Default 0,
			inactive int default 0,
			po_inactive int Default 0,
			closed int default 0,
			po_closed int default 0
		
 	)
 	Insert Into #CAMPAIGN_Temp1(#CAMPAIGN_Temp1.total)
	Select ISNULL(COUNT(*),0) From campaign 
	Where campaign.campaign_status = 'enable'
	
	
		-- Active Normal Campaign
 		CREATE TABLE #CAMPAIGN_Temp2
		(
			total int Default 0,
			normal_active int Default 0,
			po_active int Default 0,
			inactive int default 0,
			po_inactive int Default 0,
			closed int default 0,
			po_closed int default 0
			
 		)
		Insert Into #CAMPAIGN_Temp2(#CAMPAIGN_Temp2.normal_active)
		Select ISNULL(COUNT(*),0) From campaign 
		WHERE campaign.campaign_status = 'enable'
		--AND campaign.wink_purchase_only =0
		AND (
		CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
			AND 
		CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
		 )
	
			-- Inactive Normal Campaign
			CREATE TABLE #CAMPAIGN_Inactive_Temp
			(	total int Default 0,
				normal_active int Default 0,
				po_active int Default 0,
				inactive int default 0,
				po_inactive int Default 0,
				closed int default 0,
				po_closed int default 0
 			)
		 	
			Insert Into #CAMPAIGN_Inactive_Temp(#CAMPAIGN_Inactive_Temp.inactive)
			Select ISNULL(COUNT(*),0) From campaign 
			WHERE campaign.campaign_status = 'enable'
			AND campaign.wink_purchase_only =0
			AND 
			CONVERT(CHAR(10),@CURRENT_DATE,111)< CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
    
					-- Expired/Closed Normal Campaign
				CREATE TABLE #CAMPAIGN_Closed_Temp
				(
					total int Default 0,
					normal_active int Default 0,
					po_active int Default 0,
					inactive int default 0,
					po_inactive int Default 0,
					closed int default 0,
					po_closed int default 0
 				)
			 	
				Insert Into #CAMPAIGN_Closed_Temp(#CAMPAIGN_Closed_Temp.closed)
				Select ISNULL(COUNT(*),0) From campaign 
				WHERE campaign.campaign_status = 'enable'
				AND campaign.wink_purchase_only =0
				--AND campaign.wink_purchase_status <> 'on hold'
				AND 
				CONVERT(CHAR(10),@CURRENT_DATE,111) > CONVERT(CHAR(10),campaign.campaign_end_date,111)





					-- Expired/Closed Normal Campaign
				CREATE TABLE #CAMPAIGN_Closed_Temp_Pur
				(
					total int Default 0,
					normal_active int Default 0,
					po_active int Default 0,
					inactive int default 0,
					po_inactive int Default 0,
					closed int default 0,
					po_closed int default 0
 				)
			 	
				Insert Into #CAMPAIGN_Closed_Temp_Pur(#CAMPAIGN_Closed_Temp_Pur.closed)
				Select ISNULL(COUNT(*),0) From campaign 
				WHERE campaign.campaign_status = 'enable'
				--AND campaign.wink_purchase_only =0
				AND campaign.wink_purchase_status = 'activate'
				AND 
				CONVERT(CHAR(10),@CURRENT_DATE,111) > CONVERT(CHAR(10),campaign.campaign_end_date,111)


	
				-- Inactive Po Campaign
						CREATE TABLE #CAMPAIGN_PO_Inactive_Temp
						(	total int Default 0,
							normal_active int Default 0,
							po_active int Default 0,
							inactive int default 0,
							po_inactive int Default 0,
							closed int default 0,
							po_closed int default 0
 						)
						Insert Into #CAMPAIGN_PO_Inactive_Temp(#CAMPAIGN_PO_Inactive_Temp.po_inactive)
						Select ISNULL(COUNT(*),0) From campaign 
						WHERE campaign.campaign_status = 'enable'
						AND campaign.wink_purchase_only =1
						AND campaign.wink_purchase_status ='on hold'
    
    					/*	-- Closed PO Campaign
						CREATE TABLE #CAMPAIGN_PO_Closed_Temp
						(	total int Default 0,
							normal_active int Default 0,
							po_active int Default 0,
							inactive int default 0,
							po_inactive int Default 0,
							closed int default 0,
							po_closed int default 0
 						)
					 	
						Insert Into #CAMPAIGN_PO_Closed_Temp(#CAMPAIGN_PO_Closed_Temp.po_closed)
						Select ISNULL(COUNT(*),0) From campaign 
						WHERE campaign.campaign_status = 'enable'
						AND campaign.wink_purchase_only =1
						AND campaign.campaign_id IN 
						(
 						Select campaign.campaign_id
						from campaign 
						LEFT JOIN customer_earned_winks 
						ON campaign.campaign_id = customer_earned_winks.campaign_id
						WHERE campaign.wink_purchase_only =1 
						AND campaign.campaign_status='enable'
						GROUP BY campaign.campaign_id
						HAVING SUM(campaign.total_winks)= ISNULL(SUM(customer_earned_winks.total_winks),0) 
						) */
    
    Select * from #CAMPAIGN_Temp1
	UNION
    Select * from #CAMPAIGN_Temp2
    UNION
    select * from #CAMPAIGN_Inactive_Temp
    UNION
    select * from #CAMPAIGN_PO_Inactive_Temp
    --UNION
    --select * from #CAMPAIGN_PO_Temp
    UNION
    Select * from #CAMPAIGN_Closed_Temp
	UNION
	Select * from #CAMPAIGN_Closed_Temp_Pur
    --UNION
    --select * from #CAMPAIGN_PO_Closed_Temp
    
	
END
