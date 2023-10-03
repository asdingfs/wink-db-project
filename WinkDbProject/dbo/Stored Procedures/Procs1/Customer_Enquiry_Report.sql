CREATE PROC [dbo].[Customer_Enquiry_Report]
(
	@customer_name varchar(200),
	@email varchar(200),
	@phone_no varchar(10),
	@ip varchar(20),
	@gender varchar(200),
	@customer_id int,
	@start_date varchar(50),
	@end_date varchar(50),
	@wid varchar(50),
	@status varchar(50)
)
AS

BEGIN


	IF(@customer_name is null or @customer_name ='')
		SET @customer_name = NULL

	IF(@email is null or @email ='')
		SET @email = NULL

	IF(@gender is null or @gender ='')
		SET @gender = NULL

	IF(@phone_no is null or @phone_no ='')
		SET @phone_no = NULL

	IF(@ip is null or @ip ='')
		SET @ip = NULL

	IF(@customer_id = 0)
		SET @customer_id = NULL

	IF (@start_date is null or @start_date = '')
		SET @start_date = NULL;

	IF (@end_date is null or @end_date = '')
		SET @end_date = NULL;

	IF(@wid is null or @wid ='')
		SET @wid = NULL

	IF(@status is null or @status='')
		SET @status = NULL
	

		SELECT * FROM 
		(
			SELECT ROW_NUMBER() OVER (Order by T.created_at ASC)AS no,c.first_name +' '+c.last_name as customer_name,c.gender as gender, (select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age, c.WID as wid, c.customer_id,
			c.[status], T.phone_no, T.email, T.ip_address, T.GPS_location, T.app_version, T.created_at
			
			FROM

					(
						-------table1
						SELECT phone_no,email,ip_address, GPS_location, app_version, created_at
						FROM customer_enquiry where 
						(@phone_no IS NULL OR phone_no like '%'+@phone_no+'%')
						AND (@email IS NULL OR email like '%'+@email+'%')
						AND (@ip is null or ip_address  like '%'+@ip+'%')
						AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
						-------table1


					) AS T 
					LEFT JOIN customer as c ON T.email = c.email 
			)as temp
			
			WHERE (@gender is null or TEMP.gender = @gender)
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@customer_id is null or TEMP.customer_id = @customer_id)
				AND (@status is null or TEMP.status = @status)
			 
			order by temp.no desc

END



