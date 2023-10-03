CREATE PROC [dbo].[Points_Issuance_Report]
(
	@campaign_id int,
	@customer_name varchar(200),
	@email varchar(200),
	@gender varchar(200),
	@customer_id int,
	@start_date varchar(50),
	@end_date varchar(50),
	@wid varchar(50)
)
AS

BEGIN
	IF(@campaign_id = 0)
		SET @campaign_id = NULL

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

	IF(@customer_id = 0)
		SET @customer_id = NULL

	IF(@wid is null or @wid ='')
		SET @wid = NULL

	SELECT *
	FROM (

		SELECT ROW_NUMBER() OVER (Order by p.created_at ASC)AS [no], 
		p.campaign_id, p.wid, p.points, p.issuer, p.remark_issuer, p.created_at, p.approver, p.remark_approver, p.approved_at,
		c.first_name +' '+c.last_name as customer_name,c.email,c.gender,(select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,c.customer_id
		FROM points_issuance as p
		LEFT JOIN customer as c
		ON p.wid like c.WID
		WHERE campaign_id = @campaign_id
		AND (@customer_id is null or @customer_id =c.customer_id)
		AND (@wid is null or p.wid like '%'+@wid+'%')
		AND (@start_date IS NULL OR CAST(p.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
		AND (@email is null or (email like '%'+@email+'%'))
		AND (@customer_name is null or (c.first_name +' '+c.last_name) like '%'+@customer_name+'%')
		AND (@gender is null or gender = @gender)
	)AS TEMP
	
	order by temp.[no] desc
END



