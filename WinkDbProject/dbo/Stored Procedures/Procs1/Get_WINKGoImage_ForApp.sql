CREATE PROCEDURE [dbo].[Get_WINKGoImage_ForApp]
	
AS
BEGIN
    Declare @current_datetime datetime
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime Output
	Declare @global_campaign int
	set @global_campaign =1 --testing
    --set @global_campaign =5 --production
	select * from winkgo_image as w , campaign as c
	where w.campaign_id = c.campaign_id
	and w.campaign_id = @global_campaign
	and w.image_status =1
	/*
	IF EXISTS (Select 1 from campaign where cast(campaign_end_date as date) >=  cast(@current_datetime as date) and campaign_id !=@global_campaign and campaign.campaign_status='enable')
	BEGIN
	select * from winkgo_image as w , campaign as c
	where w.campaign_id = c.campaign_id
	and w.image_status =1
	and cast(c.campaign_end_date as date) >=  cast(@current_datetime as date) 
	and w.campaign_id !=@global_campaign and c.campaign_status='enable'

	print('inside testing')

	END
	ELSE
	BEGIN


	print('inside ELSE')

	select * from winkgo_image as w , campaign as c
	where w.campaign_id = c.campaign_id
	and w.campaign_id = @global_campaign
	and w.image_status =1


	END
    
      */
    

	
END

--select * from campaign


