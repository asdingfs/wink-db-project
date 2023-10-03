CREATE PROCEDURE [dbo].[Get_WINK_Rdp_Large_banner]
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
		IF OBJECT_ID('tempdb..#ValidCampaigns') IS NOT NULL DROP TABLE #ValidCampaigns
		CREATE TABLE #ValidCampaigns
		(
			campaignId int
		)
		INSERT INTO #ValidCampaigns (campaignId)
		SELECT c.campaign_id
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
		group by c.campaign_id, c.total_winks, c.total_wink_confiscated
		HAVING ISNULL(SUM(e.total_winks),0) < (ISNULL(c.total_winks,0)+ ISNULL(c.total_wink_confiscated,0));

		--manually add TL MC campaign into the list as the wink balance is 0
		--INSERT INTO #ValidCampaigns (campaignId)
		--SELECT campaign_id
		--FROM campaign
		--where (campaign_id =210 or campaign_id = 211)
		--AND (CAST (@CURRENT_DATE as date) BETWEEN CAST(campaign_start_date as date) AND CAST(campaign_end_date as date))
		--AND campaign_status = 'enable';

		SELECT l.large_image_name as large_banner, l.large_image_url as large_url, l.id as banner_id
		FROM #ValidCampaigns as v, campaign_large_image as l
		WHERE v.campaignId = l.campaign_id
		AND l.large_image_status = '1'
		ORDER BY v.campaignId desc
	--END
	--ELSE
	--BEGIN
	--	SELECT '' as large_banner,'' as large_url, 0 as banner_id;
	--END

END
