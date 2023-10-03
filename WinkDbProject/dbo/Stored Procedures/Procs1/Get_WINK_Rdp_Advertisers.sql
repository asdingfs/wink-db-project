CREATE PROCEDURE [dbo].[Get_WINK_Rdp_Advertisers]
(
	@industryId int
)
AS
BEGIN

	DECLARE @CURRENT_DATE DATETIME
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT

	IF OBJECT_ID('tempdb..#ValidAdvCampaigns') IS NOT NULL DROP TABLE #ValidAdvCampaigns
	CREATE TABLE #ValidAdvCampaigns
	(
		campaignId int,
		campaignName varchar(100),
		merchantId int,
		campaignStartDate datetime
	)
	INSERT INTO #ValidAdvCampaigns (campaignId, campaignName, merchantId, campaignStartDate)
	SELECT c.campaign_id, c.campaign_name, c.merchant_id, c.campaign_start_date
	FROM campaign as c
	left join customer_earned_winks as e
	ON c.campaign_id = e.campaign_id
	WHERE c.campaign_status ='enable'
	AND CAST (@CURRENT_DATE as date) >= CAST(c.campaign_start_date as date)
	AND 
	(
		(c.wink_purchase_only = 1 and c.wink_purchase_status ='activate')
		OR 
		(c.wink_purchase_only =0 )
	)
	group by c.campaign_id, c.total_winks, c.total_wink_confiscated, c.campaign_name, c.merchant_id, c.campaign_start_date
	HAVING ISNULL(SUM(e.total_winks),0) < (ISNULL(c.total_winks,0)+ ISNULL(c.total_wink_confiscated,0));

	--manually add TL MC campaign into the list as the wink balance is 0
	--INSERT INTO #ValidAdvCampaigns (campaignId, campaignName, merchantId, campaignStartDate)
	--SELECT campaign_id,campaign_name,merchant_id,campaign_start_date
	--FROM campaign
	--where (campaign_id =210 or campaign_id = 211)
	--AND (CAST (@CURRENT_DATE as date) BETWEEN CAST(campaign_start_date as date) AND CAST(campaign_end_date as date))
	--AND campaign_status = 'enable';

	SELECT  l.large_image_name as large_banner, l.large_image_url as large_url, l.id as banner_id,
	campaign_small_image.small_image_name as small_banner,
	v.campaignId, v.campaignName
	FROM #ValidAdvCampaigns as v
	LEFT JOIN merchant_industry
	ON v.merchantId = merchant_industry.merchant_id
	LEFT JOIN industry
	ON merchant_industry.industry_id = industry.industry_id
	LEFT JOIN campaign_small_image 
	ON v.campaignId = campaign_small_image.campaign_id
	LEFT JOIN campaign_large_image as l
	ON v.campaignId = l.campaign_id
	WHERE industry.industry_id = @industryId
	AND l.large_image_status = '1'
	AND campaign_small_image.small_image_status = '1'
	order by v.campaignStartDate desc

END