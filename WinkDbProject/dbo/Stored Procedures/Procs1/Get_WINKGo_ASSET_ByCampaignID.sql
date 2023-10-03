CREATE PROCEDURE [dbo].[Get_WINKGo_ASSET_ByCampaignID]
(
	@campaign_id int
)
AS
BEGIN
    Declare @current_datetime datetime
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime Output
	Declare @global_campaign int
	set @global_campaign =1 --testing

	-- for WFH 2021 winkcity
	IF @campaign_id = 207 
	BEGIN
		select 'wfh2021_winkgo_banner.jpg' as [image], 207, 'https://www.facebook.com/winkwinksg' as [url]  
	END
	ELSE IF @campaign_id>0
	BEGIN
		IF EXISTS (SELECT 1 from ASSET_WINKGO where campaign_id=@campaign_id and campaign_id>0 and status='1' and cast(to_date as date) >=  cast(@current_datetime as date) and cast(from_date as date) <=  cast(@current_datetime as date))
		BEGIN
			SELECT TOP 1 * from ASSET_WINKGO where campaign_id=@campaign_id and campaign_id>0 and status='1' and cast(to_date as date) >=  cast(@current_datetime as date) and cast(from_date as date) <=  cast(@current_datetime as date)
			order by id desc
		END
	END
	ELSE
	BEGIN
	
		--set @global_campaign =5 --production
		select w.small_image_name as [image], c.campaign_id, w.small_image_url as [url] from campaign_small_image as w , campaign as c
		where w.campaign_id = c.campaign_id
		and w.campaign_id = @global_campaign
		and w.small_image_status =1
	END
	
END

--select * from campaign


