CREATE PROC [dbo].[WINKTAG_GET_EURO_POINTS]
(
	@customer_name varchar(200),
	@email varchar(200),
	@gender varchar(200),
	@customer_id int,
	@start_date varchar(50),
	@end_date varchar(50),
	@winktag_report varchar(50),
	@winktag_point_status varchar(50)
)
AS

BEGIN

	DECLARE @CAMPAIGN_ID int;

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

	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
		RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)


	SELECT * FROM 
		(--1 START
			SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC) AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,T.customer_id,T.points,T.GPS_location,T.ip_address,T.created_at 
			FROM WINKTAG_CUSTOMER_EARNED_POINTS AS T
			INNER JOIN CUSTOMER 
			ON T.customer_id = CUSTOMER.customer_id 
			WHERE T.campaign_id = @CAMPAIGN_ID
			AND T.POINTS = 15

		) AS TEMP----1 END
	WHERE (@email is null or TEMP.email like '%'+@email+'%')
	and (@gender is null or TEMP.gender = @gender)
	and (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
	and (@customer_id is null or TEMP.customer_id = @customer_id)
	and (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
	order by temp.no desc
END



