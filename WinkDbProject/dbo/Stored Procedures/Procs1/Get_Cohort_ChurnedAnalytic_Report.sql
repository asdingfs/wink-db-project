CREATE PROC [dbo].[Get_Cohort_ChurnedAnalytic_Report]

@from_date datetime,
@to_date datetime


AS

BEGIN

Declare @real_total_customer INT 
set @real_total_customer = (select count(*) as
 real_total_customers from customer where cast(customer.created_at as date) <=
cast(@to_date as date))

  select (@real_total_customer - count(distinct d.customer_id)) as total_customers ,count(distinct d.scan_action) as scans,
	 count(distinct d.trip_action) as trips,ISNULL(sum(isnull(eVoucher_redemption_amount,0)),0) as eVoucher_amount,
	 count(distinct total_redemption_eVoucher) as redemption_eVoucher, count(distinct full_page_tracker) as full_page,
	 count(distinct catfish_tracker) as catfish_tracker, count(distinct wink_tag) as wink_tag, 1 as group_by
	 from cohort_customer_action_detail as d
	 where Cast(d.created_at as date) >=   DateAdd(day,-90,@to_date)

   /*select (@real_total_customer - count(d.customer_action)) as total_customers ,count(d.scan_action) as scans,
	 count(d.trip_action) as trips,sum(isnull(eVoucher_redemption_amount,0)) as eVoucher_amount,
	 sum(total_redemption_eVoucher) as redemption_eVoucher, count(full_page_tracker) as full_page,
	 count(catfish_tracker) as catfish_tracker, count(wink_tag) as wink_tag, 1 as group_by
	 from customer_action_detail as d
	 where Cast(d.created_at as date) >=   DateAdd(month,-3,'2017-05-05')*/
 
    /* select count(d.customer_action) as total_customers,count(d.scan_action) as scans,
	 count(d.trip_action) as trips,sum(isnull(eVoucher_redemption_amount,0)) as eVoucher_amount,
	 sum(total_redemption_eVoucher) as redemption_eVoucher, count(full_page_tracker) as full_page,
	 count(catfish_tracker) as catfish_tracker, count(wink_tag) as wink_tag, 1 as group_by
	 from customer_action_detail as d
	 where Cast(d.created_at as date) >=   DateAdd(month,-3,'2017-05-05')*/
     
	

END




 