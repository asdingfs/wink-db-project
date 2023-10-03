
CREATE  PROCEDURE [dbo].[Get_QR_Code_Scan_Report_With_Paging]
	(
	
	 @start_date datetime,
	 @end_date datetime,
	 @asset_type varchar(100),
	 @email varchar(100),
	 @intPage int,
     @intPageSize int
 )
AS
BEGIN

DECLARE @intStartRow int;
DECLARE @intEndRow int;
DECLARE @topsize int;


SET @topsize =  @intPage * @intPageSize;
print(@topsize)
SET @intStartRow = (@intPage -1) * @intPageSize + 1;
SET @intEndRow = @intPage * @intPageSize;

IF OBJECT_ID('tempdb..#QR_Report') IS NOT NULL DROP TABLE #QR_Report

CREATE TABLE #QR_Report
(
 total_scan int,
 qr_code varchar(100),
 created_date DateTime,
 created_hour int,
 
 customer_id int,
 intRow int
 
 

 )

IF OBJECT_ID('tempdb..#QR_Report_Temp') IS NOT NULL DROP TABLE #QR_Report_Temp
CREATE TABLE #QR_Report_Temp
(
 countof int

 )


 IF OBJECT_ID('tempdb..#QR_Final_Temp') IS NOT NULL DROP TABLE #QR_Final_Temp
CREATE TABLE #QR_Final_Temp
(
 total_scan int,
 qr_code varchar(100),
 created_date DateTime,
 scan_time DateTime,
 id int,

 customer_name varchar(100),
 customer_email varchar(100),
 asset_type varchar(100)



 )



 print(@asset_type);
 IF (@asset_type is null or @asset_type = '')
 BEGIN
 SET @asset_type = NULL;
 --print('asset_type is string');
 END
 IF (@email is null or @email = '')
 BEGIN
 SET @email = NULL;
 --print('@email is string');
 END

 IF (@start_date is null or @start_date = '')
 BEGIN
 SET @start_date = NULL;
 --print('@email is string');
 END

 IF (@end_date is null or @end_date = '')
 BEGIN
 SET @end_date = NULL;
 --print('@email is string');
 END

 INSERT INTO #QR_Report_Temp 
SELECT  COUNT(*)

	 from customer_earned_points
	
	Where  (@start_date IS NULL OR CAST(customer_earned_points.created_at as Date) BETWEEN @start_date AND @end_date) 

	Group by customer_earned_points.qr_code, 
	customer_earned_points.customer_id,     
	CAST(customer_earned_points.created_at as Date),
	datepart(HOUR,customer_earned_points.created_at)
	
	--As countof

	--select count(*) from #QR_Report_Temp

  INSERT INTO #QR_Report
	SELECT TOP (@topsize) Count(*)As total_scan ,customer_earned_points.qr_code 

	
	



	,CAST(customer_earned_points.created_at as Date) as created_date ,datepart(HOUR,customer_earned_points.created_at)as created_hour
	, customer_earned_points.customer_id as customer_id
	


	,ROW_NUMBER() OVER(order by
			CAST (
			(Concat
			(
			CAST(customer_earned_points.created_at as Date),
			' ',
			datepart(HOUR,customer_earned_points.created_at),
			':00:00'
			)) AS Datetime) 
			
			 desc)  as intRow



    

	 from customer_earned_points
	
	Where  (@start_date IS NULL OR CAST(customer_earned_points.created_at as Date) BETWEEN @start_date AND @end_date) 
	
	
	
	
	
	Group by customer_earned_points.qr_code, customer_earned_points.customer_id,     CAST(customer_earned_points.created_at as Date),datepart(HOUR,customer_earned_points.created_at)
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
		
		

		INSERT INTO #QR_Final_Temp
		Select  #QR_Report.total_scan

		,#QR_Report.qr_code

		,DateAdd(HOUR,#QR_Report.created_hour,#QR_Report.created_date)as created_at

		,(Select Top 1 customer_earned_points.created_at from customer_earned_points 

		Where customer_earned_points.qr_code = #QR_Report.qr_code
		 and CAST(#QR_Report.created_date as DATE) = CAST (customer_earned_points.created_at AS Date)
		 AND datepart(HOUR,customer_earned_points.created_at) = #QR_Report.created_hour
		order by customer_earned_points.created_at desc)as scan_time
		
		,ROW_NUMBER() OVER(ORDER BY (Select Top 1 customer_earned_points.created_at from customer_earned_points Where customer_earned_points.qr_code = #QR_Report.qr_code
		 and CAST(#QR_Report.created_date as DATE) = CAST (customer_earned_points.created_at AS Date)
		 AND datepart(HOUR,customer_earned_points.created_at) = #QR_Report.created_hour
		order by customer_earned_points.created_at) desc) as id

		
		

		,customer.first_name + ' ' + customer.last_name as customer_name
		,customer.email as  customer_email
		,asset_type_management.station_name as asset_type
		
		

		
		

	    from #QR_Report 
		
		JOIN customer

		ON #QR_Report.customer_id = customer.customer_id

		JOIN asset_type_management

		ON #QR_Report.qr_code = asset_type_management.qr_code_value

		where  (@asset_type IS NULL OR asset_type_management.station_name like '%' + @asset_type + '%') 
		AND (@email IS NULL OR customer.email like '%' + @email + '%') 




		SELECT *,( select count(*) from #QR_Report_Temp ) as total_count FROM #QR_Final_Temp WHERE id BETWEEN @intStartRow AND @intEndRow 

		--intRow BETWEEN @intStartRow AND @intEndRow AND
		
		
		
		--AND asset_type_management.station_name like '%' + @asset_type + '%'
		
		--(asset_type_management.station_name like '%' OR asset_type_management.station_name like '%' + @asset_type + '%') 
		--(@asset_type IS NULL OR asset_type_management.station_name like '%' + @asset_type + '%') 
		--AND asset_type_management.station_name like '%' + ISNULL(@asset_type,NULL) + '%'
		

		--order by scan_time desc
		
		--print('%' + ISNULL(@asset_type ,NULL) + '%');
		--print('%' + @asset_type + '%');
	
		 
END



