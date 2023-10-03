CREATE PROCEDURE [dbo].[Get_Finance_Maseter_Report]
	(@year varchar(10))
AS
BEGIN
Declare @selected_year int 
set @selected_year = @year
select c.campaign_id,ISNULL(c.total_wink_confiscated,0) as total_wink_confiscated
,m.first_name+' '+ m.last_name as ads_name,m.mas_code,c.campaign_name
,c.campaign_amount,c.total_winks,c.total_winks_amount,c.campaign_code as contract_no,
ISNULL(w1.jan_redeemed_winks,0) as jan,ISNULL(feb_redeemed_winks,0) as feb,
ISNULL(march_redeemed_winks,0) as march,
ISNULL(april_redeemed_winks,0) as april ,ISNULL(may_redeemed_winks,0) as may,
ISNULL(June_redeemed_winks,0)as june, 
ISNULL(july_redeemed_winks,0) as july,
ISNULL(aug_redeemed_winks,0) as aug,
ISNULL(sept_redeemed_winks,0) as sept,
ISNULL(oct_redeemed_winks,0) as oct,
ISNULL(nov_redeemed_winks,0) as nov,
ISNULL(dec_redeemed_winks,0) as dec,
c.created_at,

(ISNULL(w1.jan_redeemed_winks,0)+ISNULL(feb_redeemed_winks,0)+ISNULL(march_redeemed_winks,0)+
ISNULL(april_redeemed_winks,0)+ISNULL(may_redeemed_winks,0)+ISNULL(June_redeemed_winks,0)+
ISNULL(july_redeemed_winks,0)+ISNULL(aug_redeemed_winks,0)+ISNULL(sept_redeemed_winks,0)+
ISNULL(oct_redeemed_winks,0)+
ISNULL(nov_redeemed_winks,0)+
ISNULL(dec_redeemed_winks,0)) as total_redeemed_winks


 from campaign as c
join merchant as m
on c.merchant_id = m.merchant_id

left join
(
 
SELECT DATEPART(Year, created_at) Year, DATEPART(Month, created_at) Month, SUM(total_winks) as jan_redeemed_winks,campaign_id
FROM customer_earned_winks
where DATEPART(Month, created_at) = 1 and DATEPART(Year, created_at) = (@selected_year+1)
GROUP BY DATEPART(Year, created_at), DATEPART(Month, created_at),campaign_id
) as w1
on w1.campaign_id = c.campaign_id

left join
(
 
SELECT DATEPART(Year, created_at) Year, DATEPART(Month, created_at) Month, SUM(total_winks) as feb_redeemed_winks,campaign_id
FROM customer_earned_winks
where DATEPART(Month, created_at) = 2 and DATEPART(Year, created_at) = (@selected_year+1)
GROUP BY DATEPART(Year, created_at), DATEPART(Month, created_at),campaign_id
) as w2
on w2.campaign_id = c.campaign_id
left join
(
 
SELECT DATEPART(Year, created_at) Year, DATEPART(Month, created_at) Month, SUM(total_winks) as march_redeemed_winks,campaign_id
FROM customer_earned_winks
where DATEPART(Month, created_at) = 3 and DATEPART(Year, created_at) = (@selected_year+1)
GROUP BY DATEPART(Year, created_at), DATEPART(Month, created_at),campaign_id
) as w3

on w3.campaign_id = c.campaign_id

left join
(
 
SELECT DATEPART(Year, created_at) Year, DATEPART(Month, created_at) Month, SUM(total_winks) as april_redeemed_winks,campaign_id
FROM customer_earned_winks
where DATEPART(Month, created_at) = 4 and DATEPART(Year, created_at) = (@selected_year+1)
GROUP BY DATEPART(Year, created_at), DATEPART(Month, created_at),campaign_id
) as w4
on w4.campaign_id = c.campaign_id

left join
(
 
SELECT DATEPART(Year, created_at) Year, DATEPART(Month, created_at) Month, SUM(total_winks) as may_redeemed_winks,campaign_id
FROM customer_earned_winks
where DATEPART(Month, created_at) = 5  and DATEPART(Year, created_at) = @selected_year
GROUP BY DATEPART(Year, created_at), DATEPART(Month, created_at),campaign_id
) as w5
on w5.campaign_id = c.campaign_id

left join
(
 
SELECT DATEPART(Year, created_at) Year, DATEPART(Month, created_at) Month, SUM(total_winks) as june_redeemed_winks,campaign_id
FROM customer_earned_winks
where DATEPART(Month, created_at) = 6  and DATEPART(Year, created_at) = @selected_year
GROUP BY DATEPART(Year, created_at), DATEPART(Month, created_at),campaign_id
) as w6
on w6.campaign_id = c.campaign_id

left join
(
 
SELECT DATEPART(Year, created_at) Year, DATEPART(Month, created_at) Month, SUM(total_winks) as july_redeemed_winks,campaign_id
FROM customer_earned_winks
where DATEPART(Month, created_at) = 7 and DATEPART(Year, created_at) = @selected_year
GROUP BY DATEPART(Year, created_at), DATEPART(Month, created_at),campaign_id
) as w7
on w7.campaign_id = c.campaign_id

left join
(
 
SELECT DATEPART(Year, created_at) Year, DATEPART(Month, created_at) Month, SUM(total_winks) as aug_redeemed_winks,campaign_id
FROM customer_earned_winks
where DATEPART(Month, created_at) = 8 and DATEPART(Year, created_at) = @selected_year
GROUP BY DATEPART(Year, created_at), DATEPART(Month, created_at),campaign_id
) as w8
on w8.campaign_id = c.campaign_id

left join
(
 
SELECT DATEPART(Year, created_at) Year, DATEPART(Month, created_at) Month, SUM(total_winks) as sept_redeemed_winks,campaign_id
FROM customer_earned_winks
where DATEPART(Month, created_at) = 9 and DATEPART(Year, created_at) = @selected_year
GROUP BY DATEPART(Year, created_at), DATEPART(Month, created_at),campaign_id
) as w9
on w9.campaign_id = c.campaign_id

left join
(
 
SELECT DATEPART(Year, created_at) Year, DATEPART(Month, created_at) Month, SUM(total_winks) as oct_redeemed_winks,campaign_id
FROM customer_earned_winks
where DATEPART(Month, created_at) = 10 and DATEPART(Year, created_at) = @selected_year
GROUP BY DATEPART(Year, created_at), DATEPART(Month, created_at),campaign_id
) as w10
on w10.campaign_id = c.campaign_id

left join
(
 
SELECT DATEPART(Year, created_at) Year, DATEPART(Month, created_at) Month, SUM(total_winks) as nov_redeemed_winks,campaign_id
FROM customer_earned_winks
where DATEPART(Month, created_at) = 11 and DATEPART(Year, created_at) = @selected_year
GROUP BY DATEPART(Year, created_at), DATEPART(Month, created_at),campaign_id
) as w11
on w11.campaign_id = c.campaign_id

left join
(
 
SELECT DATEPART(Year, created_at) Year, DATEPART(Month, created_at) Month, SUM(total_winks) as dec_redeemed_winks,campaign_id
FROM customer_earned_winks
where DATEPART(Month, created_at) = 12 and DATEPART(Year, created_at) = @selected_year
GROUP BY DATEPART(Year, created_at), DATEPART(Month, created_at),campaign_id
) as w12
on w12.campaign_id = c.campaign_id

order by c.created_at

END
