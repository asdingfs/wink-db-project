CREATE PROCEDURE [dbo].[Get_Total_WinkGates_Hits_ByPeriod]

	(@from_date datetime,

	 @to_date datetime,

	 @status varchar(100) = NULL

	  )

AS

BEGIN

DECLARE @filer_date datetime 

EXEC GET_CURRENT_SINGAPORT_DATETIME @filer_date OUTPUT	



		-- Filte By Today
IF (@status = 'today' or @status = 'y')
BEGIN
	IF @status = 'today'
		SET @filer_date = CAST(@filer_date as Date)
	ELSE IF (@status ='y') -- Filter By Yesterday
		SET @filer_date = dateadd(day,-1, cast(@filer_date as date))

	Select COUNT(*) as total_scans,datepart(HOUR,created_at) as period from wink_gate_points_earned
	WHERE  CAST(created_at As Date) = CAST (@filer_date AS Date)
	GROUP BY datepart(HOUR,created_at)
END

ELSE IF (@status = 'year_to_month')
BEGIN

	SELECT COUNT(*) AS total_scans, RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4)) AS period FROM wink_gate_points_earned 

	WHERE  CAST(created_at As Date) >= CAST (@from_date AS Date) and CAST(created_at As Date) <= CAST (@to_date AS Date)

	GROUP BY RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))

	Order by RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))
END
ELSE IF (@status= '2022' or @status= '2021' or @status = '2016' or @status = '2017' or @status='2018' or @status= '2019' or @status='2020')
BEGIN
SELECT COUNT(*) AS total_scans, MONTH(created_at)  AS period FROM wink_gate_points_earned 

WHERE 

CAST(YEAR(created_at) AS VARCHAR(4))= @status

--and  CAST(created_at As Date) >= CAST (@from_date AS Date) and CAST(created_at As Date) <= CAST (@to_date AS Date)

GROUP BY month(created_at)

Order by month(created_at) 
END

ELSE
 BEGIN
	Select COUNT(*) as total_scans ,CAST(created_at As Date) as period from wink_gate_points_earned

	WHERE  CAST(created_at As Date) >= CAST (@from_date AS Date) and CAST(created_at As Date) <= CAST (@to_date AS Date)

	GROUP BY CAST(created_at As Date)

	Order by CAST(created_at As Date)
  END

END


