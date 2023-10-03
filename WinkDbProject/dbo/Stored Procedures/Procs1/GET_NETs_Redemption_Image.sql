CREATE Procedure [dbo].[GET_NETs_Redemption_Image]

AS
BEGIN
DECLARE @created_at datetime

EXEC GET_CURRENT_SINGAPORT_DATETIME @created_at output
--print (@created_at)
SELECT l.large_image_name,l.large_image_url ,l.id FROM campaign_large_image AS l , campaign as c
WHERE l.campaign_id = c.campaign_id 
and large_image_status =1 
--and cast(c.campaign_start_date as date) <= cast(@created_at as date)
and cast(c.campaign_end_date as date) > = cast(@created_at as date)

END