CREATE  PROCEDURE [dbo].[Get_All_Scans_ByLocation_With_Date]
(@start_date datetime,
	 @end_date datetime,
	 @Page int,
 @PageSize int
 )
AS

DECLARE @CurrentDate Datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @CurrentDate Output

DECLARE @StartRow int;
DECLARE @EndRow int;

SET @StartRow = (@Page -1) * @PageSize + 1;
SET @EndRow = @Page * @PageSize;

IF OBJECT_ID('tempdb..#More_Scan_Report') IS NOT NULL DROP TABLE #QR_Report

CREATE TABLE #More_Scan_Report
(
 station_id int,
 station_name varchar(100),
 total_scans int,
 today_scans int

 )



IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date!='')

BEGIN

INSERT INTO #More_Scan_Report
Select t2.station_id, t2.station_name, count(*) as total_scans,
	ISNULL((
	 Select  count(*) 
	
	 from customer_earned_points as t3
	 left join asset_type_management as t4 
	 on t3.qr_code = t4.qr_code_value
	 Where t4.station_id = t2.station_id
	 and CAST(@CurrentDate As DATE) = Cast(t3.created_at As Date)
		
	 Group by Cast(t3.created_at As Date)
	),0) as today_scans
	 from customer_earned_points as t1 
	 left join asset_type_management as t2 
	 on t1.qr_code = t2.qr_code_value
		
	Group by t2.station_id, t2.station_name order by total_scans desc



END


ELSE

BEGIN

INSERT INTO #More_Scan_Report
Select t2.station_id, t2.station_name, count(*) as total_scans,
	ISNULL((
	 Select  count(*) 
	
	 from customer_earned_points as t3
	 left join asset_type_management as t4 
	 on t3.qr_code = t4.qr_code_value
	 Where t4.station_id = t2.station_id
	 and CAST(@CurrentDate As DATE) = Cast(t3.created_at As Date)
		
	 Group by Cast(t3.created_at As Date)
	),0) as today_scans
	 from customer_earned_points as t1 
	 left join asset_type_management as t2 
	 on t1.qr_code = t2.qr_code_value
		
	Group by t2.station_id, t2.station_name order by total_scans desc


END





