

CREATE Procedure [dbo].[Get_Active_WINKTag]
as 
BEGIN
Declare @current_date datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

-- Check WINK Tag Booking
IF EXISTS ( select 1 from asset_management_booking as b where CAST(@current_date as date)
Between CAST (b.start_date as date) and CAST (b.end_date as date) and b.winktag_id !=0)
BEGIN

print('dfkdjfd')
select Cast(b.start_date as date),c.campaign_name,c.campaign_id,b.asset_type_management_id,b.booking_id,b.scan_value,w.wink_content,
s.small_image_name,s.small_image_url,l.large_image_name,l.large_image_url
 from campaign as c,asset_management_booking as b,campaign_small_image as s ,campaign_large_image as l,
  campaign_winktag as w
where c.campaign_id =b.campaign_id 
and b.image_id= s.id
and l.campaign_id = c.campaign_id
and w.id = b.winktag_id
and b.winktag_id !=0
and CAST (@current_date as date) between Cast(b.start_date as date) and Cast(b.end_date as date)

END

END


