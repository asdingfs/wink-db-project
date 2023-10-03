
CREATE PROCEDURE [dbo].[WinkGatesCNY2021Report]
(
	@wid varchar(50),
	@customer_id int,
	@name varchar(100),
	@email varchar(100),
	@gender varchar(10),
	@ip_address varchar(50),
	@location varchar(255),
	@status varchar(50),
	@start_date datetime,
	@end_date datetime,
	@intPage int,
    @intPageSize int
)
AS
BEGIN

	DECLARE @intStartRow int;
	DECLARE @intEndRow int;

	Declare @current_datetime datetime

	Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

	
	SET @intStartRow = (@intPage -1) * @intPageSize + 1;
	SET @intEndRow = @intPage * @intPageSize;

	IF(@customer_id = 0)
	BEGIN
		SET @customer_id = NULL;
	END

	IF(@wid is null or @wid ='')
	BEGIN
		SET @wid = NULL;
	END
	IF (@start_date is null or @start_date = '')
	BEGIN
		SET @start_date = NULL;
	END

	IF (@end_date is null or @end_date = '')
	BEGIN
		SET @end_date = NULL;
	END

	IF (@email is null or @email = '')
	BEGIN
		SET @email = NULL;
	END
	ELSE
	BEGIN
		SET @email = LTRIM(RTRIM(@email));
	END
 
	IF (@name is null or @name = '')
	BEGIN
		SET @name = NULL;
	END
	ELSE
	BEGIN
		SET @name = LTRIM(RTRIM(@name));
	END


	 IF (@ip_address is null or @ip_address = '')
	 BEGIN
		SET @ip_address = NULL;
	 END
	 ELSE
	 BEGIN
		SET @ip_address = LTRIM(RTRIM(@ip_address));
	 END


	 IF (@gender is null or @gender = '')
	 BEGIN
		SET @gender = NULL;
	 END

	 IF (@location is null or @location = '')
	 BEGIN
		SET @location = NULL;
	 END
	 ELSE
	 BEGIN
		SET @location = LTRIM(RTRIM(@location));
	 END


	 IF (@status is null or @status = '')
	 BEGIN
		SET @status = NULL;
	 END 

	
	
		SELECT * FROM 
		(
			SELECT 
			e.customer_id ,
			MAX(c.WID) as wid, 
			MAX(c.gender) as gender,
			MAX(c.email) as  customer_email,
			MAX(c.first_name + ' ' + c.last_name) as customer_name,
			MAX((CONVERT(int,CONVERT(char(8),@current_datetime,112))-CONVERT(char(8),Cast(c.date_of_birth as date),112))/10000) AS age,
			MAX(c.[status]) as customer_status,
			sum(e.points)  as points,
			COUNT(*) OVER() as total_count,
			COUNT(*) as total_hits,
			MAX(e.created_at) as createdAt,
			ROW_NUMBER() OVER(
				ORDER BY COUNT(*) DESC, MAX(e.created_at) DESC)
			as id,
			MAX(e.GPS_location) as GPS_location, MAX(e.ip_address) as ip_address
			
			FROM wink_gate_points_earned as e
			JOIN customer as c
			ON e.customer_id = c.customer_id
			JOIN wink_gate_booking as b
			ON e.bookingId = b.id
			WHERE b.wink_gate_campaign_id = 35
			--AND b.[status] = 1
			AND (@wid is null or c.wid like '%'+@wid+'%')
			AND (@customer_id is null or c.customer_id = @customer_id)
			AND (@name IS NULL OR c.first_name + ' ' + c.last_name like '%'+ Lower(@name) +'%')
			AND (@email IS NULL OR c.email like '%'+ @email + '%')
			AND (@gender IS NULL OR c.gender = @gender )
			AND (@location IS NULL OR e.GPS_location like '%' + @location + '%')
			AND (@ip_address IS NULL OR e.ip_address like '%' + @ip_address + '%')
			AND (@status IS NULL OR c.[status] like '%' + @status + '%')
			AND (@start_date IS NULL OR CAST(e.created_at as Date) BETWEEN @start_date AND @end_date) 
			group by e.customer_id
		) as w
		WHERE w.id between @intStartRow and @intEndRow
		ORDER BY w.total_hits DESC
		--ORDER BY w.createdAt DESC
	
	
END

