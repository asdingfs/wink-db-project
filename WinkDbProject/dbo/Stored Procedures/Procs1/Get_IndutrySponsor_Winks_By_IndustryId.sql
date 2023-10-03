CREATE PROCEDURE [dbo].[Get_IndutrySponsor_Winks_By_IndustryId] 
(
@industry_id int

)
AS
BEGIN
DECLARE @CURRENT_DATE DATETIME
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUT
	SELECT industry.industry_id,industry.industry_name,
	--(SUM(campaign.total_winks) - (SUM(ISNULL(customer_earned_winks.total_winks,0))))As balance_total_winks
	
	 SUM(campaign.total_winks) As all_time_total_winks,
     ( Select SUM(ISNULL(customer_earned_winks.total_winks,0))
       From customer_earned_winks 
       Where customer_earned_winks.merchant_id In (Select merchant_industry.merchant_id
       from merchant_industry where merchant_industry.industry_id = industry.industry_id)
       
     )
     
     As redeemed_winks
		
	From merchant_industry
	JOIN industry
	ON merchant_industry.industry_id = industry.industry_id
	JOIN merchant
	ON merchant_industry.merchant_id  = merchant.merchant_id
	JOIN campaign
	ON
	campaign.merchant_id = merchant_industry.merchant_id
	
	WHERE
	((CONVERT(CHAR(10),@CURRENT_DATE,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111)
	AND
	CONVERT(CHAR(10),@CURRENT_DATE,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111))
    OR (Lower(campaign.wink_purchase_status)='activate')
	)
	AND industry.industry_id=@industry_id
	GROUP By industry.industry_id,industry.industry_name
	
END
