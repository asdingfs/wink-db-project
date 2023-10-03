CREATE  PROCEDURE [dbo].[Get_QR_Code_Scan_Report]
	(@start_date datetime,
	 @end_date datetime)
AS
BEGIN

IF OBJECT_ID('tempdb..#QR_Report') IS NOT NULL DROP TABLE #QR_Report

CREATE TABLE #QR_Report
(
 total_scan int,
 qr_code varchar(100),
 created_date DateTime,
 created_hour int
 
 )

IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date!='')
BEGIN

    INSERT INTO #QR_Report
	Select Count(*)As total_scan ,customer_earned_points.qr_code ,
	CAST(customer_earned_points.created_at as Date) as created_date ,datepart(HOUR,customer_earned_points.created_at)as created_hour
	 from customer_earned_points
	
	Where  CAST(customer_earned_points.created_at as Date) BETWEEN @start_date AND @end_date
	
	Group by customer_earned_points.qr_code,CAST(customer_earned_points.created_at as Date),datepart(HOUR,customer_earned_points.created_at)
			order by
			CAST (
			(Concat
			(
			CAST(customer_earned_points.created_at as Date),
			' ',
			datepart(HOUR,customer_earned_points.created_at),
			':00:00'
			)) AS Datetime) 
			
			 desc

     
	

END
	ELSE
	
		BEGIN
			INSERT INTO #QR_Report
			Select Count(*)As total_scan , customer_earned_points.qr_code 
			,CAST(customer_earned_points.created_at as Date) as created_date ,datepart(HOUR,customer_earned_points.created_at)as created_hour
			from customer_earned_points
	
			--Where  CAST(customer_earned_points.created_at as Date) BETWEEN @start_date AND @end_date
	
			--Group by customer_earned_points.qr_code
			--Order by customer_earned_points.created_at desc
			Group by customer_earned_points.qr_code,CAST(customer_earned_points.created_at as Date),datepart(HOUR,customer_earned_points.created_at)
			order by
			CAST (
			(Concat
			(
			CAST(customer_earned_points.created_at as Date),
			' ',
			datepart(HOUR,customer_earned_points.created_at),
			':00:00'
			)) AS Datetime) 
		    desc
				 
		
		END
		
		
		
		/*select #QR_Report.total_scan,#QR_Report.qr_code,DateAdd(HOUR,#QR_Report.created_hour,#QR_Report.created_date)as created_at from #QR_Report
		order by DateAdd(HOUR,#QR_Report.created_hour,#QR_Report.created_date)desc*/
		
		Select #QR_Report.total_scan,#QR_Report.qr_code,DateAdd(HOUR,#QR_Report.created_hour,#QR_Report.created_date)as created_at,
		(Select Top 1 customer_earned_points.created_at from customer_earned_points Where customer_earned_points.qr_code = #QR_Report.qr_code
		 and CAST(#QR_Report.created_date as DATE) = CAST (customer_earned_points.created_at AS Date)
		 AND datepart(HOUR,customer_earned_points.created_at) = #QR_Report.created_hour
		order by customer_earned_points.created_at desc)as scan_time
	    from #QR_Report 
	    order by scan_time desc
		
		
		
		
END

--select * from customer_earned_points where CAST(customer_earned_points.created_at as Date) = '2016-02-13' order by created_at desc

