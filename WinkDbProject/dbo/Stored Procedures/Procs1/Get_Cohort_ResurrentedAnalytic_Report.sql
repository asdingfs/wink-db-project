CREATE PROC [dbo].[Get_Cohort_ResurrentedAnalytic_Report]

@from_date datetime,
@to_date datetime


AS

BEGIN
/*Declare @real_total_customer INT 
set @real_total_customer = (select count(*) as
 real_total_customers from customer where cast(customer.created_at as date) <=
cast(@to_date as date))*/
select count(total_customers) as total_customers,
count(distinct scans) as scans,
	 count(distinct trips) as trips,sum(isnull(eVoucher_amount,0)) as eVoucher_amount,
	 sum(distinct redemption_eVoucher) as redemption_eVoucher, count(distinct full_page) as full_page,
	 count(distinct catfish_tracker) as catfish_tracker, count(distinct wink_tag) as wink_tag

 from 
(select distinct customer_id,count(distinct d.customer_id) as total_customers ,count(distinct d.scan_action) as scans,
	 count(distinct d.trip_action) as trips,sum(isnull(eVoucher_redemption_amount,0)) as eVoucher_amount,
	 sum(distinct total_redemption_eVoucher) as redemption_eVoucher, count(distinct full_page_tracker) as full_page,
	 count(distinct catfish_tracker) as catfish_tracker, count(distinct wink_tag) as wink_tag
	 from cohort_customer_action_detail as d
	 where Cast(d.created_at as date) >=   DateAdd(day,-90,@to_date)
     group by customer_id 
     having count(*)=1
)
as b 
where b.customer_id not in 
(select distinct customer_id from cohort_customer_action_detail as d
where Cast(d.created_at as date) <=   DateAdd(day,-90,@to_date)
and Cast(d.created_at as date) >=   DateAdd(day,-180,@to_date)
group by customer_id )

 /* select * from 
(select distinct customer_id,count(distinct d.customer_id) as total_customers ,count(distinct d.scan_action) as scans,
	 count(distinct d.trip_action) as trips,sum(isnull(eVoucher_redemption_amount,0)) as eVoucher_amount,
	 sum(distinct total_redemption_eVoucher) as redemption_eVoucher, count(full_page_tracker) as full_page,
	 count(catfish_tracker) as catfish_tracker, count(wink_tag) as wink_tag
	 from customer_action_detail as d
	 where Cast(d.created_at as date) >=   DateAdd(day,-90,'2017-05-05')
     group by customer_id 
     having count(*)=1
)
as b 
where b.customer_id not in 
(select distinct customer_id from customer_action_detail as d
where Cast(d.created_at as date) <=   DateAdd(day,-90,'2017-05-05')
and Cast(d.created_at as date) >=   DateAdd(day,-180,'2017-05-05')
group by customer_id )*/
     
	

END




 