

Create PROCEDURE [dbo].[Get_QRCodeScan_Report_With_Paging_v06]
	(
	
	 @start_date datetime,
	 @end_date datetime,
	 @asset_type varchar(100),
	 @asset_name varchar(100),
	 @email varchar(100),
	 @name varchar(100),
	 @qr_code varchar(50),
	 @qr_ip_address varchar(50),
	 @gender varchar(10),
	 @location varchar(255),
	 @status varchar(50),
	 @intPage int,
     @intPageSize int
 )
AS
BEGIN

DECLARE @intStartRow int;
DECLARE @intEndRow int;
DECLARE @topsize int;
DECLARE @station_code varchar(100);
DECLARE @cusid int;

Declare @current_datetime datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

SET @qr_code = RTRIM(LTRIM(@qr_code));
SET @topsize =  @intPage * @intPageSize;
print(@topsize)
SET @intStartRow = (@intPage -1) * @intPageSize + 1;
SET @intEndRow = @intPage * @intPageSize;


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

IF (@asset_name is null or @asset_name = '')
 BEGIN
 SET @asset_name = NULL;
 --print('asset_type is string');
 END
 ELSE
 BEGIN
 SET @asset_name = LTRIM(RTRIM(@asset_name))
 END

 --print(@asset_type);
 IF (@asset_type is null or @asset_type = '')
 BEGIN
 SET @asset_type = NULL;
 --print('asset_type is string');
 END
 ELSE
 BEGIN
 SET @asset_type = LTRIM(RTRIM(@asset_type))
 END

 IF (@email is null or @email = '')
 BEGIN
 SET @email = NULL;
 --print('@email is string');
 END
 ELSE
 BEGIN
 SET @email = LTRIM(RTRIM(@email))
 END
 
 IF (@name is null or @name = '')
 BEGIN
 SET @name = NULL;
 --print('@email is string');
 END
 ELSE
 BEGIN
 SET @name = LTRIM(RTRIM(@name))
 END

 IF (@qr_code is null or @qr_code = '')
 BEGIN
 SET @qr_code = NULL;
 --print('@email is string');
 END
 ELSE
 BEGIN
 SET @qr_code = LTRIM(RTRIM(@qr_code))
 END


 IF (@qr_ip_address is null or @qr_ip_address = '')
 BEGIN
 SET @qr_ip_address = NULL;
 --print('@email is string');
 END
 ELSE
 BEGIN
 SET @qr_ip_address = LTRIM(RTRIM(@qr_ip_address))
 END


 IF (@gender is null or @gender = '')
 BEGIN
 SET @gender = NULL;
 --print('@email is string');
 END

 IF (@location is null or @location = '')
 BEGIN
 SET @location = NULL;
 --print('@email is string');
 END
 ELSE
 BEGIN
 SET @location = LTRIM(RTRIM(@location))
 END


 IF (@status is null or @status = '')
 BEGIN
 SET @status = NULL;
 --print('@email is string');
 END 

 	SET @station_code = (SELECT Top 1 station_code FROM station WHERE station_name like  @asset_name + '%');
	SET @cusid = (SELECT Top 1 customer.customer_id FROM customer WHERE customer.email like @email + '%');


 	SELECT * FROM (SELECT customer_earned_points.points As total_scan ,customer_earned_points.qr_code 
	,customer_earned_points.GPS_location
	,customer.status as customer_status
	,customer_earned_points.ip_address
	,customer.first_name + ' ' + customer.last_name as customer_name
	,customer.email as  customer_email
	,customer.gender
   ,(CONVERT(int,CONVERT(char(8),@current_datetime,112))-CONVERT(char(8),Cast(customer.date_of_birth as date),112))/10000 AS age
	,asset_type_management.station_name as asset_type
	,asset_type_management.asset_name,
	customer_earned_points.created_at as scan_time 

	,datepart(HOUR,customer_earned_points.created_at)as created_hour
	,customer_earned_points.customer_id as customer_id

	,ROW_NUMBER() OVER(order by
			customer_earned_points.customer_id desc,
			customer_earned_points.created_at 
			
			desc) as id,
    
	COUNT(*) OVER()  as total_count

	 from customer_earned_points
	JOIN customer

		ON customer_earned_points.customer_id = customer.customer_id

		JOIN asset_type_management

		ON customer_earned_points.qr_code = asset_type_management.qr_code_value

	Where  (@start_date IS NULL OR CAST(customer_earned_points.created_at as Date) BETWEEN @start_date AND @end_date) 
	
	AND (@qr_code IS NULL OR customer_earned_points.qr_code like '%' + @qr_code + '%') 

	AND (@qr_ip_address IS NULL OR customer_earned_points.ip_address like '%' + @qr_ip_address + '%')

	AND (@asset_name IS NULL OR asset_type_management.asset_name like  '%' + @asset_name + '%') 
	AND (@asset_type IS NULL OR asset_type_management.station_name like  '%'+ @asset_type + '%') 
	AND (@email IS NULL OR customer.email like '%'+ @email + '%')
	 
	AND (@name IS NULL OR customer.first_name + ' ' + customer.last_name like '%'+ Lower(@name) +'%')
    AND (@gender IS NULL OR customer.gender = @gender )

	AND (@location IS NULL OR customer_earned_points.GPS_location like '%' + @location + '%')

    AND (@status IS NULL OR customer.status like '%' + @status + '%')

	/*Group by customer_earned_points.qr_code, customer_earned_points.GPS_location,customer_earned_points.ip_address, customer_earned_points.customer_id,     
	customer_earned_points.created_at 
	,customer.first_name, customer.last_name, customer.email, customer.status, asset_type_management.station_name,
	asset_type_management.asset_name
		,customer.gender
		,customer.date_of_birth*/
			 ) as w
			 
			 
			  where w.id between @intStartRow and @intEndRow
			  
			 order by w.scan_time desc
	

	
		 
END

