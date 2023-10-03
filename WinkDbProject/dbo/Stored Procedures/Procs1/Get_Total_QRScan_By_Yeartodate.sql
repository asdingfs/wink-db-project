CREATE PROCEDURE [dbo].[Get_Total_QRScan_By_Yeartodate]

	(@from_date datetime,

	 @to_date datetime

	)

AS

BEGIN



/*SELECT COUNT(*) AS total_scans, CAST(MONTH(created_at) AS VARCHAR(2)) + '-' + CAST(YEAR(created_at) AS VARCHAR(4)) AS period FROM customer_earned_points 

WHERE  CAST(created_at As Date) >= CAST (@from_date AS Date) and CAST(created_at As Date) <= CAST (@to_date AS Date)

GROUP BY CAST(MONTH(created_at) AS VARCHAR(2)) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))

Order by CAST(MONTH(created_at) AS VARCHAR(2)) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))*/





SELECT COUNT(*) AS total_scans, RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4)) AS period FROM customer_earned_points 

WHERE  CAST(created_at As Date) >= CAST (@from_date AS Date) and CAST(created_at As Date) <= CAST (@to_date AS Date)

GROUP BY RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))

Order by RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))



END




