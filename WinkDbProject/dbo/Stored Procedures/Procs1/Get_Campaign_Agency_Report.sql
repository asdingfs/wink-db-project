CREATE PROCEDURE [dbo].[Get_Campaign_Agency_Report]
	(@start_date varchar(50),
	 @end_date varchar(50),
	 @campaignName varchar(100),
	 @campaignId int,
	 @companyName varchar(300))
AS
BEGIN
	IF (@start_date is null or @start_date = '')
	BEGIN
		SET @start_date = NULL;
	END
	IF (@end_date is null or @end_date = '')
	BEGIN
		SET @end_date = NULL;
	END
	IF (@campaignName is null or @campaignName = '')
	BEGIN
		SET @campaignName = NULL;
	END
	IF (@campaignId is null or @campaignId = '')
	BEGIN
		SET @campaignId = NULL;
	END
	IF (@companyName is null or @companyName = '')
	BEGIN
		SET @companyName = NULL;
	END

	SELECT CAST(campaign.created_at as Date) AS c_created_at,
	(	SElECT COUNT(customer_earned_points.campaign_id)FROM customer_earned_points
		WHERE customer_earned_points.campaign_id =campaign.campaign_id
	)AS total_scans,
	campaign.campaign_id,
	campaign.campaign_name,
	campaign.campaign_status,
	campaign.campaign_amount,
	campaign.total_winks_amount,
	CONVERT(DECIMAL(10,2),(((campaign.campaign_amount)*campaign.agency_comm)/100)) AS agency_comm,
	campaign.merchant_id,
	merchant.mas_code,
	merchant.first_name,
	merchant.last_name,
	campaign.agency,
	campaign.sales_code,
	campaign.sales_commission,
	campaign.campaign_start_date,
	campaign.campaign_end_date,
	campaign.agency_name
	FROM campaign,merchant
	WHERE campaign.merchant_id = merchant.merchant_id
	AND campaign.agency =1
	AND (@campaignId is null or campaign.campaign_id = @campaignId)
	AND (@campaignName is null or campaign.campaign_name like '%'+@campaignName+'%')
	AND (@companyName is null or ((merchant.first_name+' '+merchant.last_name) like '%'+@companyName+'%'))
	AND (@start_date IS NULL OR CAST(campaign.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date)) 
	GROUP BY campaign.campaign_id,campaign.campaign_name,campaign.campaign_status,campaign.campaign_amount,
	campaign.total_winks_amount,
	campaign.sales_commission,CAST(campaign.created_at as Date),campaign.merchant_id,
	campaign.agency_comm,
	merchant.mas_code,merchant.first_name,merchant.last_name,campaign.agency,campaign.sales_code,
	campaign.campaign_start_date,campaign.campaign_end_date,campaign.agency_name
	ORDER BY campaign.campaign_id DESC
END
