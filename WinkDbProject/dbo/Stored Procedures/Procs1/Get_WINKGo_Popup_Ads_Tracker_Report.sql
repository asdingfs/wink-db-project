CREATE PROCEDURE [dbo].[Get_WINKGo_Popup_Ads_Tracker_Report]
(
   @url_name varchar(50),
  @customer_id varchar(10),
  @customer_email varchar(50),
  @customer_name varchar(50),
  @from_date varchar(20),
  @to_date varchar(20),
  @campaign_name varchar(50),
  @ip_address varchar(20)
)
As
BEGIN
Declare @current_datetime datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

IF (@url_name is null or @url_name='')
BEGIN
set @url_name= NULL
END
IF (@customer_id is null or @customer_id ='')
BEGIN
set @customer_id = NULL
END

IF (@customer_email is null or @customer_email ='')
BEGIN
set @customer_email = NULL
END

IF (@customer_name is null or @customer_name ='')
BEGIN
set @customer_name = NULL
END

IF (@ip_address is null or @ip_address ='')
BEGIN
set @ip_address = NULL
END

IF (@campaign_name is null or @campaign_name ='')
BEGIN
set @campaign_name = NULL
END

IF(@from_date is null or @to_date is null or @from_date ='' or @to_date ='')
BEGIN

select t.url_id,t.created_at,t.updated_at,t.id,t.url,t.customer_id,t.ip_address,cam.campaign_name,
img.winkgo_small_image as name, 
c.first_name+' '+ c.last_name as customer_name,c.email,c.gender,c.date_of_birth,
(CONVERT(int,CONVERT(char(8),@current_datetime,112))-CONVERT(char(8),CAST(c.date_of_birth as date),112))/10000 AS age

from winkgo_ads_tracker as t
join winkgo_image as img
on img.id = t.url_id
join campaign as cam
on cam.campaign_id = img.campaign_id
and (@campaign_name is null or (cam.campaign_name like '%'+@campaign_name +'%'))
left join 
customer as c
on c.customer_id = t.customer_id
where (@url_name is null or img.winkgo_small_image like '%'+@url_name+'%')
and (@customer_name is null or (c.first_name+' '+ c.last_name) like '%'+@customer_name+'%')
and (@customer_id is null or t.customer_id =@customer_id)
and (@customer_email is null or c.email like '%'+@customer_email+'%')
and (@ip_address is null or t.ip_address like '%'+@ip_address+'%')

order by created_at desc

END
ELSE 
BEGIN
select t.url_id,t.created_at,t.updated_at,t.id,t.url,t.customer_id,t.ip_address,cam.campaign_name,
img.winkgo_small_image  as name, 
c.first_name+' '+ c.last_name as customer_name,c.email,c.gender,c.date_of_birth,
(CONVERT(int,CONVERT(char(8),@current_datetime,112))-CONVERT(char(8),CAST(c.date_of_birth as date),112))/10000 AS age

from 
(select * from winkgo_ads_tracker where CAST(created_at as date) BETWEEN 
CAST(@from_date as date) and CAST(@to_date as date)
and (@ip_address is null or winkgo_ads_tracker.ip_address like '%'+@ip_address+'%')

) as t
join winkgo_image as img
on t.url_id = img.id
join campaign as cam
on cam.campaign_id = img.campaign_id
and (@campaign_name is null or (cam.campaign_name like '%'+@campaign_name +'%'))
left join 
customer as c
on c.customer_id = t.customer_id
where (@url_name is null or img.winkgo_small_image like '%'+@url_name+'%')
and (@customer_name is null or (c.first_name+' '+ c.last_name) like '%'+@customer_name+'%')
and (@campaign_name is null or (cam.campaign_name like '%'+@campaign_name +'%'))
and (@customer_id is null or t.customer_id =@customer_id)
and (@customer_email is null or c.email like '%'+@customer_email+'%')
order by created_at desc

END

END


/*select * from winkgo_ads_tracker

select * from winkgo_image*/

/*select * from NETs_CANID_Redemption_Record_SendingLog

select * from NETs_CANID_Redemption_Record_Detail*/
