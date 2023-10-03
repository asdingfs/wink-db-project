CREATE PROCEDURE [dbo].[Get_7di_Report]
	(@start_date datetime,
	 @end_date datetime)
AS
BEGIN
--DECLARE @AGENCY_COMM DECIMAL(10,2)
--DECLARE @SALES_COMM DECIMAL(10,2)

--SET @AGENCY_COMM = (SELECT system_key_value.system_value from system_key_value where system_key_value.system_key ='agency_com');
--SET @SALES_COMM = (SELECT system_key_value.system_value from system_key_value where system_key_value.system_key ='sales_com');

IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')
BEGIN

	SELECT  CAST(campaign.created_at as Date) AS c_created_at,
	        ( SElECT COUNT(customer_earned_points.campaign_id)FROM customer_earned_points
	         WHERE customer_earned_points.campaign_id =campaign.campaign_id)AS total_scans,
	        
			campaign.campaign_id,
			campaign.campaign_name,
			campaign.campaign_amount,
			campaign.total_winks_amount,
			campaign.agency_comm,
			--CONVERT(DECIMAL(10,2),(((campaign.campaign_amount-campaign.total_winks_amount)*campaign.agency_comm)/100)) AS agency_comm,
			/*CONVERT(DECIMAL(10,2),((
			
			((campaign.campaign_amount-campaign.total_winks_amount)-
			 CONVERT(DECIMAL(10,2),(((campaign.campaign_amount-campaign.total_winks_amount)*campaign.agency_comm)/100))
			)
			*campaign.sales_commission)/100)) AS sales_commission,*/
			campaign.sales_commission,
			
			campaign.revenue_share,
			/*(campaign.campaign_amount - campaign.total_winks_amount - 
			CONVERT(DECIMAL(10,2),(((campaign.campaign_amount-campaign.total_winks_amount)*campaign.agency_comm)/100))
			-
			CONVERT(DECIMAL(10,2),((
			
			(
			(campaign.campaign_amount-campaign.total_winks_amount)-
			 CONVERT(DECIMAL(10,2),(((campaign.campaign_amount-campaign.total_winks_amount)*campaign.agency_comm)/100))
			))))) AS net_revenue,
			
			(campaign.campaign_amount - campaign.total_winks_amount - 
			CONVERT(DECIMAL(10,2),(((campaign.campaign_amount-campaign.total_winks_amount)*campaign.agency_comm)/100))
			-
			CONVERT(DECIMAL(10,2),((
			
			(
			(campaign.campaign_amount-campaign.total_winks_amount)-
			 CONVERT(DECIMAL(10,2),(((campaign.campaign_amount-campaign.total_winks_amount)*campaign.agency_comm)/100))
			)))))*(campaign.revenue_share/100) AS revenue_share,*/
					
			campaign.merchant_id,
			merchant.mas_code,
			merchant.first_name,
			merchant.last_name,
			campaign.agency,
			campaign.sales_code,
			campaign.sales_commission,
			campaign.campaign_start_date,
			campaign.campaign_end_date
			
			FROM campaign,merchant
		WHERE campaign.merchant_id = merchant.merchant_id
	    AND ( campaign.agency =1 OR campaign.sales_code !='')
        AND CAST(campaign.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date)
		--AND CAST(customer_earned_points.created_at as Date)>= @start_date 
		--AND CAST(customer_earned_points.created_at as DATE) <= @end_date
		GROUP BY campaign.campaign_id,campaign.campaign_name,campaign.campaign_amount,campaign.total_winks_amount,
		campaign.sales_commission,CAST(campaign.created_at as Date),campaign.merchant_id,
		campaign.agency_comm,campaign.sales_commission,campaign.revenue_share,
		merchant.mas_code,merchant.first_name,merchant.last_name,campaign.agency,campaign.sales_code,
		campaign.campaign_start_date,campaign.campaign_end_date
		ORDER BY campaign_id DESC
END		
	ELSE
		BEGIN
				SELECT  CAST(campaign.created_at as Date) AS c_created_at,
	        ( SElECT COUNT(customer_earned_points.campaign_id)FROM customer_earned_points
	         WHERE customer_earned_points.campaign_id =campaign.campaign_id)AS total_scans,
	        
			campaign.campaign_id,
			campaign.campaign_name,
			campaign.campaign_amount,
			campaign.total_winks_amount,
			campaign.agency_comm,
			--CONVERT(DECIMAL(10,2),(((campaign.campaign_amount-campaign.total_winks_amount)*campaign.agency_comm)/100)) AS agency_comm,
			/*CONVERT(DECIMAL(10,2),((
			
			((campaign.campaign_amount-campaign.total_winks_amount)-
			 CONVERT(DECIMAL(10,2),(((campaign.campaign_amount-campaign.total_winks_amount)*campaign.agency_comm)/100))
			)
			*campaign.sales_commission)/100)) AS sales_commission,*/
			campaign.sales_commission,
			
			campaign.revenue_share,
		
						
			/*(campaign.campaign_amount - campaign.total_winks_amount - 
			CONVERT(DECIMAL(10,2),(((campaign.campaign_amount-campaign.total_winks_amount)*campaign.agency_comm)/100))
			-
			CONVERT(DECIMAL(10,2),((
			
			(
			(campaign.campaign_amount-campaign.total_winks_amount)-
			 CONVERT(DECIMAL(10,2),(((campaign.campaign_amount-campaign.total_winks_amount)*campaign.agency_comm)/100))
			)))))*(campaign.revenue_share/100) AS revenue_share,*/
		    campaign.merchant_id,
			merchant.mas_code,
			merchant.first_name,
			merchant.last_name,
			campaign.agency,
			campaign.sales_code,
			--CONVERT(DECIMAL(10,2),(((campaign.campaign_amount-campaign.total_winks_amount)*@SALES_COMM)/100)) AS sales_commission,

			campaign.sales_commission,
			campaign.campaign_start_date,
			campaign.campaign_end_date
			
			FROM campaign,merchant
		WHERE campaign.merchant_id = merchant.merchant_id
	    AND ( campaign.agency =1 OR campaign.sales_code !='')
        --AND CAST(campaign.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date)
		--AND CAST(customer_earned_points.created_at as Date)>= @start_date 
		--AND CAST(customer_earned_points.created_at as DATE) <= @end_date
		GROUP BY campaign.campaign_id,campaign.campaign_name,campaign.campaign_amount,
		campaign.total_winks_amount,campaign.agency_comm,campaign.sales_commission,
		campaign.sales_commission,CAST(campaign.created_at as Date),campaign.merchant_id,
		merchant.mas_code,merchant.first_name,merchant.last_name,campaign.agency,campaign.sales_code,
		campaign.revenue_share,
		campaign.campaign_start_date,campaign.campaign_end_date
		ORDER BY campaign.campaign_id DESC
		
		END
	
		

END

--select * from campaign where sales_code !=''

--SELECT * FROM system_key_value
--update campaign set sales_commission = 1 where campaign.sales_code !='' 

--update campaign set agency_comm =15 where campaign.agency=1

--update campaign set revenue_share =20
