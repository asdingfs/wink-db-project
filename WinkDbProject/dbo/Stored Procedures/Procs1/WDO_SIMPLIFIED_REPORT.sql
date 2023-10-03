CREATE PROC [dbo].[WDO_SIMPLIFIED_REPORT]
(
	@winktag_report varchar(50),
	@order_no varchar(250),
	@customer_id int,
	@customer_name varchar(200),
	@email varchar(200),
	@mer_name varchar(200),
	@completion int,
	@validity varchar(10),
	@exception varchar(10),
	@status varchar(50),
	@start_date varchar(50),
	@end_date varchar(50)
)
AS

BEGIN

	DECLARE @CAMPAIGN_ID int
	
	
	IF(@order_no is null or @order_no ='')
		SET @order_no = NULL;

	IF(@customer_id = 0)
		SET @customer_id = NULL;

	IF(@customer_name is null or @customer_name ='')
		SET @customer_name = NULL;

	IF(@email is null or @email ='')
		SET @email = NULL;

	IF(@mer_name is null or @mer_name ='')
		SET @mer_name = NULL;

	IF(@completion = 2)
		SET @completion = NULL;

	IF(@validity is null or @validity='')
		SET @validity = NULL;

	IF(@exception is null or @exception='')
		SET @exception = NULL;

	IF(@status is null or @status='')
		SET @status = NULL;

	IF (@start_date is null or @start_date = '')
		SET @start_date = NULL;

	IF (@end_date is null or @end_date = '')
		SET @end_date = NULL;

	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
		RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)

	IF(@CAMPAIGN_ID = 145)
		BEGIN
		SELECT * from(
		SELECT ROW_NUMBER() OVER (Order by wto.cus_date ASC)AS no, wto.order_number, wto.cus_date, wto.mer_date,
		wto.completion, wto.validity, wto.points, wto.exception, 
		cus.first_name +' '+cus.last_name as customer_name, cus.status,
		mer.first_name+' '+mer.last_name as mer_name, 
		(SELECT staff_code from winktag_redemption_staffs where campaign_id = @CAMPAIGN_ID) as access_code
		from wink_delights_online as wto

		left join customer as cus on wto.cus_id = cus.customer_id
		left join customer as mer on wto.mer_id = mer.customer_id

		WHERE (@order_no is null or wto.order_number like '%'+@order_no+'%')
		AND (@customer_id is null or wto.cus_id = @customer_id)
	
		AND (@email is null or cus.email like '%'+@email+'%')
		
		AND (@completion is null or wto.completion = @completion)
		AND (
				@validity is null or (wto.validity like @validity)
			)
		AND (
				@exception is null or (wto.exception like @exception)
			)
		AND (
				@status is null or (cus.status = @status)
			)			
		AND (@start_date IS NULL OR CAST(wto.cus_date as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))

		) as T
		WHERE (@customer_name is null or T.customer_name like '%'+@customer_name+'%') 
		AND (@mer_name is null or T.mer_name like '%'+@mer_name+'%') 
		order by T.cus_date desc
		END
	
END



