CREATE PROC [dbo].[ANALYTICS_INSERT_CUSTOMER_ACTION_LOG_ALL]
AS

BEGIN

INSERT INTO customer_action_log_summary(customer_id,customer_action_date)

select temp.customer_id,temp.customer_action_date from
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

union

select * from (
select customer_id,cast(created_at as date) as action_date
,count(*) as count from customer where customer_id is not null and customer_id != '' group by customer_id, cast(created_at as date)) as temp

) as temp group by temp.customer_id, cast(temp.action_date as date)

) as temp where cast(temp.customer_action_date as date) < cast((select today from VW_CURRENT_SG_TIME) as date) order by temp.customer_action_date asc

END

