
CREATE PROCEDURE [dbo].[Insert_CanId_Earned_Points_v01]
	(@can_id varchar (150),
	  @business_date datetime ,
	  @total_tabs int ,
	  @total_points int,
	  @created_at datetime
	)
	  
AS
BEGIN
DECLARE @customer_id  int 
DECLARE @current_date datetime
--Declare @NETsPromotionPoints int
--Declare @NETPromotionTotal int
--Declare @NetPromotionStatus int
--DEclare @NETPromotionStartDate datetime
--Declare @NETPromotionEndDate datetime

--set @NETsPromotionPoints = 0
--set @NETPromotionTotal = 30000
--set @NetPromotionStatus = 1
--set @NETPromotionStartDate ='2017-08-15'
--set @NETPromotionEndDate ='2017-11-15'



EXEC dbo.GET_CURRENT_SINGAPORT_DATETIME @current_date output

    IF NOT EXISTS (select 1 from wink_canid_earned_points where can_id =@can_id and CAST (business_date as DATE) = CAST (@business_date as DATE))
	BEGIN
	IF EXISTS (select can_id.customer_id from can_id where can_id.customer_canid = @can_id
	and can_id.customer_id IN (select customer.customer_id from customer where customer.[status]='enable')
	)
		BEGIN
		---1. Insert to canid_earned_points
			set @customer_id = (select can_id.customer_id from can_id where can_id.customer_canid = @can_id)

			--- Check Chuned Customer
			IF NOT EXISTS (select 1 from customer_churned where customer_id =@customer_id)
				BEGIN 

				      ---- Check Chuned Trip Only

					  IF NOT EXISTS (select 1 from customer_churned_for_trip where customer_id =@customer_id)
					  BEGIN
						DECLARE @counter int=1;
						SET @total_points = 0;
						WHILE @counter<=@total_tabs
						BEGIN
							--testing
							DECLARE @campaignId int = 1;
							--production
							--DECLARE @campaignId int = 5;
							DECLARE @winkgoPts int =1;
			
							SELECT TOP(1) @campaignId = campaign_id, @winkgoPts = points
							FROM [winkwink].[dbo].[ASSET_WINKGO]
							WHERE (Cast(@created_at as date) BETWEEN CAST(from_date AS DATE) AND CAST(to_date AS DATE))
							AND [status] like '1'
							ORDER by NEWID();

							INSERT INTO nonstop_net_canid_earned_points 
							([can_id]
							,[business_date]
							,[total_tabs]
							,[total_points]
							,[created_at]
							,[customer_id]
							,[card_type]
							,[points_credit_status]
							,[point_redemption_date]
							,[trans_amount]
							,[updated_at]
							,[gps_location]
							,[points_expired_status]
							,[campaign_id]
							,[wink_gate_asset_id]
							,[ip_address]
							,[wink_gate_points_earned_id])
							VALUES 
							(@can_id
							,@business_date
							,1
							,@winkgoPts
							,@created_at
							,@customer_id 
							,'10'
							,0
							,NULL
							,0.00
							,@created_at
							,NULL
							,'0'
							,@campaignId
							,NULL
							,NULL
							,NULL);

							SET @counter = @counter + 1;
							SET @total_points+=@winkgoPts;
						END
						INSERT INTO wink_canid_earned_points 
						(can_id,business_date,total_tabs,total_points,created_at,customer_id,[source])
						VALUES (@can_id,@business_date,@total_tabs,@total_points,@created_at,@customer_id,'trip')
					  END
					  ELSE
					  BEGIN

						IF( DAY(@current_date) >=25)
						BEGIN
							DECLARE @resurrectedCounter int=1;
							SET @total_points = 0;
							WHILE @resurrectedCounter<=@total_tabs
							BEGIN
								--testing
								DECLARE @resurrectedCampaignId int = 1;
								--production
								--DECLARE @campaignId int = 5;
								DECLARE @resurrectedWinkgoPts int =1;
			
								SELECT TOP(1) @resurrectedCampaignId = campaign_id, @resurrectedWinkgoPts = points
								FROM [winkwink].[dbo].[ASSET_WINKGO]
								WHERE (Cast(@created_at as date) BETWEEN CAST(from_date AS DATE) AND CAST(to_date AS DATE))
								AND [status] like '1'
								ORDER by NEWID();

								INSERT INTO nonstop_net_canid_earned_points 
								([can_id]
								,[business_date]
								,[total_tabs]
								,[total_points]
								,[created_at]
								,[customer_id]
								,[card_type]
								,[points_credit_status]
								,[point_redemption_date]
								,[trans_amount]
								,[updated_at]
								,[gps_location]
								,[points_expired_status]
								,[campaign_id]
								,[wink_gate_asset_id]
								,[ip_address]
								,[wink_gate_points_earned_id])
								VALUES 
								(@can_id
								,@business_date
								,1
								,@resurrectedWinkgoPts
								,@created_at
								,@customer_id 
								,'10'
								,0
								,NULL
								,0.00
								,@created_at
								,NULL
								,'0'
								,@resurrectedCampaignId
								,NULL
								,NULL
								,NULL);

								SET @resurrectedCounter = @resurrectedCounter + 1;
								SET @total_points+=@resurrectedWinkgoPts;
							END
							INSERT INTO wink_canid_earned_points 
						    (can_id,business_date,total_tabs,total_points,created_at,customer_id,[source])
						     VALUES (@can_id,@business_date,@total_tabs,@total_points,@created_at,@customer_id,'trip')

						END

						ELSE
						BEGIN
							INSERT INTO [wink_canid_earned_points_chuned_customer] 
							(can_id,business_date,total_tabs,total_points,created_at,customer_id,churned_from)
							VALUES (@can_id,@business_date,@total_tabs,@total_points,@created_at,@customer_id,'trip')

					        Return 0

						END

					  END

				END
			ELSE
				BEGIN

					INSERT INTO [wink_canid_earned_points_chuned_customer] 
					(can_id,business_date,total_tabs,total_points,created_at,customer_id)
					VALUES (@can_id,@business_date,@total_tabs,@total_points,@created_at,@customer_id)

					Return 0

				END
		END

		--IF(@@ROWCOUNT>0)
		--BEGIN
		 ---2. Check NETs Promotion
		 --IF(cast(@business_date as date) > = cast(@NETPromotionStartDate as date) and 
		 --cast(@business_date as date) < = cast(@NETPromotionEndDate as date) and
		 --@NetPromotionStatus =1)
		 --BEGIN
		 ----print('check NETs step 1 Pass')
		 -----3. Check registered SMRT CAN ID
			--	 IF EXISTS (select 1 From SMRTNETsCANIDs as a where a.can = @can_id)
			--	 BEGIN
			--	-- print('check NETs step 2 Pass')
			--		 IF NOT EXISTS (select 1 from wink_net_canid_earned_points where can_id = @can_id and 
			--		 promotion_name ='NETs2017')		 
			--		 BEGIN
			--		 --print('check NETs step 3 Pass')
			--		  if((select count(*) from wink_net_canid_earned_points where promotion_name ='NETs2017') < @NETPromotionTotal)
			--			  BEGIN
			--			       --print('check NETs step 4 Pass')
							
			--					 set @NETsPromotionPoints = 50

			--					 INSERT INTO wink_net_canid_earned_points 
			--					(can_id,business_date,total_tabs,total_points,created_at,customer_id,promotion_name)
			--					VALUES (@can_id,@business_date,@total_tabs,@NETsPromotionPoints,@created_at,@customer_id,'NETs2017')
			--			  END
			--		 END

			--	 END
		 --END
		 ---4. Calculate the points
				 --set @total_points = @total_points + @NETsPromotionPoints
		 ---5. Check customer balance (only add the entries into wink go, without crediting the points)

			
		
			 --IF EXISTs (select 1 from customer_balance where customer_id = @customer_id)
				-- BEGIN
			    
				--	update customer_balance set total_points +=@total_points where customer_id =@customer_id
				--	return @@ROWCOUNT
				-- END
			 --ELSE
				-- BEGIN
				-- insert into customer_balance (customer_id,total_points,total_redeemed_amt)
				-- values (@customer_id,@total_points,0.00)
				-- return @@ROWCOUNT
				-- END

		--END
	return @@ROWCOUNT
	END
END



--select * from customer_churned

