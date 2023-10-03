CREATE PROC [dbo].[Social_Media_Acq_Report]
(
	@wid varchar(50),
	@customerId int,
	@customerName varchar(200),
	@email varchar(200),
	@gender varchar(200),
	@start_date varchar(50),
	@end_date varchar(50),
	@status varchar(50)
)
AS

BEGIN
	IF(@wid is null or @wid ='')
		SET @wid = NULL;

	IF(@customerId = 0)
		SET @customerId = NULL;

	IF(@customerName is null or @customerName ='')
		SET @customerName = NULL;

	IF(@email is null or @email ='')
		SET @email = NULL;

	IF(@gender is null or @gender ='')
		SET @gender = NULL;

	IF(@start_date is null or @start_date='')
		SET @start_date = NULL;

	IF(@end_date is null or @end_date='')
		SET @end_date = NULL;

	IF(@status is null or @status='')
		SET @status = NULL
	
	SELECT ROW_NUMBER() OVER (Order by w.created_at ASC)AS [no], cus.WID, cus.gender,
	(select floor(datediff(day,cus.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
	w.points, w.created_at,
	cus.[status]
	FROM winners_points AS w
	LEFT JOIN customer AS cus 
	ON w.customer_id = cus.customer_id
	WHERE w.entry_id = 20
	AND (@wid is null or cus.WID like '%'+@wid+'%')
	AND (@customerId is null or w.customer_id = @customerId)
	AND (@customerName is null or (cus.first_name +' '+cus.last_name) like '%'+@customerName+'%') 
	AND (@email is null or cus.email like '%'+@email+'%')
	and (@gender is null or cus.gender = @gender)
	AND (@status is null or cus.[status] = @status)
	AND (@start_date IS NULL OR CAST(w.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
	order by [no] desc
	
END



