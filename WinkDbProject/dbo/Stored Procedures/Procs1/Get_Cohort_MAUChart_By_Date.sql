CREATE PROC Get_Cohort_MAUChart_By_Date
@from_date datetime,
@to_date datetime

AS

BEGIN

SELECT * FROM (
select coalesce(t1.date,t2.date,t3.date,t4.date,t5.date) as period,isnull(T1.Rules_Count_1,0) as churned,isnull(T2.Rules_Count_2,0) as resurrected,isnull(T3.Rules_Count_3,0) as newuser,isnull(T4.Rules_Count_4,0) as quickratio,isnull(T5.Rules_Count_5,0) as retention
FROM
(
  Select date, COUNT(date) AS Rules_Count_1 
  from  VW_EVOUCHER T1
  group by date) T1
  full outer join
(
  Select date, COUNT(date) AS Rules_Count_2
  from VW_VERIFICATION_CODE T2
  group by date
 ) T2
on T1.date = T2.date
full outer join
(
  Select date, COUNT(date) AS Rules_Count_3
  from VW_WINK_TO_EVOUCHER T3 where CUSTOMER_ID is not null
  group by date
 ) T3
 on T1.date = T3.date
 full outer join
(
  Select date, COUNT(date) AS Rules_Count_4
  from VW_SCAN T4
  group by date
 ) T4
 on T1.date = T4.date
 full outer join
(
  Select date, COUNT(date) AS Rules_Count_5
  from VW_POINT_TO_WINK T5
  group by date
 ) T5
 on T1.date = T5.date
 ) AS temp
WHERE cast( temp.period as date) >= cast('2017-03-06' as date) and cast( temp.period as date) <= cast('2017-04-12'as date)
order by temp.period desc

END

