-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Update_WinkPurchaseOnlyCampaign_ByCampaignId]
	(
	 @campaign_id int,
	 @merchant_id int,
	 @campaign_name varchar(255),
     @campaign_code varchar(255),
	 @campaign_amount Decimal(10,2),
	 @cents_per_wink Decimal(10,2),
	 @percent_for_wink Decimal(10,2),
     @sales_code varchar(255),
	 @sales_commission Decimal(10,2),
	 @total_winks int,
	 @total_winks_amount Decimal(10,2),
	 @agency bit,
	 @agency_name varchar(255),
	 @wink_purchase_only int ,
     @wink_purchase_status varchar(50),
	-- @campaign_start_date DateTime,
	-- @campaign_end_date DateTime,
	 @updated_at DateTime
	 
	
	)
AS
BEGIN
	Declare @existing_start_date DateTime
	IF EXISTS (SELECT campaign_start_date FROM campaign WHERE campaign.campaign_id = @campaign_id)
		BEGIN  
			 BEGIN 
				UPDATE campaign SET 
				campaign_name = @campaign_name,
				campaign_code = @campaign_code,
				campaign_amount= @campaign_amount,       
				cents_per_wink =@cents_per_wink ,             
				percent_for_wink =@percent_for_wink,
				sales_code = @sales_code,
				sales_commission = @sales_commission,
				total_winks =  @total_winks,
				total_winks_amount = @total_winks_amount,
				agency = @agency,
				agency_name =  @agency_name,
				wink_purchase_only = @wink_purchase_only,
				wink_purchase_status = @wink_purchase_status,
				--campaign_start_date = @campaign_start_date,
				--campaign_end_date =@campaign_end_date,
				updated_at = @updated_at 
				WHERE campaign_id =@campaign_id
				IF(@@ROWCOUNT>0)
				BEGIN
					SELECT '1' as response_code, 'Success' as response_message 
					RETURN
				END
	        
	        END 
				
	        
	       
	        
		END
	ELSE 
		BEGIN 
			SELECT '0' as response_code, 'No Campaign Id' as response_message 
			RETURN
		END
	
	
END
