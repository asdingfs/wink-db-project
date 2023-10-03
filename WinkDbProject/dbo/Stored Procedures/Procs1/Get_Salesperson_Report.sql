CREATE PROCEDURE [dbo].[Get_Salesperson_Report]
	(@start_date datetime,
	 @end_date datetime)
AS
BEGIN

	IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')
	BEGIN
		SELECT	campaign.campaign_status,
		campaign.campaign_id,
		campaign.campaign_name,
		campaign.campaign_amount,
		campaign.total_winks_amount,
			
		CONVERT(DECIMAL(10,2),(((campaign.campaign_amount)*campaign.agency_comm)/100)) AS agency_comm,
		CONVERT(DECIMAL(10,2),((
		((campaign.campaign_amount-campaign.total_winks_amount)-
			CONVERT(DECIMAL(10,2),(((campaign.campaign_amount)*campaign.agency_comm)/100))
			) *campaign.sales_commission)/100)) AS sales_commission,
		merchant.first_name,
		merchant.last_name,
		campaign.sales_code,
		campaign.campaign_start_date,
		campaign.campaign_end_date
		FROM campaign,merchant
		WHERE campaign.merchant_id = merchant.merchant_id
	    AND ( campaign.agency =1 OR campaign.sales_code !='')
        AND CAST(campaign.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date)
	
		GROUP BY campaign.campaign_id,campaign.campaign_name,campaign.campaign_amount,campaign.campaign_status,
		campaign.total_winks_amount,campaign.agency_comm,
		campaign.sales_commission,CAST(campaign.created_at as Date),campaign.merchant_id,
		merchant.first_name,merchant.last_name,campaign.sales_code,
		campaign.campaign_start_date,campaign.campaign_end_date
		ORDER BY campaign.campaign_id DESC
	END		
	ELSE
	BEGIN
		SELECT campaign.campaign_status,
		campaign.campaign_id,
		campaign.campaign_name,
		campaign.campaign_amount,
		campaign.total_winks_amount,
		CONVERT(DECIMAL(10,2),(((campaign.campaign_amount)*campaign.agency_comm)/100)) AS agency_comm,
		CONVERT(DECIMAL(10,2),((
			
		((campaign.campaign_amount-campaign.total_winks_amount)-
			CONVERT(DECIMAL(10,2),(((campaign.campaign_amount)*campaign.agency_comm)/100))
			) *campaign.sales_commission)/100)) AS sales_commission,
		merchant.first_name,
		merchant.last_name,
		campaign.sales_code,
		campaign.campaign_start_date,
		campaign.campaign_end_date
			
		FROM campaign,merchant
		WHERE campaign.merchant_id = merchant.merchant_id
	    AND ( campaign.agency =1 OR campaign.sales_code !='')
		GROUP BY campaign.campaign_id,campaign.campaign_name,campaign.campaign_amount,campaign.campaign_status,
		campaign.total_winks_amount,campaign.agency_comm,
		campaign.sales_commission,CAST(campaign.created_at as Date),campaign.merchant_id,
		merchant.first_name,merchant.last_name,campaign.sales_code,
		campaign.campaign_start_date,campaign.campaign_end_date
		ORDER BY campaign.campaign_id DESC
	END
END