CREATE PROCEDURE [dbo].[VerifyWINKGateHit_testing]
(
	@authToken VARCHAR(255),
	@assetId int,
	@ip_address varchar(30),
	@GPS_location varchar(200)
)
	
AS
BEGIN
	--DECLARE @externalCampaignId int = 190;
	--DECLARE @nhbCampaignId int = 206;
	DECLARE @TLMCSilverCampaignId int = 210;
	DECLARE @TLMCGoldenCampaignId int = 211;
	DECLARE @TLMCSapphireCampaignId int = 209;
	DECLARE @TLMCDiamondCampaignId int = 212;
	DECLARE @TLMCStartDate varchar(100) = '2021-10-23';
	DECLARE @TLMCEndDate varchar(100) = '2021-12-23';
	
	DECLARE @RETURN_NO VARCHAR(10)
	
	IF NOT EXISTS (SELECT 1 FROM CUSTOMER WHERE auth_token = @authToken )
	BEGIN
		SET @RETURN_NO='002'; -- Multiple login          
		GOTO Err
	END 

	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT;

	DECLARE @locked_reason varchar(255);
	DECLARE @admin_user_email_for_lock_account varchar(255)  = 'system@winkwink.sg';
	DECLARE @customerId int
    SELECT @customerId = customer_id FROM customer where auth_token = @authToken;

	UPDATE customer 
	SET customer.ip_scanned = @ip_address ,customer.ip_address = @ip_address 
	WHERE customer_id=@customerId;
	IF(@@ROWCOUNT=0)
	BEGIN
		SET @RETURN_NO='003';
		GOTO Err
	END

	IF EXISTS (select 1 from customer where customer.auth_token = @authToken and status ='disable')
    BEGIN
		SET @RETURN_NO='001'; -- account is locked       
		GOTO Err
	END-- END
	
	-- Check time between 00:00 and 05:30
	IF(CAST(@CURRENT_DATETIME as time) > '00:00:00' AND CAST(@CURRENT_DATETIME as time) <= '05:30:00')
	BEGIN
		SET @RETURN_NO='005';
		GOTO Err
	END

	--Daily Limit Checking 250 records (the limit will need to be modified depending on number of assets that we have)
	--IF (
	--		(SELECT COUNT(*) 
	--			FROM wink_gate_points_earned 
	--			WHERE customer_id = @customerId
 --   			AND CAST(created_at as Date) = CAST(@CURRENT_DATETIME as Date)
 --   		 )>=250
	--	)
 --  	BEGIN
	--	SET @RETURN_NO='006';
	--	GOTO Err
 --   END
	
	--LBS
	--IF EXISTS(
	--	SELECT * FROM(
	--		SELECT TOP 25 customer_id,GPS_location
	--		FROM wink_gate_points_earned 
	--		WHERE GPS_location like '%detected%'
	--		AND cast(created_at as date ) =cast(@CURRENT_DATETIME as date ) 
	--		AND customer_id = @customerId 
	--	) as c
	--	HAVING COUNT(*)>=25
	--)
	--BEGIN
	--	IF NOT EXISTS (
	--		SELECT 1 from wink_account_filtering 
	--		where customer_id =@customerId 
	--		and filtering_status = 'verified' 
	--		AND reason like '%no location data received.%'
	--		AND cast(created_at as date) = CAST (@CURRENT_DATETIME as date)
	--	)BEGIN
	--		Insert into System_Log (customer_id, action_status,created_at,reason)
	--		values (@customerId,
	--			'disable',
	--			@CURRENT_DATETIME,
	--			'LBS');
			
	--		-----INSERT INTO ACCOUNT FILTERING LOCK
			
	--		Set @locked_reason = CONCAT('On ',cast(@CURRENT_DATETIME as date),', no location data received.');

	--		DECLARE @verified INT 
	--		EXEC @verified = Create_LBS_AFM @customerId, @locked_reason,@admin_user_email_for_lock_account 
			
	--		if(@verified = 0)
	--		BEGIN
	--			SET @RETURN_NO='001'; -- account is locked due to LBS                    
	--			GOTO Err
	--		END

	--	END
	--END
	--Blocked IP
	--IF EXISTS(
	--	SELECT 1 
	--	FROM wink_customer_block_ip 
	--	WHERE ip_address like @ip_address
	--)
	--BEGIN
	--	UPDATE customer 
	--	SET [status] = 'disable', updated_at = @CURRENT_DATETIME 
	--	WHERE auth_token = @authToken;
	--	IF (@@ROWCOUNT>0)
	--	BEGIN
	--		Insert into System_Log (customer_id, action_status,created_at,reason)
	--		Select customer_id,'disable',@CURRENT_DATETIME,@ip_address
	--		FROM customer 
	--		WHERE auth_token = @authToken;

	--		SET @locked_reason ='Blocked IP';
	--		EXEC Create_WINK_Account_Filtering @customerId,@locked_reason,@admin_user_email_for_lock_account;
	--	END
	--	SET @RETURN_NO='001'   
	--	GOTO Err
	--END

	--Minute lock (vehicles?) (30s)(nearest gate must be at least 1 min away)Depending on the naming of WINK+ Gate assets
	--Declare @prevAssetId int
	--Declare @prevCreatedAt datetime

	--Select TOP(1) @prevAssetId = assetId, @prevCreatedAt = created_at FROM wink_gate_points_earned
	--WHERE customer_id = @customerId
	--AND cast (created_at as date) = cast(@CURRENT_DATETIME as date)
	--order by created_at desc;

	--IF(@prevAssetId != @assetId)
	--BEGIN	
	--	IF(DATEDIFF(second,@prevCreatedAt, @CURRENT_DATETIME) < 30)
	--	BEGIN			
	--		print('shorter than 30s');

	--		Update customer set customer.status = 'disable',
	--		customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @authToken;

	--		IF (@@ROWCOUNT>0)
	--		BEGIN
	--			DECLARE @gateId varchar(100);
	--			SELECT @gateId = gate_id FROM wink_gate_asset WHERE id = @assetId;

	--			Set @locked_reason = 'Minute Lock ('+@gateId+')';

	--			Insert into System_Log (customer_id, action_status,created_at,reason)
	--			Select customer.customer_id,
	--			'disable',@CURRENT_DATETIME,@locked_reason
	--				from customer where customer.auth_token = @authToken;

	--			-----INSERT INTO ACCOUNT FILTERING LOCK
	--			EXEC Create_WINK_Account_Filtering @customerId,@locked_reason,@admin_user_email_for_lock_account;
	--		END
	--	END
	--END

	
	
	
	--check if asset is enabled
	
	DECLARE @interval int;
	DECLARE @points int;
	DECLARE @bookingId int;
	DECLARE @campaignId int;

	--Check booking status
	SELECT @campaignId=c.campaign_id, @bookingId = b.id, @points = b.points, @interval = b.interval
	FROM wink_gate_booking as b,
	wink_gate_campaign as wc,
	campaign as c
	WHERE b.wink_gate_asset_id = @assetId
	AND b.wink_gate_campaign_id = wc.id
	AND wc.campaign_id = c.campaign_id
	AND (cast(@CURRENT_DATETIME as date) between c.campaign_start_date and c.campaign_end_date)
	AND wc.[status] = 1
	AND b.[status] = 1;

	IF(@bookingId is null or @bookingId = 0)
	BEGIN
		SET @RETURN_NO='005'; -- the WINK Gate Asset is disabled as it is not booked by any advertiser
		GOTO Err
	END


	IF(@campaignId = @TLMCSilverCampaignId OR @campaignId = @TLMCGoldenCampaignId)
	BEGIN
		--check for daily limit
		IF (
				(SELECT COUNT(*) 
					FROM wink_gate_points_earned  as e,
					wink_gate_booking as b,
					wink_gate_campaign as wc
					WHERE e.bookingId = b.id
					AND b.wink_gate_campaign_id = wc.id
					AND wc.campaign_id = @campaignId
					AND customer_id = @customerId
    				AND CAST(e.created_at as Date) = CAST(@CURRENT_DATETIME as Date)
    			 )>=5
			)
   		BEGIN
			SET @RETURN_NO='006';
			GOTO Err
		END
	END
	--check inventory count
	--DECLARE @globalCampaignId int = 1;
	--set global campaign total inventory to 5,000,000 points
	--DECLARE @globalCampaignPoints int = 5000000;
	DECLARE @totalPtsAllocated int;
	IF(@campaignId != @TLMCSapphireCampaignId AND @campaignId != @TLMCDiamondCampaignId)
	BEGIN
		DECLARE @totalPtsRedeemed int;
		SELECT @totalPtsRedeemed = sum(e.points) 
		FROM wink_gate_points_earned as e,
		wink_gate_booking as b,
		wink_gate_campaign as wc
		WHERE e.bookingId = b.id
		AND b.wink_gate_campaign_id = wc.id
		AND wc.campaign_id = @campaignId;

		IF(@totalPtsRedeemed is null)
		BEGIN
			SET @totalPtsRedeemed = 0;
		END

		SELECT @totalPtsAllocated = wc.total_points
		FROM wink_gate_campaign as wc
		WHERE wc.campaign_id = @campaignId;

		IF(
			@totalPtsRedeemed >= @totalPtsAllocated
		)
		BEGIN
			SET @RETURN_NO='005'; -- the allocated points have been fully redeemed
			GOTO Err
		END
	END
	
	

	--IF(
	--	@campaignId = @nhbCampaignId
	--	AND 
	--	(CAST(@CURRENT_DATETIME AS date)between '2021-04-19' AND '2021-04-28')
	--)
	--BEGIN
	--	DECLARE @NHBDailyInventory int = 3;
	--	DECLARE @NHBTotalPtsRedeemed int;
	--	SELECT @NHBTotalPtsRedeemed = ISNULL(sum(e.points),0)
	--	FROM wink_gate_points_earned as e,
	--	wink_gate_booking as b,
	--	wink_gate_campaign as wc
	--	WHERE e.bookingId = b.id
	--	AND b.wink_gate_campaign_id = wc.id
	--	AND wc.campaign_id = @campaignId
	--	AND cast(e.created_at as date) = CAST(@CURRENT_DATETIME AS date);

	--	IF(@NHBTotalPtsRedeemed >= @NHBDailyInventory)
	--	BEGIN
	--		SET @RETURN_NO='005'; -- the allocated points have been fully redeemed
	--		GOTO Err
	--	END
	--END
	

	--check frequency
	IF EXISTS(
		SELECT 1 
		FROM wink_gate_points_earned
		WHERE customer_id = @customerId
		AND assetId = @assetId
	)
	BEGIN
		DECLARE @lastLoggedTime DATETIME
		DECLARE @timeDiff int
		
		SELECT TOP(1) @lastLoggedTime = created_at
		FROM wink_gate_points_earned
		WHERE customer_id = @customerId
		AND assetId = @assetId
		order by created_at desc;

		SET @timeDiff = DATEDIFF(MINUTE,@lastLoggedTime,cast(@CURRENT_DATETIME as datetime));
		IF(@timeDiff < (@interval*60) AND @interval != 24 AND @interval != 0)
		BEGIN
			SET @RETURN_NO='004';
			GOTO Err
		END
		ELSE
		BEGIN
			IF (@interval=24)
			BEGIN
				IF(@assetId != 362 AND @assetId != 13 AND @assetId != 54 AND @assetId != 55)
				BEGIN
					IF(Cast(@CURRENT_DATETIME as date) <= Cast (@lastLoggedTime as date))
					BEGIN
						SET @RETURN_NO='004';
						GOTO Err
					END
				END
				
			END
		END
		
	END

	-- For TL Apr Campaign
	-- Check the campaign ID, and user input for the activation code

	--IF(@campaignId = 205)
	--BEGIN
	--	IF(
	--		(SELECT answer 
	--		FROM winktag_customer_survey_answer_detail
	--		WHERE campaign_id = 160
	--		AND customer_id = @customerId)
	--		like 
	--		'UOB%'
	--	)
	--	BEGIN
	--		SET @points = @points*2;
	--	END
	--END
	--TransitLink MasterCard campaign
	--Check if user is non-MC or MC member or neither
	DECLARE @validOTTLMC int = 0;
	DECLARE @validMCTLMC int = 0;
	DECLARE @TLMCWinkPlayCampaignId int = 170;

	DECLARE @tlMCAns varchar(50);
	SELECT @tlMCAns = answer FROM winktag_customer_survey_answer_detail 
	WHERE campaign_id = @TLMCWinkPlayCampaignId 
	AND customer_id = @customerId;

	print('tl answer');
	print(@tlMCAns);

	IF (@tlMCAns IS NOT NULL)
	BEGIN
		SET @validOTTLMC = 1;

		IF(@tlMCAns like 'MC%' OR @tlMCAns like '%,MC%')
		BEGIN
			SET @validMCTLMC = 1;
		END
	END
	print(@validOTTLMC);
	print(@validMCTLMC);

	DECLARE @expiryDatetime datetime;
	SELECT @expiryDatetime = DATEADD(HOUR, system_value , @CURRENT_DATETIME) 
	FROM system_key_value 
	WHERE system_key = 'wink_gate_points_expiry';
			
	INSERT INTO [dbo].[wink_gate_points_earned]
        ([customer_id]
        ,[points]
        ,[assetId]
        ,[bookingId]
        ,[ip_address]
        ,[GPS_location]
        ,[created_at]
		,[expired_at])
		VALUES
		(@customerId
		,@points
		,@assetId
		,@bookingId
		,@ip_address
		,@GPS_location
		,@CURRENT_DATETIME
		,@expiryDatetime);

	IF(@@ROWCOUNT>0)
	BEGIN
		DECLARE @earnPointsId int;
		set @earnPointsId = 0

		--TransitLink MasterCard Campaign Finale
		IF(
			(@campaignId = @TLMCSapphireCampaignId OR @campaignId = @TLMCDiamondCampaignId)
			AND @validOTTLMC = 1
			AND (CAST(@CURRENT_DATETIME AS date)between @TLMCStartDate AND @TLMCEndDate)
		)
		BEGIN
			print(@campaignId);
			--For non-MC users
			IF(@validMCTLMC = 0)
			BEGIN
				DECLARE @TLMCSapphireInventory int = 300;
				DECLARE @TLMCSapphireWinnerEntry int = 28;
				DECLARE @TLMCSapphireWinnerCount int = 0;
				DECLARE @TLMCSapphirePts int =2000;
				
				SELECT @TLMCSapphireWinnerCount = COUNT(*) FROM winners_points 
				WHERE entry_id = @TLMCSapphireWinnerEntry
				print('sapphire winner count');
				print(@TLMCSapphireWinnerCount);

				IF( 
					@TLMCSapphireInventory > @TLMCSapphireWinnerCount
				)BEGIN
					-- check if the user has won the lucky draw for sapphire gates
					IF NOT EXISTS(
						SELECT 1 FROM winners_points 
						WHERE entry_id = @TLMCSapphireWinnerEntry 
						AND customer_id = @customerId
					)
					BEGIN
						DECLARE @luckyNum int
					
						SELECT @luckyNum = ROUND(((100 - 1 -1) * RAND() + 1), 0)
						print('sapphire lucky number: ');
						print(@luckyNum);
						-- odds need to be updated to 1
						IF(@luckyNum <= 50)
						BEGIN
							SELECT TOP(1) @earnPointsId = id 
							FROM wink_gate_points_earned
							WHERE customer_id = @customerId
							AND assetId = @assetId
							AND bookingId = @bookingId
							AND cast(created_at as date) = cast(@CURRENT_DATETIME as date)
							ORDER BY created_at desc;

							UPDATE [dbo].[customer_balance]
							SET total_points = (total_points + @TLMCSapphirePts)
							WHERE customer_id = @customerId;

							INSERT INTO [dbo].[winners_points]
									([entry_id]
									,[customer_id]
									,[points]
									,[location]
									,[created_at])
								VALUES
									(@TLMCSapphireWinnerEntry
									,@customerId
									,@TLMCSapphirePts
									,@earnPointsId
									,@CURRENT_DATETIME);
							
							IF(@@ROWCOUNT>0)
							BEGIN
								IF(@TLMCSapphireInventory = (@TLMCSapphireWinnerCount+1))
								BEGIN
									UPDATE [dbo].[wink_gate_campaign]
									SET [status] = 0
									WHERE campaign_id = @TLMCSapphireCampaignId;
									print('sapphire wink gate campaign is concluded');

									UPDATE campaign 
									SET campaign_status = 'disable'
									where campaign_id = @TLMCSapphireCampaignId;
									print('sapphire advertiser campaign is disabled');
									-- if diamond campaign is concluded as well
									IF(
										(
											SELECT [status] 
											FROM [dbo].[wink_gate_campaign]
											WHERE campaign_id = @TLMCDiamondCampaignId
										)
										= 0
									)
									BEGIN
										UPDATE [dbo].[winktag_campaign]
										SET winktag_status = '0'
										WHERE campaign_id = @TLMCWinkPlayCampaignId;
											print('winktag campaign is concluded')
									END
								END
								print('won 2000 points');
							END
							ELSE
							BEGIN
								print('sapphire lucky but failed to insert the record');
							END
						END
						ELSE
						BEGIN
							print('sapphire unlucky')
						END
					END
					ELSE
					BEGIN
						print('sapphire user has already won once')
					END
				END
				ELSE
				BEGIN
					print('prize for sapphire has run out')
				END
			END
			ELSE IF(@validMCTLMC = 1)
			BEGIN
				DECLARE @TLMCDiamondInventory int = 120;
				DECLARE @TLMCDiamondWinnerEntry int = 29;
				DECLARE @TLMCDiamondWinnerCount int = 0;
				DECLARE @TLMCDiamondPts int =5000;
				
				SELECT @TLMCDiamondWinnerCount = COUNT(*) FROM winners_points 
				WHERE entry_id = @TLMCDiamondWinnerEntry

				IF( 
					@TLMCDiamondInventory > @TLMCDiamondWinnerCount
				)BEGIN
					-- check if the user has won the lucky draw for diamond gates
					IF NOT EXISTS(
						SELECT 1 FROM winners_points 
						WHERE entry_id = @TLMCDiamondWinnerEntry 
						AND customer_id = @customerId
					)
					BEGIN
						DECLARE @luckyDiamondNum int
						SELECT @luckyDiamondNum = ROUND(((100 - 1 -1) * RAND() + 1), 0)
						print('Diamond lucky number: ');
						print(@luckyDiamondNum);
						-- odds need to be updated to 1
						IF(@luckyDiamondNum <= 50)
						BEGIN
							SELECT TOP(1) @earnPointsId = id 
							FROM wink_gate_points_earned
							WHERE customer_id = @customerId
							AND assetId = @assetId
							AND bookingId = @bookingId
							AND cast(created_at as date) = cast(@CURRENT_DATETIME as date)
							ORDER BY created_at desc;

							UPDATE [dbo].[customer_balance]
							SET total_points = (total_points + @TLMCDiamondPts)
							WHERE customer_id = @customerId;

							INSERT INTO [dbo].[winners_points]
									([entry_id]
									,[customer_id]
									,[points]
									,[location]
									,[created_at])
								VALUES
									(@TLMCDiamondWinnerEntry
									,@customerId
									,@TLMCDiamondPts
									,@earnPointsId
									,@CURRENT_DATETIME);
							
							IF(@@ROWCOUNT>0)
							BEGIN
								IF(@TLMCDiamondInventory = (@TLMCDiamondWinnerCount+1))
								BEGIN
									UPDATE [dbo].[wink_gate_campaign]
									SET [status] = 0
									WHERE campaign_id = @TLMCDiamondCampaignId;
									print('diamond wink gate campaign is concluded');

									UPDATE campaign 
									SET campaign_status = 'disable'
									where campaign_id = @TLMCDiamondCampaignId;
									print('diamond advertiser campaign is disabled');
									-- if sappire campaign is concluded as well
									IF(
										(
											SELECT [status] 
											FROM [dbo].[wink_gate_campaign]
											WHERE campaign_id = @TLMCSapphireCampaignId
										)
										= 0
									)
									BEGIN
										UPDATE [dbo].[winktag_campaign]
										SET winktag_status = '0'
										WHERE campaign_id = @TLMCWinkPlayCampaignId;
										print('disable wink play campaign');
									END
								END
								print('won 5000 points');
							END
							ELSE
							BEGIN
								print('Diamond lucky but failed to insert the record');
							END
						END
						ELSE
						BEGIN
							print('Diamond unlucky')
						END
					END
					ELSE
					BEGIN
						print('Diamond user has already won once')
					END
				END
				ELSE
				BEGIN
					print('prize for Diamond has run out')
				END
			END
		END
		-- check if it's NHB campaign
		--IF(
		--	@campaignId = @nhbCampaignId
		--	AND 
		--	(CAST(@CURRENT_DATETIME AS date)between '2021-04-19' AND '2021-04-28')
		--)
		--BEGIN
		--	print(@campaignId);
		--	--wink gate campaign ID needs to be updated
		--	IF EXISTS(
		--		SELECT 1 
		--		FROM wink_gate_booking as b
		--		WHERE b.wink_gate_campaign_id = 42
		--		AND b.[status] = 1
		--		AND b.wink_gate_asset_id = @assetId
		--	)
		--	BEGIN
		--		declare @entryId int = 23;
		--		declare @noOfDays int
		--		SELECT @noOfDays = DATEDIFF(day, '2021-04-19', cast (@CURRENT_DATETIME as date));
		--		print('day difference: ');
		--		print(@noOfDays);

		--		declare @pastWinnerCount int
		--		SELECT @pastWinnerCount = COUNT(*) 
		--		FROM winners_points 
		--		where entry_id = @entryId 
		--		AND cast(created_at as date) < cast(@CURRENT_DATETIME as date);
		--		print('past winner count: ');
		--		print(@pastWinnerCount);

		--		declare @maxWinnerCount int
		--		-- 1 winner a day
		--		set @maxWinnerCount = @noOfDays * 1 - @pastWinnerCount +1;
		--		print('max winner count: ');
		--		print(@maxWinnerCount);
				
		--		--check if total inventory is met
		--		IF( 
		--			(
		--				SELECT COUNT(*) FROM winners_points 
		--				WHERE entry_id = @entryId and cast(created_at as date) = cast(@CURRENT_DATETIME as date)
		--			) 
		--			< @maxWinnerCount
		--		)
		--		BEGIN
		--			-- check if the user has not won for today
		--			IF NOT EXISTS(
		--				SELECT 1 FROM winners_points 
		--				WHERE entry_id = @entryId 
		--				AND customer_id = @customerId
		--				AND cast(created_at as date) = CAST(@CURRENT_DATETIME AS date)
		--			)
		--			BEGIN
		--				DECLARE @luckyNum int
		--				SELECT @luckyNum = ROUND(((100 - 1 -1) * RAND() + 1), 0)
		--				print('lucky number: ');
		--				print(@luckyNum);
		--				-- odds need to be updated to 1
		--				IF(@luckyNum <= 50)
		--				BEGIN
							

		--					SELECT TOP(1) @earnPointsId = id 
		--					FROM wink_gate_points_earned
		--					WHERE customer_id = @customerId
		--					AND assetId = @assetId
		--					AND bookingId = @bookingId
		--					AND cast(created_at as date) = cast(@CURRENT_DATETIME as date)
		--					ORDER BY created_at desc;

		--					INSERT INTO [dbo].[winners_points]
		--							([entry_id]
		--							,[customer_id]
		--							,[points]
		--							,[location]
		--							,[created_at])
		--						VALUES
		--							(@entryId
		--							,@customerId
		--							,0
		--							,@earnPointsId
		--							,@CURRENT_DATETIME);
							
		--					IF(@@ROWCOUNT>0)
		--					BEGIN
		--						DECLARE @winnerIdList varchar(MAX);
		--						DECLARE @luckyDrawId int = 24;
		--						SELECT @winnerIdList = winner_id
		--						FROM [winkwink].[dbo].[Winktag_Lucky_Draw]
		--						WHERE winktag_lucky_draw_id = @luckyDrawId;

		--						IF(@winnerIdList = '')
		--						BEGIN
		--							UPDATE [winkwink].[dbo].[Winktag_Lucky_Draw]
		--							SET winner_id = cast(@customerId as varchar)
		--							WHERE winktag_lucky_draw_id = @luckyDrawId;
		--						END
		--						ELSE
		--						BEGIN
		--							UPDATE [winkwink].[dbo].[Winktag_Lucky_Draw]
		--							SET winner_id = @winnerIdList +','+ cast(@customerId as varchar)
		--							WHERE winktag_lucky_draw_id = @luckyDrawId;
		--						END
		--						print('won 500 points');
		--						SET @ifWin = 1;
		--					END
		--					ELSE
		--					BEGIN
		--						print('lucky but failed to insert the record');
		--					END
		--				END
		--				ELSE
		--				BEGIN
		--					print('unlucky');
		--				END
		--			END
		--			ELSE
		--			BEGIN
		--				print('already won for today')
		--			END
		--		END
		--		ELSE
		--		BEGIN
		--			print('fully redeemed for the day')
		--		END
				
		--	END
		--	ELSE
		--	BEGIN
		--		print('other asset')
		--	END
		--END
		--ELSE
		--BEGIN
		--	print('other dates')     
		--END                  
           
		--inject points to winkgo
		DECLARE @counter int=1;
		
		IF(@campaignId != @TLMCSapphireCampaignId AND @campaignId != @TLMCDiamondCampaignId)
		BEGIN
			WHILE @counter<=@points
			BEGIN
				insert into nonstop_net_canid_earned_points (customer_id ,created_at,business_date,can_id,card_type,total_tabs,total_points,updated_at,campaign_id,wink_gate_asset_id, ip_address, gps_location,wink_gate_points_earned_id)
						values (@customerId ,@CURRENT_DATETIME,@CURRENT_DATETIME, '','11',1,1,@CURRENT_DATETIME,@campaignId,@bookingId,@ip_address, @GPS_location, @earnPointsId)
				set @counter = @counter + 1
			END

			--disable the campaign if all points are issued
			IF(@campaignId = @TLMCSilverCampaignId OR @campaignId = @TLMCGoldenCampaignId)
			BEGIN
				
				--print('silver or golden gate, check balance')
				--print('total allocated (before): ');
				--print(@totalPtsAllocated);
				--SET	@totalPtsAllocated = 67;
				--print('total allocated (after): ');
				--print(@totalPtsAllocated);

				IF(
					(
						SELECT ISNULL(sum(e.points),0)
						FROM wink_gate_points_earned as e,
						wink_gate_booking as b,
						wink_gate_campaign as wc
						WHERE e.bookingId = b.id
						AND b.wink_gate_campaign_id = wc.id
						AND wc.campaign_id = @campaignId
					) 
					>= @totalPtsAllocated
				)
				BEGIN
					UPDATE [dbo].[wink_gate_campaign]
					SET [status] = 0
					WHERE campaign_id = @campaignId;
					print('silver or golden wink gate campaign is concluded');

					UPDATE campaign 
					SET campaign_status = 'disable'
					where campaign_id = @campaignId;
					print('silver or golden advertiser campaign is disabled');
				END
			END

			SET @RETURN_NO='000';
			GOTO Err
		END
		ELSE
		BEGIN
			insert into nonstop_net_canid_earned_points (customer_id ,created_at,business_date,can_id,card_type,total_tabs,total_points,updated_at,campaign_id,wink_gate_asset_id, ip_address, gps_location,wink_gate_points_earned_id)
						values (@customerId ,@CURRENT_DATETIME,@CURRENT_DATETIME, '','11',1,0,@CURRENT_DATETIME,@campaignId,@bookingId,@ip_address, @GPS_location, @earnPointsId)
				
			SET @RETURN_NO='000';
			GOTO Err
		END
		
	END
	ELSE
	BEGIN
		SET @RETURN_NO='003';
		GOTO Err
	END

	Err:
	IF @RETURN_NO='000'                          
	BEGIN 
		--IF(
		--	@campaignId = @nhbCampaignId
		--	AND 
		--	(CAST(@CURRENT_DATETIME AS date)between '2021-04-19' AND '2021-04-28')
		--)
		--BEGIN
		--	print(@campaignId);
		--	IF(@ifWin = 1)
		--	BEGIN
		--		print('won 500 points');
		--		DECLARE @email VARCHAR(100);
		--		SELECT @email = customer.email  FROM customer WHERE customer.customer_id = @customerId;

		--		SELECT '4' as response_code,'Congrats!' as response_message, @email as email;
		--		RETURN 
		--	END
		--	ELSE
		--	BEGIN
		--		print('did not win');
		--		SELECT '1' as response_code, 'Please head to WINK+ GO page for points redemption.' as response_message;
		--		RETURN 
		--	END
		--	--SELECT '1' as response_code, 'Please head to WINK+ GO page for points redemption.' as response_message;
		--	--RETURN 
		--END
		--ELSE
		--BEGIN
			print('other dates')
			SELECT '1' as response_code, 'Please head to WINK+ GO page for points redemption.' as response_message;
			RETURN        
		--END                  
	END                                          
	ELSE IF @RETURN_NO='001'                          
	BEGIN 
		SELECT '3' as response_code, 'Your account is locked. Please contact customer service.' as response_message;
		RETURN                           
	END 
	ELSE IF @RETURN_NO='002'                          
	BEGIN 
		SELECT '2' as response_code, 'Multiple logins not allowed' as response_message;
		RETURN                           
	END 
	ELSE IF @RETURN_NO='003'                          
	BEGIN 
		SELECT '0' as response_code, 'Oops, something is wrong. Please try again later.' as response_message;
		RETURN                           
	END 
	ELSE IF @RETURN_NO='004'                          
	BEGIN 
		SELECT '0' as response_code, 'You''ve already hit this gate. Please come back later.' as response_message;
		RETURN                           
	END 
	ELSE IF @RETURN_NO='005'                          
	BEGIN 
		SELECT '0' as response_code, 'Invalid Hit' as response_message;
		RETURN                           
	END 
	ELSE IF @RETURN_NO='006'                          
	BEGIN 
		SELECT '0' as response_code, 'Daily limit reached' as response_message;
		RETURN                           
	END
	ELSE
	BEGIN 
		SELECT '0' as response_code, 'Invalid Hit' as response_message;
		RETURN                           
	END
END
