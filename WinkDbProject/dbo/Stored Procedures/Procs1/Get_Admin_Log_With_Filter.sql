

CREATE PROCEDURE [dbo].[Get_Admin_Log_With_Filter]
	(
	
	 @user_name varchar(100),
	 @user_status varchar(100),
	 @start_date datetime,
	 @end_date datetime
 )
AS
BEGIN

DECLARE @user_name_loc varchar(100);
DECLARE @user_status_loc varchar(100);

DECLARE @start_date_loc varchar(100);
DECLARE @end_date_loc varchar(100);


IF (@start_date is null or @start_date = '')
 BEGIN
 
 SET @start_date_loc = NULL;
 
 END
 ELSE 
 BEGIN
	
	SET	@start_date_loc = LTRIM(RTRIM(@start_date));

 END

 IF (@end_date is null or @end_date = '')
 BEGIN
 
 SET @end_date_loc = NULL;
 
 END
 ELSE 
 BEGIN
	SET	@end_date_loc = LTRIM(RTRIM(@end_date));
 END



IF (@user_name is null or @user_name = '')
 BEGIN
 SET @user_name_loc = NULL;
 
 END
 ELSE 
 BEGIN
	SET	@user_name_loc = LTRIM(RTRIM(@user_name));
 END

 IF (@user_status is null or @user_status = '')
 BEGIN
	 SET @user_status_loc = NULL;
	print('here');
 END
 ELSE 
 BEGIN
	SET	@user_status_loc = LTRIM(RTRIM(@user_status));
 END
 --print('@user_status is string');
 --print(@user_status_loc);
 --print('@user_name is string');
 print(@start_date_loc);
 print(@end_date_loc);
 print(@user_status_loc);

 select * from admin_log 
 where ((@user_status_loc IS NULL OR  [status] like @user_status_loc +'%')
 AND (@user_name_loc IS NULL OR  user_name like @user_name_loc +'%'))
 --AND (@end_date_loc IS NULL OR (CAST (admin_log.login_time as DATE) BETWEEN CAST (@start_date_loc as DATE) AND CAST (@end_date_loc as DATE) ))
 AND (@start_date_loc IS NULL OR @start_date_loc <=  CAST (admin_log.login_time as DATE))
 AND (@end_date_loc IS NULL OR logout_time IS NULL OR @end_date_loc >=  CAST (admin_log.logout_time as DATE))
 order by admin_log.id desc
 


END
