CREATE PROCEDURE [dbo].[Get_Total_QRScan__ByPeriod]

	(@from_date datetime,

	 @to_date datetime

	  )

AS

BEGIN

DECLARE @filer_date datetime 

EXEC GET_CURRENT_SINGAPORT_DATETIME @filer_date OUTPUT	



Select COUNT(*) as total_scans ,CAST(created_at As Date) as period from customer_earned_points

	WHERE  CAST(created_at As Date) >= CAST (@from_date AS Date) and CAST(created_at As Date) <= CAST (@to_date AS Date)

	GROUP BY CAST(created_at As Date)

	Order by CAST(created_at As Date)



	

END


