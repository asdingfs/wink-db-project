

CREATE PROCEDURE [dbo].[Get_Citi_Api_Report]
(
	 @start_date datetime,
	 @end_date datetime,
	
	
	 @name varchar(100),
	 @email varchar(100),
	 @phone varchar(250),
	 @status varchar(250),
	

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
--print(@topsize)
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



 --print(@asset_type);
 IF (@name is null or @name = '')
 BEGIN
 SET @name = NULL;
 --print('@name is NULL');
 END
 ELSE
 BEGIN
 SET @name = LTRIM(RTRIM(@name))
 --print('@ip_traped is '+ @name);
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
 
 IF (@phone is null or @phone = '')
 BEGIN
 SET @phone = NULL;
 --print('@email is string');
 END
 ELSE
 BEGIN
 SET @phone = LTRIM(RTRIM(@phone))
 END

 IF (@status is null or @status = '')
 BEGIN
 SET @status = NULL;

 END
 ELSE
 BEGIN
 SET @status = LTRIM(RTRIM(@status))
 END


 
 	SELECT * FROM create_citi_api_report
						 
			  where  (@start_date IS NULL OR CAST(created_on as Date) BETWEEN @start_date AND @end_date) 
			  
			  and  (@name IS NULL OR name like @name + '%') 

			  and (@email IS NULL OR email like @email + '%')

			  and (@phone IS NULL OR phone like @phone + '%')

			  and (@status IS NULL OR application_id like @status + '%')

			  and id between @intStartRow and @intEndRow
			  
			 order by id desc
	

	
		 
END