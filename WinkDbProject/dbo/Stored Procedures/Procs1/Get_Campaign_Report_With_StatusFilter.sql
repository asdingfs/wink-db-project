CREATE PROCEDURE [dbo].[Get_Campaign_Report_With_StatusFilter]
	(@start_date varchar(100),
	 @end_date varchar(100),
	 @status varchar(50),

	 @campaign_name varchar(50),
	 @advertiser_name varchar(50),
	 @mascode varchar(50)

	 )
AS
BEGIN
DECLARE @cents_per_wink int
DECLARE @current_date datetime

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

SET @cents_per_wink = (Select rate_conversion.rate_value from rate_conversion where rate_conversion.rate_code ='cents_per_wink')
	CREATE TABLE #temp
	(
	
   campaign_start_date varchar(80),
	campaign_end_date varchar(80),
	campaign_id int,
	campaign_code varchar(100),
	campaign_name varchar(200),
	campaign_amount decimal(10,2),
	total_winks_amount decimal(10,2),
	merchant_id int,
	campaign_status varchar(10),
	
	wink_purchase_only int,
	wink_purchase_status varchar(10),
	agency_comm decimal(10,2),
	total_winks int,
	total_campaign_wink int,
	total_wink_confiscated int,
	mas_code varchar(50),
	first_name varchar(50),
	last_name varchar(50),
	agency bit,
	sales_commission decimal(10,2),
	created_at datetime,
	total_scans int,
	redeemed_winks int)	
	-- No Filter With Start Date And End Date
	IF (@start_date IS NOT NULL AND @end_date IS NOT NUll And @start_date !='' AND @end_date !='')
		BEGIN
		   Print('Not NuLL')
			INSERT INTO #temp (
			#temp.campaign_start_date,
			#temp.campaign_end_date,
			#temp.campaign_id,
			#temp.campaign_code,
			#temp.campaign_name,
			#temp.campaign_amount,
			#temp.total_winks_amount,
			#temp.merchant_id,
			#temp.campaign_status,
			#temp.wink_purchase_only,
			#temp.wink_purchase_status,
			#temp.agency_comm,
			#temp.total_winks,
			#temp.total_campaign_wink,
			#temp.total_wink_confiscated,
			
			#temp.mas_code,
			#temp.first_name,
			#temp.last_name,
			#temp.agency,
			#temp.sales_commission,
			#temp.created_at,
			#temp.total_scans,
			#temp.redeemed_winks
			)
			SELECT  
			campaign.campaign_start_date,
			campaign.campaign_end_date,
			campaign.campaign_id,
			campaign.campaign_code,
			campaign.campaign_name,
			campaign.campaign_amount,
			campaign.total_winks_amount,
			campaign.merchant_id,
			campaign.campaign_status,
			campaign.wink_purchase_only,
			campaign.wink_purchase_status,
			campaign.agency_comm,
			CAST(campaign.total_winks AS INT)+ ISNULL(campaign.total_wink_confiscated,0) As total_winks,
			CAST(campaign.total_winks AS INT),
			ISNULL(campaign.total_wink_confiscated,0),
			merchant.mas_code,
			merchant.first_name,
			merchant.last_name,
			campaign.agency,
			campaign.sales_commission,
			campaign.created_at,
			(Select COUNT(customer_earned_points.campaign_id) from customer_earned_points 
			 where customer_earned_points.campaign_id =campaign.campaign_id
			 and CAST(customer_earned_points.created_at as DATE)>= CAST(@start_date as DATE)      
			 AND CAST(customer_earned_points.created_at as DATE)<= CAST(@end_date as DATE) 
			 
			 )AS total_scans,
			 
			/*(Select SUM(isnull(customer_earned_winks.total_winks,0)) from customer_earned_winks where campaign.campaign_id =customer_earned_winks.campaign_id
			 group by customer_earned_winks.campaign_id

			)As redeemed_winks*/
			
			(SELECT SUM(ISNULL(customer_earned_winks.total_winks,0)) from customer_earned_winks       
			WHERE customer_earned_winks.campaign_id = campaign.campaign_id      
			     
			AND CAST(customer_earned_winks.created_at as DATE)<= CAST(@end_date as DATE)      
			)
			As redeemed_winks
			FROM campaign,merchant
			WHERE campaign.merchant_id = merchant.merchant_id
			
			-- Filter by Campaign Start date
			AND 
			
						
			-- Filter by Campaign Avaiable between start date and end date
					
			(  --Start Date Filter     
     ---Not Purchase Only        
	(      
                  
		(    -- Filter with Campaign Date  
           
			
			(
			CAST(@start_date as DATE) >= CAST(campaign.campaign_start_date as DATE) and       
			CAST(@start_date as DATE) <= CAST(campaign.campaign_end_date as DATE)  
			)     
        
				 OR       
			(
			CAST(@end_date as DATE) >= CAST(campaign.campaign_start_date as DATE) and       
			CAST(@end_date as DATE) <= CAST(campaign.campaign_end_date as DATE)  
			)    
        
		) -- End Filter with Campaign Date
       
			 AND campaign.wink_purchase_only = 0      
        
	 )   ---End Not Purchase Only   
        
  OR       
        
       
	(      --- Start Purchse Only 
        
   campaign.wink_purchase_only = 1 and campaign.wink_purchase_status='activate'      
       
    
	AND 
	
		(    -- Filter with Campaign Date  
			 
        
			
			
			(
			CAST(@start_date as DATE) >= CAST(campaign.campaign_start_date as DATE) and       
			CAST(@start_date as DATE) <= CAST(campaign.campaign_end_date as DATE)  
			)     
        
				 OR       
			(
			CAST(@end_date as DATE) >= CAST(campaign.campaign_start_date as DATE) and       
			CAST(@end_date as DATE) <= CAST(campaign.campaign_end_date as DATE)  
			)   
			
			
			
        
	 )-- End Filter with Campaign Date
     
    
       
	)   --- End Purchse Only  
    
        
  )   --End Date Filter
				
			-- Filter by Campaign Created At		
			--AND CAST(campaign.created_at as Date)>= CAST(@start_date  As DATE)
			--AND CAST(campaign.created_at as DATE) <= CAST(@end_date AS Date)


			AND Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%') 
			AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%')
			AND Lower(merchant.mas_code) LIKE Lower('%'+ @mascode +'%')


			GROUP BY campaign.campaign_id,campaign.campaign_name,campaign.campaign_amount,campaign.total_winks_amount,
			campaign.sales_commission,campaign.merchant_id,campaign.wink_purchase_only,campaign.wink_purchase_status,
			campaign.total_winks,campaign.agency_comm,campaign.campaign_status,
			merchant.mas_code,merchant.first_name,merchant.last_name,campaign.agency,campaign.sales_commission,
			campaign.campaign_start_date,campaign.campaign_end_date,campaign.created_at,campaign.total_wink_confiscated,campaign.campaign_code
			ORDER BY campaign.campaign_id DESC
		
		END
	ELSE IF (@start_date IS NULL OR @end_date IS NUll OR @start_date ='' OR @end_date ='')
		BEGIN
			 Print('NuLL')
			INSERT INTO #temp (
			#temp.campaign_start_date,
			#temp.campaign_end_date,
			#temp.campaign_id,
			#temp.campaign_code,
			#temp.campaign_name,
			#temp.campaign_amount,
			#temp.total_winks_amount,
			#temp.merchant_id,
			#temp.campaign_status,
			#temp.wink_purchase_only,
			#temp.wink_purchase_status,
			#temp.agency_comm,
			#temp.total_winks,
			#temp.total_campaign_wink,
			#temp.total_wink_confiscated,
			#temp.mas_code,
			#temp.first_name,
			#temp.last_name,
			#temp.agency,
			#temp.sales_commission,
			#temp.created_at,
			#temp.total_scans,
			#temp.redeemed_winks
			)
			SELECT  
			campaign.campaign_start_date,
			campaign.campaign_end_date,
			campaign.campaign_id,
			campaign.campaign_code,
			campaign.campaign_name,
			campaign.campaign_amount,
			campaign.total_winks_amount,
			campaign.merchant_id,
			campaign.campaign_status,
			campaign.wink_purchase_only,
			campaign.wink_purchase_status,
			campaign.agency_comm,
			CAST(campaign.total_winks AS INT)+ ISNULL(campaign.total_wink_confiscated,0) As total_winks,
			CAST(campaign.total_winks AS INT),
			ISNULL(campaign.total_wink_confiscated,0),
			merchant.mas_code,
			merchant.first_name,
			merchant.last_name,
			campaign.agency,
			campaign.sales_commission,
			campaign.created_at,
			(Select COUNT(customer_earned_points.campaign_id) from customer_earned_points where customer_earned_points.campaign_id =campaign.campaign_id)AS total_scans,
			(Select SUM(isnull(customer_earned_winks.total_winks,0)) from customer_earned_winks where campaign.campaign_id =customer_earned_winks.campaign_id
			 group by customer_earned_winks.campaign_id

			)As redeemed_winks
			
			FROM campaign,merchant
			WHERE campaign.merchant_id = merchant.merchant_id

			AND Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%') 
			AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%')
			AND Lower(merchant.mas_code) LIKE Lower('%'+ @mascode +'%')

			--AND (CAST(campaign.campaign_start_date as Date) BETWEEN @start_date AND @end_date
			--AND (CAST(campaign.campaign_end_date as Date) <= @end_date))
			--AND CAST(campaign.created_at as Date)>= @start_date 
			--AND CAST(campaign.created_at as DATE) <= @end_date
			GROUP BY campaign.campaign_id,campaign.campaign_name,campaign.campaign_amount,campaign.total_winks_amount,
			campaign.sales_commission,campaign.merchant_id,campaign.wink_purchase_only,campaign.wink_purchase_status,
			campaign.total_winks,campaign.agency_comm,campaign.campaign_status,
			merchant.mas_code,merchant.first_name,merchant.last_name,campaign.agency,campaign.sales_commission,
			campaign.campaign_start_date,campaign.campaign_end_date,campaign.created_at,campaign.total_wink_confiscated,campaign.campaign_code
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
			Select * From #temp
			ORDER BY #temp.campaign_id DESC

END


--select * from campaign
