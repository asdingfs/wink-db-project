-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateCampaignByCampaignId_v2]
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
	 @campaign_start_date varchar(50),
	 @campaign_end_date varchar(50),
	 @updated_at DateTime,
	 @admin_email varchar(50)
	 
	
	)
AS
BEGIN
	Declare @existing_start_date DateTime
	Declare @existing_campaign_booking int
	DECLARE @redeemed_total_winks int
	DECLARE @RETURN_NO VARCHAR(10)
	DECLARE @existing_campaign_start_date VARCHAR(50)
	DECLARE @redeemed_wink_id int
	DECLARE @existing_campaign_end_date VARCHAR(50)
	--DECLARE @total_booked_assets int

	--DECLARE @existing_total_winks int
	
	
	DECLARE @agency_comm decimal(10,2)
	
	SET @agency_comm =0
	SET @sales_commission =0
	IF @agency = 1
	BEGIN
	Set @agency_comm = ISNULL( (Select system_key_value.system_value from system_key_value where system_key_value.system_key = 'agency_com'),0)
	END
	IF @sales_code !='' AND @sales_code IS NOT NULL
	BEGIN
	Set @sales_commission = ISNULL( (Select system_key_value.system_value from system_key_value where system_key_value.system_key = 'sales_com'),0)
	END
	
	
	IF @campaign_end_date ='' OR @campaign_end_date IS NULL
	BEGIN
	SET @campaign_end_date = NULL
	END
	IF @campaign_start_date=''
	BEGIN
	SET @campaign_start_date = NULL
	END
	--0. Get Old Campaign Data 
	--1.CHECK CAMPAIGN ID
	--2.CHECK REDEEMED WINKS
	--3.CHECK UPDATE WINKS
	--4.CHECK EXISTING CAMPAIGN START DATE AND UPDATE CAMPAIGN START DATE 

	--4.CHECK WINK PURCHASED ONLY ?
	
	--5.CHECK BOOKED ASSETS
	
	--0. Get Old Campaign Data 
	Begin
	 DECLARE 
	 @old_merchant_id int,
	 @old_campaign_name varchar(255),
     @old_campaign_code varchar(255),
	 @old_campaign_amount Decimal(10,2),
	 @old_cents_per_wink Decimal(10,2),
	 @old_percent_for_wink Decimal(10,2),
     @old_sales_code varchar(255),
	 @old_sales_commission Decimal(10,2),
	 @old_total_winks int,
	 @old_total_winks_amount Decimal(10,2),
	 @old_agency bit,
	 @old_agency_name varchar(255),
	 @old_agency_commission decimal(10,2),
	 @old_wink_purchase_only int ,
	 @old_wink_purchase_status varchar(50),
	 @old_campaign_start_date varchar(50),
	 @old_campaign_end_date varchar(50),
	 @old_updated_at DateTime,
     @action_object varchar(10),
     @action_type varchar(10)
     
     select @old_merchant_id = merchant_id,
     @old_campaign_name=campaign_name,
     @old_campaign_code=campaign_code,
     @old_campaign_amount=campaign.campaign_amount,
	 @old_cents_per_wink =campaign.cents_per_wink,
	 @old_percent_for_wink=campaign.percent_for_wink,
     @old_sales_code=campaign.sales_code,
	 @old_sales_commission =campaign.sales_commission,
	 @old_total_winks =campaign.total_winks,
	 @old_total_winks_amount =campaign.total_winks_amount,
	 @old_agency =campaign.agency,
	 @old_agency_name =campaign.agency_name,
	 @old_agency_commission = campaign.agency_comm,
	 @old_wink_purchase_only =campaign.wink_purchase_only ,
	 @old_wink_purchase_status =campaign.wink_purchase_status,
	 @old_campaign_start_date = campaign.campaign_start_date,
	 @old_campaign_end_date =campaign.campaign_end_date,
	 @old_updated_at =campaign.updated_at,
     @action_object ='Campaign',
     @action_type ='Edit'    
     from campaign
     where campaign.campaign_id = @campaign_id
     
    
	END
	
	--0. Check Contract No.
	/*IF(@campaign_code is not null and @campaign_code !='')
	IF EXISTS (select campaign.campaign_code from campaign where campaign.campaign_code =@campaign_code
	and campaign_id = @campaign_id)
	BEGIN
			SELECT '0' as response_code, 'Contract No. already in used.' as response_message 
			RETURN
						
	END*/
	
	--1.CHECK CAMPAIGN ID

	IF EXISTS (SELECT campaign_id FROM campaign WHERE campaign.campaign_id = @campaign_id)
		BEGIN  
			--2.CHECK REDEEMED  WINKS
			SET @redeemed_total_winks = ISNULL((SELECT SUM(ISNULL(total_winks,0)) from customer_earned_winks 
			WHERE customer_earned_winks.campaign_id = @campaign_id GROUP BY campaign_id),0)
			
			
				--3.CHECK UPDATE WINKS
				--production 5
				IF (@total_winks < @redeemed_total_winks and @campaign_id !=1)
						BEGIN 
							SELECT '0' as response_code, 'You are not allowed to edit total winks less than total redeemed winks' as response_message 
							RETURN
						
						END
		        ELSE
						BEGIN
						--4.CHECK EXISTING CAMPAIGN START DATE AND UPDATE CAMPAIGN START DATE 
							IF(@campaign_start_date IS NOT NULL)	
								BEGIN
							SET @existing_campaign_start_date =CAST((SELECT campaign.campaign_start_date FROM campaign WHERE campaign.campaign_id =@campaign_id) AS VARCHAR(50))
							SET @existing_campaign_end_date =CAST((SELECT campaign.campaign_end_date FROM campaign WHERE campaign.campaign_id =@campaign_id) AS VARCHAR(50))
								IF (@existing_campaign_start_date IS NOT NULL OR @existing_campaign_start_date !=''  OR @existing_campaign_end_date IS NOT NULL OR @existing_campaign_end_date !='')
									BEGIN
									--print (@redeemed_total_winks)
									--print (@existing_campaign_start_date)
									--print (@campaign_start_date)
										 IF(CAST(@existing_campaign_start_date AS date) < CAST(@campaign_start_date  AS DATE))
										 OR (CAST(@existing_campaign_start_date AS date)>CAST(@campaign_start_date  AS DATE))
										 OR (CAST(@existing_campaign_end_date AS date) < CAST(@campaign_end_date  AS DATE))
										 OR (CAST(@existing_campaign_end_date AS date)>CAST(@campaign_end_date  AS DATE))
										 
										 -- AND @redeemed_total_winks !=0
										  
											BEGIN
												SET @existing_campaign_booking =ISNULL((SELECT TOP 1 asset_management_booking.booking_id FROM asset_management_booking WHERE asset_management_booking.campaign_id = @campaign_id),0)
												IF (@existing_campaign_booking > 0)
												BEGIN
											--SELECT '0' as response_code, 'Error to edit campaign period.There are booked assets in this campaign.' as response_message 
											--	RETURN
													-- update for booked QR assets
													UPDATE asset_management_booking
													SET [start_date] = CAST(@campaign_start_date as DATE),
													[end_date] = CAST(@campaign_end_date as DATE)
													WHERE campaign_id = @campaign_id;
 												END

												IF EXISTS(
													SELECT 1 
													FROM ASSET_WINKGO
													WHERE campaign_id = @campaign_id
												)
												BEGIN
													-- update for WINK+ GO campaign
													UPDATE ASSET_WINKGO
													SET from_date = CAST(@campaign_start_date as DATE),
													to_date = CAST(@campaign_end_date as DATE)
													WHERE campaign_id = @campaign_id;
												END

												SET @RETURN_NO='001'       
												GOTO Cmp_update
											END
									END
									
								END 
									
							
							--4.CHECK WINK PURCHASED ONLY ?
							IF @wink_purchase_only !=0 AND @wink_purchase_status IS NOT NULL
								BEGIN
									
									SET @existing_campaign_booking =ISNULL((SELECT TOP 1 asset_management_booking.booking_id FROM asset_management_booking WHERE asset_management_booking.campaign_id = @campaign_id),0)
										--5.CHECK BOOKED ASSETS
										IF @existing_campaign_booking = 0
											BEGIN
											SET @RETURN_NO='001' -- UPDATE WINK PURCHASED ONLY                          
											GOTO Cmp_update
											END
										ELSE
											BEGIN
													SELECT '0' AS response_code ,'Error to save WINK purchase only.This campaing is already linked to assets' as response_message
					
											END
								END
								
								
								
							ELSE
							
								BEGIN
									SET @RETURN_NO='001' -- UPDATE WINK PURCHASED ONLY                          
									GOTO Cmp_update
								
								END
						
						
						END
					
					
					
				END
			
			
		
	ELSE
		BEGIN
		SELECT '0' as response_code, 'No Campaign Id' as response_message 
			RETURN
		
		END
	
	Cmp_update:                                         
	IF @RETURN_NO='001'                           
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
					agency_comm = @agency_comm,
					total_winks =  @total_winks,
					total_winks_amount = @total_winks_amount,
					agency = @agency,
					wink_purchase_only = @wink_purchase_only,
					wink_purchase_status = @wink_purchase_status,
					agency_name =  @agency_name,
					campaign_start_date = @campaign_start_date,
					campaign_end_date =@campaign_end_date,
					updated_at = @updated_at 
					WHERE campaign_id =@campaign_id
						IF(@@ROWCOUNT>0)
						BEGIN
						       --- Call Campaign Log Storeprocedure Function 
						   Declare @result int

						    EXEC CreateCampaigLog
						    @campaign_id,
						    @old_merchant_id ,
							@old_campaign_name,
							@old_campaign_code,
							@old_campaign_amount,
							@old_cents_per_wink,
							@old_percent_for_wink,
							@old_sales_code ,
							@old_sales_commission,
							@old_total_winks,
							@old_total_winks_amount,
							@old_agency,
							@old_agency_name,
							@old_wink_purchase_only,
							@old_wink_purchase_status,
							@old_campaign_start_date,
							@old_campaign_end_date,
						    @old_updated_at,
							@admin_email,
						    @action_object,
							@action_type,
							@result output ;
						    if(@result=2)
						    BEGIN
						    
				     UPDATE campaign SET 
					campaign_name = @old_campaign_name,
					campaign_code = @old_campaign_code,
					campaign_amount= @old_campaign_amount,       
					cents_per_wink =@old_cents_per_wink ,             
					percent_for_wink =@old_percent_for_wink,
					sales_code = @old_sales_code,
					sales_commission = @old_sales_commission,
					agency_comm = @old_agency_commission,
					total_winks =  @old_total_winks,
					total_winks_amount = @old_total_winks_amount,
					agency = @agency,
					wink_purchase_only = @old_wink_purchase_only,
					wink_purchase_status = @old_wink_purchase_status,
					agency_name =  @old_agency_name,
					campaign_start_date = @old_campaign_start_date,
					campaign_end_date =@old_campaign_end_date,
					updated_at = @old_updated_at 
					WHERE campaign_id =@campaign_id
					SELECT '0' as response_code, 'Failed to save the campaign log ' as response_message 
                     RETURN
						    END
						    
					 ELSE					
							SELECT '1' as response_code, 'Campaign is successfully saved' as response_message 
							RETURN
						END
						ELSE 
						BEGIN
							SELECT '0' as response_code, 'Failed to save the campaign' as response_message 
							RETURN
					
						END
					END                      
	END 
	
END

