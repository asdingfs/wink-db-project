CREATE Procedure [dbo].[Get_Active_WINK_OO_Campaign]

AS
BEGIN

Declare @current_datetime datetime
Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output
select answer from wink_oo_campaign_luckydraw_detail where cast(from_time as datetime)< 
cast(@current_datetime as datetime) and 
cast(@current_datetime as datetime) <= cast(to_time as datetime)

END


--select * from wink_oo_campaign_luckydraw_detail

/*

select * from [wink_oo_campaign_luckydraw_winner]
alter table [wink_oo_campaign_luckydraw_winner] add customer_id int*/


--select * from wink_oo_campaign_luckydraw_winner

/*select * from wink_oo_campaign_luckydraw_detail*/

