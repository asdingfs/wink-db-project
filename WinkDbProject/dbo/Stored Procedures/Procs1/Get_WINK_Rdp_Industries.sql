CREATE PROCEDURE [dbo].[Get_WINK_Rdp_Industries] 
AS
BEGIN
	DECLARE @CURRENT_DATE DATETIME
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT

	--IF(
	--	(cast(@CURRENT_DATE as time) not between '07:00:00.000' and '08:00:00.000')
	--	AND 
	--	(cast(@CURRENT_DATE as time) not between '17:45:00.000' and '18:30:00.000')	
	--)
	--BEGIN
		IF OBJECT_ID('tempdb..#ValidIndCampaigns') IS NOT NULL DROP TABLE #ValidIndCampaigns
		CREATE TABLE #ValidIndCampaigns
		(
			campaignId int,
			merchantId int
		)
		INSERT INTO #ValidIndCampaigns (campaignId, merchantId)
		SELECT c.campaign_id, c.merchant_id
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
		group by c.campaign_id, c.total_winks, c.total_wink_confiscated, c.merchant_id
		HAVING ISNULL(SUM(e.total_winks),0) < (ISNULL(c.total_winks,0)+ ISNULL(c.total_wink_confiscated,0));

		--manually add TL MC campaign into the list as the wink balance is 0
		--INSERT INTO #ValidIndCampaigns (campaignId, merchantId)
		--SELECT campaign_id,merchant_id
		--FROM campaign
		--where (campaign_id =210 or campaign_id = 211)
		--AND (CAST (@CURRENT_DATE as date) BETWEEN CAST(campaign_start_date as date) AND CAST(campaign_end_date as date))
		--AND campaign_status = 'enable';

		SELECT industry.industry_name, industry.industry_id,
		campaign_small_image.small_image_name as small_banner
		From merchant_industry
		JOIN industry
		ON merchant_industry.industry_id = industry.industry_id
		JOIN #ValidIndCampaigns as v
		ON
		v.merchantId = merchant_industry.merchant_id
		JOIN campaign_small_image 
		ON v.campaignId = campaign_small_image.campaign_id
		WHERE campaign_small_image.small_image_status = '1'
		group by industry_name, industry.industry_id, small_image_name
	--END
	--ELSE
	--BEGIN
	--	SELECT '' as industry_name, 0 as industry_id, '' as small_banner;
	--END
END