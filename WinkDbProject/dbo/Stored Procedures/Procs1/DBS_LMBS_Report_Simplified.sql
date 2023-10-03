CREATE PROC [dbo].[DBS_LMBS_Report_Simplified]
(
	@wid varchar(10),
	@qr_code varchar(50),
	@customer_id int,
	@customer_name varchar(200),
	@email varchar(200),
	@gender varchar(15),
	@qr_ip_address varchar(50),
	@location varchar(255),
	@status varchar(50),
	@start_date varchar(50),
	@end_date varchar(50)
)
AS

BEGIN

	SET @qr_code = RTRIM(LTRIM(@qr_code));

	IF(@wid is null or @wid ='')
		SET @wid = NULL

	IF (@start_date is null or @start_date = '')
		SET @start_date = NULL;

	IF (@end_date is null or @end_date = '')
		SET @end_date = NULL;

	IF(@customer_name is null or @customer_name ='')
		SET @customer_name = NULL

	IF(@email is null or @email ='')
		SET @email = NULL


	IF(@gender is null or @gender ='')
		SET @gender = NULL
	
	IF (@qr_ip_address is null or @qr_ip_address = '')
	 BEGIN
		SET @qr_ip_address = NULL;
	 END
	 ELSE
	 BEGIN
		SET @qr_ip_address = LTRIM(RTRIM(@qr_ip_address))
	 END
	
	 IF (@location is null or @location = '')
	 BEGIN
		SET @location = NULL;
	 END
	 ELSE
	 BEGIN
		 SET @location = LTRIM(RTRIM(@location))
	 END

	IF(@customer_id = 0)
		SET @customer_id = NULL


	IF(@status is null or @status='')
		SET @status = NULL

	IF (@qr_code is null or @qr_code = '')
	BEGIN
	 SET @qr_code = NULL;
	END
	ELSE
	BEGIN
	 SET @qr_code = LTRIM(RTRIM(@qr_code))
	END

	SELECT *
	FROM 
	(
	SELECT ROW_NUMBER() OVER (Order by e.created_at ASC)AS [no], c.WID, c.first_name +' '+c.last_name as customer_name,
	c.gender, (select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
	e.qr_code, e.points, e.created_at, c.[status]
	
	FROM customer_earned_points as e
	JOIN customer as c
	on e.customer_id = c.customer_id
	where e.qr_code like 'CTH_iView_%'
	AND e.points = 25
	AND (@wid is null or c.wid like '%'+@wid+'%')
	AND (@customer_id is null or c.customer_id = @customer_id)
	AND (@email is null or c.email like '%'+@email+'%')
	AND (@gender is null or c.gender like @gender+'%')
	AND (@qr_code is null or e.qr_code  like '%'+@qr_code+'%')
	AND (@location IS NULL OR e.GPS_location like '%' + @location + '%')
	AND (@qr_ip_address IS NULL OR e.ip_address like '%' + @qr_ip_address + '%')
    AND (@status IS NULL OR c.[status] like '%' + @status + '%')
	AND (@start_date IS NULL OR CAST(e.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
	) as w
	WHERE (@customer_name is null or (w.customer_name) like '%'+@customer_name+'%') 

	order by w.no desc


END
