CREATE PROCEDURE [dbo].[Execute_TotalScan_YearEnd_ForMonthly]
	(
	 @year varchar(10)
	)
AS
BEGIN

DECLARE @count INT;
DECLARE @monthly VARCHAR(19)
SET @count = 1;
    
WHILE @count<= 12
BEGIN
  set @monthly  =  FORMAT(@count,'00','en-US') + '-' + @year
   
   insert into monthly_qrscan_records (scan_year,total_scans,scan_peroid)
	SELECT @year ,COUNT(*) AS total_scans, RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4)) AS period FROM customer_earned_points 
	WHERE 
	CAST(YEAR(created_at) AS VARCHAR(4))=@year 
	and RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4)) = @monthly
	--and  CAST(created_at As Date) >= CAST (@from_date AS Date) and CAST(created_at As Date) <= CAST (@to_date AS Date)
	GROUP BY RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))
	Order by RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))
   SET @count = @count + 1;
END;

/*
--insert into monthly_qrscan_records (scan_year,total_scans,scan_peroid)
SELECT @year ,COUNT(*) AS total_scans, RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4)) AS period FROM customer_earned_points 
WHERE 
CAST(YEAR(created_at) AS VARCHAR(4))=@year 
and RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4)) = '12-2020'
--and  CAST(created_at As Date) >= CAST (@from_date AS Date) and CAST(created_at As Date) <= CAST (@to_date AS Date)
GROUP BY RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))
Order by RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))
*/

END
