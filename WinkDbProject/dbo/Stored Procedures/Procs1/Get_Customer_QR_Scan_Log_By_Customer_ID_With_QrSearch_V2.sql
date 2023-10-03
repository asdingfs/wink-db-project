
CREATE PROCEDURE [dbo].[Get_Customer_QR_Scan_Log_By_Customer_ID_With_QrSearch_V2]
	(@customer_id int,

	 @qr_code varchar(50),

	 @qr_loc varchar(50),

	 @from_date varchar(50),

	  @to_date varchar(50)
	
	
	)
AS
BEGIN
Declare @qr_loc_value varchar(50)
Declare @qr_code_value varchar(50)

set @qr_code_value = @qr_code
IF(@qr_code_value is null or @qr_code_value ='')
BEGIN
SET @qr_code_value = NULL
END

set @qr_loc_value = @qr_loc
IF(@qr_loc_value is null or @qr_loc_value ='')
BEGIN
SET @qr_loc_value = NULL
END


IF (@from_date is null or @from_date ='' or @to_date is null or @to_date ='')

BEGIN


Select customer_earned_points.qr_code,customer_earned_points.points,
customer_earned_points.GPS_location as scanned_location,
customer_earned_points.last_scanned_time,customer.first_name as c_first_name,
customer.last_name as c_last_name,
customer_earned_points.campaign_id,campaign.campaign_name,campaign.merchant_id,
merchant.first_name as m_first_name , merchant.last_name as m_last_name
from customer_earned_points , merchant,campaign,customer
Where customer_earned_points.customer_id= @customer_id
AND customer_earned_points.campaign_id = campaign.campaign_id
AND campaign.merchant_id = merchant.merchant_id
AND customer_earned_points.customer_id = customer.customer_id
AND (@qr_code_value is null or customer_earned_points.qr_code like '%'+@qr_code_value+'%')
AND (@qr_loc_value is null or customer_earned_points.GPS_location like '%'+@qr_loc_value+'%')

--AND customer_earned_points.campaign_id = campaign.campaign_id
--AND customer_earned_points.customer_id= @customer_id
order by customer_earned_points.last_scanned_time desc

END
ELSE 

BEGIN
Select customer_earned_points.qr_code,customer_earned_points.points,
customer_earned_points.GPS_location as scanned_location,
customer_earned_points.last_scanned_time,customer.first_name as c_first_name,
customer.last_name as c_last_name,
customer_earned_points.campaign_id,campaign.campaign_name,campaign.merchant_id,
merchant.first_name as m_first_name , merchant.last_name as m_last_name
from customer_earned_points , merchant,campaign,customer
Where customer_earned_points.customer_id= @customer_id
AND customer_earned_points.campaign_id = campaign.campaign_id
AND campaign.merchant_id = merchant.merchant_id
AND customer_earned_points.customer_id = customer.customer_id
AND (@qr_code_value is null or customer_earned_points.qr_code like '%'+@qr_code_value+'%')
AND (@qr_loc_value is null or customer_earned_points.GPS_location like '%'+@qr_loc_value+'%')
--AND customer_earned_points.campaign_id = campaign.campaign_id
--AND customer_earned_points.customer_id= @customer_id
AND CAST (customer_earned_points.created_at as date) >= CAST (@from_date as date)
AND CAST (customer_earned_points.created_at as date) <= CAST (@to_date as date)
order by customer_earned_points.last_scanned_time desc

END

END

