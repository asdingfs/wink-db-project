-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Garden_By_The_Bay_Report]
(
	@customer_name varchar(200),
	@email varchar(200),
	@gender varchar(15),
	@customer_id int,
	@qr_code varchar(50),
	@start_date varchar(50),
	@end_date varchar(50),
	@winktag_report varchar(50),
	@winner varchar(5),
	@staff_code varchar(10),
	@redemption_status varchar(5)
)	
AS
BEGIN

	DECLARE @CAMPAIGN_ID int
	DECLARE @POINTS int

	SET @qr_code = RTRIM(LTRIM(@qr_code));
	
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

	IF (@qr_code is null or @qr_code = '')
	BEGIN
	 SET @qr_code = NULL;
	END
	ELSE
	BEGIN
	 SET @qr_code = LTRIM(RTRIM(@qr_code))
	END


	IF(@winner is null or @winner ='')
		SET @winner = NULL

	IF(@staff_code is null or @staff_code ='')
		SET @staff_code = NULL

	IF(@redemption_status is null or @redemption_status ='')
		SET @redemption_status = NULL

	
	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
		RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)

	IF(@CAMPAIGN_ID = 130)
		BEGIN

		SELECT * FROM 
		(
			SELECT ROW_NUMBER() OVER (Order by T.created_at ASC)AS no,c.first_name +' '+c.last_name as customer_name,c.gender as gender, (select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age, c.email,c.WID as wid, c.customer_id as customer_id,
			T.qr_code, T.points, T.winner, T.GPS_location, T.ip_address, T.created_at, T.staff_code, T.redemption_status,T.redeemed_on, T.redemption_location
			
			FROM

					(
						-------table1
						SELECT customer_id, campaign_id, qr_code,points,winning_status as winner, GPS_location, ip_address, created_at, 
						redemption_code as staff_code, redemption_status, redeemed_on, redemption_location
						FROM qr_campaign where 
						campaign_id = @CAMPAIGN_ID
						AND (@winner IS NULL OR winning_status like @winner)
					
						AND (@qr_code is null or qr_code  like '%'+@qr_code+'%')
						AND (@redemption_status IS NULL OR redemption_status like @redemption_status)
						AND (@staff_code IS NULL OR redemption_code like'%'+@staff_code+'%')
						AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
						-------table1


					) AS T 
					INNER JOIN customer as c ON T.customer_id = c.customer_id 
			)as temp
			
			WHERE  (@customer_id is null or TEMP.customer_id = @customer_id)
			AND (@email is null or TEMP.email like '%'+@email+'%')
			AND (@gender is null or TEMP.gender like @gender+'%')
			AND (@customer_name is null or (TEMP.customer_name) like '%'+@customer_name+'%') 
			AND (@customer_id is null or TEMP.customer_id = @customer_id)
			AND (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			
			order by temp.no desc
			
		END
	
END
