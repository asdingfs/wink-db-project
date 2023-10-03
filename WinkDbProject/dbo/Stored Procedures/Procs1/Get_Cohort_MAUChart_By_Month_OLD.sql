CREATE PROC [dbo].[Get_Cohort_MAUChart_By_Month_OLD]
@year int

AS

BEGIN
--declare @year int
--set @year = 2017
SELECT convert(char(3),datename(month,dateadd(month, temp.period - 1, 0))) as period,churned,resurrected,newuser,quickratio,retention FROM (
select coalesce(t1.monthdate,t2.monthdate,t3.monthdate,t4.monthdate,t5.monthdate) as period,isnull(T1.Rules_Count_1,0) as churned,isnull(T2.Rules_Count_2,0) as resurrected,isnull(T3.Rules_Count_3,0) as newuser,isnull(T4.Rules_Count_4,0) as quickratio,isnull(T5.Rules_Count_5,0) as retention
FROM
(
  Select MONTH(date) AS monthdate, COUNT(date) AS Rules_Count_1 
  from  VW_EVOUCHER T1
  where YEAR(date) = convert(varchar(10),@year)  
  group by MONTH(date)
) T1
  full outer join
(
  Select MONTH(date) AS monthdate, COUNT(date) AS Rules_Count_2
  from VW_VERIFICATION_CODE T2
  where YEAR(date) = convert(varchar(10),@year)
  group by MONTH(date)
 ) T2
on T1.monthdate = T2.monthdate
full outer join
(
  Select MONTH(date) AS monthdate, COUNT(date) AS Rules_Count_3
  from VW_WINK_TO_EVOUCHER T3
  where YEAR(date) = convert(varchar(10),@year)
  group by MONTH(date)
 ) T3
 on T1.monthdate = T3.monthdate
 full outer join
(
  Select MONTH(date) AS monthdate, COUNT(date) AS Rules_Count_4
  from VW_SCAN T4
  where YEAR(date) = convert(varchar(10),@year)
  group by MONTH(date)
 ) T4
 on T1.monthdate = T4.monthdate
 full outer join
(
  Select MONTH(date) AS monthdate, COUNT(date) AS Rules_Count_5
  from VW_POINT_TO_WINK T5
  where YEAR(date) = convert(varchar(10),@year)
  group by MONTH(date)
 ) T5
 on T1.monthdate = T5.monthdate
 ) AS temp
order by temp.period desc

END

