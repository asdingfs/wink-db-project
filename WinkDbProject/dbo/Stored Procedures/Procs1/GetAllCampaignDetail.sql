CREATE PROCEDURE [dbo].[GetAllCampaignDetail]
	(@status varchar(50),
	 @todayDate DateTime,
	 @campaign_name varchar(50),
	 @advertiser_name varchar(50)
	)
AS
BEGIN
EXEC GET_CURRENT_SINGAPORT_DATETIME @todayDate output
IF (@status IS NULL OR @status='' OR @status=' ')
	BEGIN 
	print ('NULL')
	SELECT campaign.campaign_id,campaign.merchant_id,campaign.campaign_name,
	                         campaign.campaign_code,
                             campaign.campaign_amount,campaign.sales_code,
                             campaign.sales_commission,campaign.total_winks,
                             campaign.total_winks_amount,
                             campaign.agency,campaign.created_at,
                             campaign.updated_at,
                            campaign.percent_for_wink,
                            campaign.cents_per_wink,
                            campaign.campaign_start_date,
                            campaign.campaign_end_date,
                            campaign.wink_purchase_only,
                            campaign.wink_purchase_status,
                            campaign.campaign_status,
                            campaign.total_wink_confiscated,
                             merchant.first_name,merchant.last_name,
                             
                            (SELECT COUNT(customer_earned_points.campaign_id) FROM customer_earned_points 
                             WHERE 
                            customer_earned_points.campaign_id = campaign.campaign_id) AS TotalScan
                            
                            FROM campaign ,merchant
                            WHERE campaign.merchant_id = merchant.merchant_id
							AND Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%')
							AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%')
							 
                            Order by campaign.campaign_id DESC
    END
    ELSE IF (@status ='active')
		BEGIN
		     SELECT campaign.campaign_id,campaign.merchant_id,campaign.campaign_name,campaign.campaign_code,
                             campaign.campaign_amount,campaign.sales_code,campaign.sales_commission,campaign.total_winks,
                             campaign.total_winks_amount,campaign.agency,campaign.created_at,
                             campaign.updated_at,
                            campaign.percent_for_wink,
                            campaign.cents_per_wink,
                            campaign.campaign_start_date,
                            campaign.campaign_end_date,
                            campaign.wink_purchase_only,
                            campaign.wink_purchase_status,
                            campaign.campaign_status,
                             campaign.total_wink_confiscated,
                             merchant.first_name,merchant.last_name,
                            (SELECT COUNT(customer_earned_points.campaign_id) FROM customer_earned_points 
                             WHERE 
                            customer_earned_points.campaign_id = campaign.campaign_id) AS TotalScan
                            
                            FROM campaign ,merchant
                            WHERE campaign.merchant_id = merchant.merchant_id
                            AND CONVERT(CHAR(10),@todayDate,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
                            AND CONVERT(CHAR(10),@todayDate,111) <= CONVERT(CHAR(10),campaign_end_date,111) 
                            AND campaign.wink_purchase_only =0
                            AND campaign.campaign_status ='enable'

							AND Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%')
							AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%')

                            Order by campaign.campaign_id DESC
		END
	ELSE IF (@status ='inactive')
		BEGIN
			SELECT campaign.campaign_id,campaign.merchant_id,campaign.campaign_name,campaign.campaign_code,
                             campaign.campaign_amount,campaign.sales_code,campaign.sales_commission,campaign.total_winks,
                             campaign.total_winks_amount,campaign.agency,campaign.created_at,campaign.updated_at,
                            campaign.percent_for_wink,campaign.cents_per_wink,campaign.campaign_start_date,
                            campaign.campaign_end_date,
                            campaign.wink_purchase_only,
                            campaign.wink_purchase_status,
                            campaign.campaign_status,
                             campaign.total_wink_confiscated,
                             merchant.first_name,merchant.last_name,
                             (SELECT COUNT(customer_earned_points.campaign_id) FROM customer_earned_points 
                             WHERE 
                            customer_earned_points.campaign_id = campaign.campaign_id) AS TotalScan
                            
                             FROM campaign ,merchant
                            WHERE campaign.merchant_id = merchant.merchant_id
                            AND CONVERT(CHAR(10),@todayDate,111) < CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
                            AND campaign.wink_purchase_only=0
                            AND campaign.campaign_status ='enable'

							AND Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%')
							AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%')

                            Order by campaign.campaign_id DESC
		END
	ELSE IF (@status ='expired')
		BEGIN
			SELECT campaign.campaign_id,campaign.merchant_id,campaign.campaign_name,campaign.campaign_code,
                             campaign.campaign_amount,campaign.sales_code,campaign.sales_commission,campaign.total_winks,
                             campaign.total_winks_amount,campaign.agency,campaign.created_at,campaign.updated_at,
                            campaign.percent_for_wink,campaign.cents_per_wink,campaign.campaign_start_date,
                            campaign.campaign_end_date,
                            campaign.wink_purchase_only,
                            campaign.wink_purchase_status,
                            campaign.campaign_status,
                             campaign.total_wink_confiscated,
                             merchant.first_name,merchant.last_name,
                             (SELECT COUNT(customer_earned_points.campaign_id) FROM customer_earned_points 
                             WHERE 
                            customer_earned_points.campaign_id = campaign.campaign_id) AS TotalScan
                            
                             FROM campaign ,merchant
                            WHERE campaign.merchant_id = merchant.merchant_id
                            AND CONVERT(CHAR(10),@todayDate,111) > CONVERT(CHAR(10),campaign_end_date,111) 
                            AND campaign.wink_purchase_only=0
                            AND campaign.campaign_status ='enable'
							AND Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%')
							AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%')

                            Order by campaign.campaign_id DESC
		END
	ELSE  IF (@status='onhold')
		BEGIN
			SELECT campaign.campaign_id,campaign.merchant_id,campaign.campaign_name,campaign.campaign_code,
                             campaign.campaign_amount,campaign.sales_code,campaign.sales_commission,campaign.total_winks,
                             campaign.total_winks_amount,campaign.agency,campaign.created_at,campaign.updated_at,
                            campaign.percent_for_wink,campaign.cents_per_wink,campaign.campaign_start_date,
                            campaign.campaign_end_date,
                            campaign.wink_purchase_only,
                            campaign.wink_purchase_status,
                            campaign.campaign_status,
                             campaign.total_wink_confiscated,
                             merchant.first_name,merchant.last_name,
                             (SELECT COUNT(customer_earned_points.campaign_id) FROM customer_earned_points 
                             WHERE 
                            customer_earned_points.campaign_id = campaign.campaign_id) AS TotalScan
                            
                             FROM campaign ,merchant
                            WHERE campaign.merchant_id = merchant.merchant_id
                            AND campaign.wink_purchase_only =1
                            AND campaign.campaign_status ='enable'
                            AND Lower(campaign.wink_purchase_status)='on hold'
							AND Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%')
							AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%')

							Order by campaign.campaign_id DESC
		END
	ELSE IF (@status='activate')
		BEGIN
			SELECT campaign.campaign_id,campaign.merchant_id,campaign.campaign_name,campaign.campaign_code,
                             campaign.campaign_amount,campaign.sales_code,campaign.sales_commission,campaign.total_winks,
                             campaign.total_winks_amount,campaign.agency,campaign.created_at,campaign.updated_at,
                            campaign.percent_for_wink,campaign.cents_per_wink,campaign.campaign_start_date,
                            campaign.campaign_end_date,
                            campaign.wink_purchase_only,
                            campaign.wink_purchase_status,
                            campaign.campaign_status,
                             campaign.total_wink_confiscated,
                             merchant.first_name,merchant.last_name,
                             (SELECT COUNT(customer_earned_points.campaign_id) FROM customer_earned_points 
                             WHERE 
                            customer_earned_points.campaign_id = campaign.campaign_id) AS TotalScan
                            
                             FROM campaign ,merchant
                            WHERE campaign.merchant_id = merchant.merchant_id
                            AND campaign.wink_purchase_only =1
                            AND campaign.campaign_status ='enable'
                            AND Lower(campaign.wink_purchase_status)='activate'
							AND Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%')
							AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%')
							Order by campaign.campaign_id DESC
		END
	ELSE IF (@status='disable')
		BEGIN
			SELECT campaign.campaign_id,campaign.merchant_id,campaign.campaign_name,campaign.campaign_code,
                             campaign.campaign_amount,campaign.sales_code,campaign.sales_commission,campaign.total_winks,
                             campaign.total_winks_amount,campaign.agency,campaign.created_at,campaign.updated_at,
                            campaign.percent_for_wink,campaign.cents_per_wink,campaign.campaign_start_date,
                            campaign.campaign_end_date,
                            campaign.wink_purchase_only,
                            campaign.wink_purchase_status,
                            campaign.campaign_status,
                             campaign.total_wink_confiscated,
                             merchant.first_name,merchant.last_name,
                             (SELECT COUNT(customer_earned_points.campaign_id) FROM customer_earned_points 
                             WHERE 
                            customer_earned_points.campaign_id = campaign.campaign_id) AS TotalScan
                            
                             FROM campaign ,merchant
                            WHERE campaign.merchant_id = merchant.merchant_id
                            AND campaign.campaign_status ='disable'
							AND Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%')
							AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%')
							Order by campaign.campaign_id DESC
		END
END
