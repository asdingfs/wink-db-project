CREATE  PROCEDURE [dbo].[Get_Merchant_Report_bakorg_05022016]
	(@start_date varchar(50),
	 @end_date varchar(50),
	 @advertiser_name  varchar(50),
	 @mascode  varchar(50))
AS
BEGIN
-- Check null or empty
	
IF OBJECT_ID('tempdb..#tmpmerchant') IS NOT NULL 
Drop table #tmpmerchant
CREATE TABLE #tmpmerchant 
(
	campaign_id int,
	merchant_id int,
	
	imobshop_id int ,
	first_name varchar(100),
	last_name varchar(100),
	mas_code varchar(50),
	email varchar(150),
	total_winks int,
	redeemed_winks int)
	

IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')
BEGIN

	INSERT INTO #tmpmerchant (campaign_id,merchant_id,
	imobshop_id,first_name,last_name,mas_code,email,total_winks,redeemed_winks)


	SELECT * FROM (
	SELECT campaign.campaign_id,merchant.merchant_id,merchant.imobshop_merchant_id,merchant.first_name,merchant.last_name,merchant.mas_code,
	merchant.email,campaign.total_winks,
    
	 (SELECT SUM(ISNULL(customer_earned_winks.total_winks,0)) from customer_earned_winks 
	 WHERE customer_earned_winks.campaign_id = campaign.campaign_id
	 and CAST(customer_earned_winks.created_at as DATE)>= CAST(@start_date as DATE)
	 AND CAST(customer_earned_winks.created_at as DATE)<= CAST(@end_date as DATE)
	 ) AS Redeemed_Winks
	 
	 FROM merchant,campaign
	 WHERE merchant.merchant_id = campaign.merchant_id
	 --AND CAST(campaign.created_at as Date)>= CAST(@start_date  as DATE)
	-- AND CAST(campaign.created_at as DATE) <= CAST(@end_date as DATE)
	 AND 
	 ( 
	 /*CAST(campaign.campaign_start_date as DATE) BETWEEN CAST(@start_date as DATE)
	 AND CAST(@end_date as DATE)
	 OR
	 CAST(campaign.campaign_end_date as DATE) BETWEEN CAST(@start_date as DATE)
	 AND CAST(@end_date as DATE)*/
	 
	 CAST(@start_date as DATE) Between CAST(campaign.campaign_start_date as DATE) and 
	 CAST(campaign.campaign_end_date as DATE) 
	 
	 OR 
	 CAST(@end_date as DATE) Between CAST(campaign.campaign_start_date as DATE) and 
	 CAST(campaign.campaign_end_date as DATE) 
	 ) 
	 
	 )As tbltemp

	 WHERE Lower(tbltemp.first_name + '' + tbltemp.last_name)LIKE Lower('%'+ @advertiser_name +'%') 
	 AND Lower(tbltemp.mas_code) LIKE Lower('%'+ @mascode +'%')
    
END
ELSE 
	BEGIN
		INSERT INTO #tmpmerchant (campaign_id,merchant_id,
	imobshop_id,first_name,last_name,mas_code,email,total_winks,redeemed_winks)


	SELECT * FROM (SELECT campaign.campaign_id,merchant.merchant_id,merchant.imobshop_merchant_id,merchant.first_name,merchant.last_name,merchant.mas_code,
	merchant.email,campaign.total_winks,
    
	 (SELECT SUM(ISNULL(customer_earned_winks.total_winks,0)) from customer_earned_winks 
	 WHERE customer_earned_winks.campaign_id = campaign.campaign_id
	 ) AS Redeemed_Winks
	 
	 FROM merchant,campaign
	 WHERE merchant.merchant_id = campaign.merchant_id) As tbltemp1

	  WHERE Lower(tbltemp1.first_name + '' + tbltemp1.last_name)LIKE Lower('%'+ @advertiser_name +'%') 
	  AND Lower(tbltemp1.mas_code) LIKE Lower('%'+ @mascode +'%')
	  
	
	END 
	
	SELECT #tmpmerchant.merchant_id,#tmpmerchant.imobshop_id,#tmpmerchant.first_name,#tmpmerchant.mas_code,
	#tmpmerchant.last_name,#tmpmerchant.email,SUM(ISNULL(#tmpmerchant.total_winks,0)) AS total_winks,
	SUM(ISNULL(#tmpmerchant.redeemed_winks,0)) As redeemed_winks
	FROM #tmpmerchant
	GROUP BY #tmpmerchant.merchant_id,#tmpmerchant.imobshop_id,#tmpmerchant.first_name,
	#tmpmerchant.last_name,#tmpmerchant.email,#tmpmerchant.mas_code
	
	DROP TABLE #tmpmerchant
	
END

/*(SELECT SUM(ISNULL(campaign.total_winks,0)) from campaign 
	 WHERE campaign.merchant_id = merchant.merchant_id
      AND 
      CAST(campaign.created_at as Date)>= @start_date 
	  AND CAST(campaign.created_at as DATE) <= @end_date
      ( 
     ( 
      @start_date BETWEEN 
      CAST(campaign.campaign_start_date as Date) AND 
      CAST(campaign.campaign_end_date as Date)
      )
      OR
       ( @end_date BETWEEN 
      CAST(campaign.campaign_start_date as Date) AND 
      CAST(campaign.campaign_end_date as Date)
      )
	 
	 
	 )	 
	 ) AS Total_Winks,*/
