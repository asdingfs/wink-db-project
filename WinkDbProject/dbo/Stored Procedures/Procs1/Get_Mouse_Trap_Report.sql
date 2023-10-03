
CREATE PROCEDURE [dbo].[Get_Mouse_Trap_Report]
(
	 @start_date datetime,
	 @end_date datetime,
	
	
	 @mousetrap_id varchar(100),
	 @ip_traped varchar(100),
	 @from_where varchar(500),
	 @status varchar(100),
	

	 @intPage int,
     @intPageSize int
 )
AS
BEGIN

	DECLARE @intStartRow int;
	DECLARE @intEndRow int;
	DECLARE @topsize int;


	Declare @current_datetime datetime

	Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

	SET @topsize =  @intPage * @intPageSize;
	
	SET @intStartRow = (@intPage -1) * @intPageSize + 1;
	print('@intStartRow is ');
	 print(@intStartRow);
	SET @intEndRow = @intPage * @intPageSize;
	print('@intEndRow is ');
	print(@intEndRow);

	IF (@start_date is null or @start_date = '')
	BEGIN
		SET @start_date = NULL;
	END

	 IF (@end_date is null or @end_date = '')
	 BEGIN
		SET @end_date = NULL;
	 END

	IF (@mousetrap_id is null or @mousetrap_id = '')
	BEGIN
		SET @mousetrap_id = NULL;
	END
	ELSE
	BEGIN
		SET @mousetrap_id = LTRIM(RTRIM(@mousetrap_id));
	END

	IF (@ip_traped is null or @ip_traped = '')
	BEGIN
		SET @ip_traped = NULL;
		print('@ip_traped is NULL');
	END
	ELSE
	BEGIN
		SET @ip_traped = LTRIM(RTRIM(@ip_traped))
		print('@ip_traped is ');
	END

	IF (@from_where is null or @from_where = '')
	BEGIN
		SET @from_where = NULL;
	END
	ELSE
	BEGIN
		SET @from_where = LTRIM(RTRIM(@from_where));
	END
 
	IF (@status is null or @status = '')
	BEGIN
		SET @status = NULL;
	END
	ELSE
	BEGIN
		SET @status = LTRIM(RTRIM(@status));
	END

	SELECT * FROM (
		SELECT mousetrap_id, time_traped,ip_traped,isp_name, from_where,status, 
		ROW_NUMBER() OVER(order by mousetrap_id desc) As total_count
		FROM mousetrap
		where  (@start_date IS NULL OR CAST(time_traped as Date) BETWEEN @start_date AND @end_date) 
		and  (@ip_traped IS NULL OR ip_traped like '%' + @ip_traped + '%') 
		and (@mousetrap_id IS NULL OR mousetrap_id like @mousetrap_id + '%')
		and (@from_where IS NULL OR from_where like '%' + @from_where + '%')
		and (@status IS NULL OR status like '%' + @status + '%')
		Group by mousetrap_id, time_traped, ip_traped,from_where,[status],isp_name
	) AS M 
	order by M.mousetrap_id desc
END