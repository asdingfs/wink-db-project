CREATE PROCEDURE [dbo].[Get_Total_QRScan_BySpecifiedDateStatus]
	(@status varchar(50))
AS
BEGIN
DECLARE @filer_date datetime 
EXEC GET_CURRENT_SINGAPORT_DATETIME @filer_date OUTPUT
		-- Filte By Today
		IF (@status = 'today')
		BEGIN
		  SET @filer_date = CAST(@filer_date as Date)
		 
		END
		ELSE IF (@status ='y') -- Filter By Yesterday
			BEGIN
					SET @filer_date = dateadd(day,-1, cast(@filer_date as date))
					
			END
			


	Select COUNT(*) as total_scans,datepart(HOUR,created_at) as period from customer_earned_points
	WHERE  CAST(created_at As Date) = CAST (@filer_date AS Date)
	GROUP BY datepart(HOUR,created_at)

  	

END