CREATE PROCEDURE [dbo].[Get_Total_QRScan_By_Yeartodate_withYear]
	(
	 @year varchar(10)
	)
AS
BEGIN

/*SELECT COUNT(*) AS total_scans, CAST(MONTH(created_at) AS VARCHAR(2)) + '-' + CAST(YEAR(created_at) AS VARCHAR(4)) AS period FROM customer_earned_points 
WHERE  CAST(created_at As Date) >= CAST (@from_date AS Date) and CAST(created_at As Date) <= CAST (@to_date AS Date)
GROUP BY CAST(MONTH(created_at) AS VARCHAR(2)) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))
Order by CAST(MONTH(created_at) AS VARCHAR(2)) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))*/

select total_scans,scan_peroid as period from 
monthly_qrscan_records WHERE scan_year = @year order by scan_peroid asc 

/*SELECT COUNT(*) AS total_scans, RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4)) AS period FROM customer_earned_points 
WHERE 
CAST(YEAR(created_at) AS VARCHAR(4))=@year 
--and  CAST(created_at As Date) >= CAST (@from_date AS Date) and CAST(created_at As Date) <= CAST (@to_date AS Date)
GROUP BY RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))
Order by RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))
*/
END
