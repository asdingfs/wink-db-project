
CREATE PROCEDURE [dbo].[Get_Customer_QR_Scan_Log_By_Customer_ID_With_QrSearch_V3]
	(@customer_id int,
	 @qr_code varchar(50),

	 @qr_loc varchar(50),

	 @from_date varchar(50),

	  @to_date varchar(50),
	  @ip varchar(20)
	
	
	)
AS
BEGIN
	IF(@qr_code is null or @qr_code ='')
	BEGIN
		SET @qr_code = NULL;
	END

	IF(@qr_loc is null or @qr_loc ='')
	BEGIN
		SET @qr_loc = NULL;
	END

	IF(@ip is null or @ip ='')
	BEGIN
		SET @ip = NULL;
	END
	IF (@from_date is null or @from_date ='')
	BEGIN
		SET @from_date = NULL;
	END 

	IF(@to_date is null or @to_date = '')
	BEGIN
		SET @to_date = NULL;
	END

	Select customer_earned_points.qr_code,customer_earned_points.points,customer_earned_points.ip_address,
	customer_earned_points.GPS_location as scanned_location,
	customer_earned_points.last_scanned_time,customer.first_name as c_first_name,
	customer.last_name as c_last_name, customer.WID as wid,
	customer_earned_points.campaign_id,campaign.campaign_name,campaign.merchant_id,
	merchant.first_name as m_first_name , merchant.last_name as m_last_name
	from customer_earned_points , merchant,campaign,customer
	Where customer_earned_points.customer_id= @customer_id
	AND customer_earned_points.campaign_id = campaign.campaign_id
	AND campaign.merchant_id = merchant.merchant_id
	AND customer_earned_points.customer_id = customer.customer_id
	AND (@qr_code is null or customer_earned_points.qr_code like '%'+@qr_code+'%')
	AND (@qr_loc is null or customer_earned_points.GPS_location like '%'+@qr_loc+'%')
	AND (@ip is null or customer_earned_points.ip_address like '%'+ @ip+'%')
	AND (@from_date is null or CAST (customer_earned_points.created_at as date) >= CAST (@from_date as date))
	AND (@to_date is null or CAST (customer_earned_points.created_at as date) <= CAST (@to_date as date))
	order by customer_earned_points.last_scanned_time desc
END

