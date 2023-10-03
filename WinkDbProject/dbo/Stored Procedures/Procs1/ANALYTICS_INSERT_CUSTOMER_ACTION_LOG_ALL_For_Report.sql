
CREATE PROC [dbo].[ANALYTICS_INSERT_CUSTOMER_ACTION_LOG_ALL_For_Report]
AS

BEGIN

truncate table cohort_customer_action_detail

INSERT INTO [dbo].[cohort_customer_action_detail]
           ([customer_action]
           ,[scan_action]
           ,[trip_action]
           ,[eVoucher_redemption_amount]
           ,[total_redemption_eVoucher]
           ,[full_page_tracker]
           ,[catfish_tracker]
           ,[wink_tag]
           ,[created_at]
           ,[customer_id])
select 1,NULL,NULL,0,NULL,NULL,NULL,NULL,temp.customer_action_date,temp.customer_id from
(
select temp.customer_id,cast(temp.action_date as date) as customer_action_date,count(*) as action_date from
(

select * from (
select customer_id,cast(created_at as date) as action_date
,count(*) as count from customer_action_log where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp 

union

select * from (
select customer_id,cast(created_at as date) as action_date
,count(*) as count from customer_earned_points where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp 

union

select * from (
select customer_id,cast(created_at as date) as action_date
,count(*) as count from customer_earned_winks where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

union

select * from (
select customer_id,cast(created_at as date) as action_date
,count(*) as count from customer_earned_evouchers where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

union

select * from (
select customer_id,cast(created_at as date) as action_date
,count(*) as count from customer_earned_evouchers where customer_id is not null and customer_id != '' and used_status = 1 group by customer_id, cast(created_at as date)) as temp

union

select * from (
select customer_id,cast(created_at as date) as action_date
,count(*) as count from eVoucher_verification where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

union

select * from (
select customer_id,cast(business_date as date) as action_date
,count(*) as count from wink_canid_earned_points where customer_id is not null and customer_id != '' group by customer_id, cast(business_date as date)) as temp

union

select * from (
select customer_id,cast(created_at as date) as action_date
,count(*) as count from can_id where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

union

select * from (
select customer_id,cast(created_at as date) as action_date
,count(*) as count from footer_ads_tracker where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

union

select * from (
select customer_id,cast(created_at as date) as action_date
,count(*) as count from popup_ads_tracker where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

union

select * from (
select customer_id,cast(created_at as date) as action_date
,count(*) as count from customer_read_news where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

/*union

select * from (
select customer_id,cast(created_at as date) as action_date
,count(*) as count from customer where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp
*/
) as temp group by temp.customer_id, cast(temp.action_date as date)

) as temp order by temp.customer_action_date asc


END


