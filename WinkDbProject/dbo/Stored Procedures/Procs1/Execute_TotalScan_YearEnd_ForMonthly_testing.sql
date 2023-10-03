create PROCEDURE [dbo].[Execute_TotalScan_YearEnd_ForMonthly_testing]
	(
	 @year varchar(10)
	)
AS
BEGIN

insert into monthly_qrscan_records (scan_year,total_scans,scan_peroid)
SELECT @year ,COUNT(*) AS total_scans, RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4)) AS period FROM customer_earned_points 
WHERE 
CAST(YEAR(created_at) AS VARCHAR(4))=@year 
and RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4)) = '01-2022'
--and  CAST(created_at As Date) >= CAST (@from_date AS Date) and CAST(created_at As Date) <= CAST (@to_date AS Date)
GROUP BY RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))
Order by RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))


END