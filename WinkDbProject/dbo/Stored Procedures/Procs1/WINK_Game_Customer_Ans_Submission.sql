
CREATE PROCEDURE [dbo].[WINK_Game_Customer_Ans_Submission]
(	@campaign_id int,
	@customer_id int,
	@option_id int,
	@session_id int,
	@winner varchar(5),
	@location varchar(250),
	@ip_address varchar(50)
)
AS
BEGIN

	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

	
					

	--0)CUSTOMER ID is null or empty
	IF (@customer_id is null or @customer_id = '')
	BEGIN
		SELECT '0' AS response_code, 'Poor network connection' as response_message
		return
	END

	--1)CHECK CUSTOMER
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_CUSTOMER WHERE customer_id = @customer_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Customer' as response_message
		return
	END


	DECLARE @campaignEndedMsg varchar(200) = 'Sorry to cut your tour short. WINK+ CITY is now closed. Please stay tuned for our future campaigns! Thank you for visiting and see you again soon!'
	
	--2)CHECK CAMPAIGN
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
	BEGIN
		IF(@campaign_id = 165)
		BEGIN
			SELECT '0' as response_code, @campaignEndedMsg as response_message
			RETURN
		END
		ELSE IF(@campaign_id = 134)
		BEGIN
			SELECT '0' AS response_code, 'Invalid Campaign' as response_message
			RETURN
		END
		
	END

		
	IF(@campaign_id = 165)
	BEGIN
		IF(cast(@CURRENT_DATETIME as time) between '00:00:00.000' and '05:29:59.999')
		BEGIN
			IF(cast(@CURRENT_DATETIME as date) < '2022-06-30')
			BEGIN
				SELECT '0' AS response_code, 'Sorry to cut your tour short. WINK+ CITY is now closed for the day. Please visit us again between 530am and 1159pm. Thank you.' as response_message
				RETURN
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, @campaignEndedMsg as response_message
				RETURN
			END
		END
	END



	-- check if session has expired
	IF EXISTS(SELECT 1 from wink_game_session where campaign_id = @campaign_id and id = @session_id and expired_at >= @CURRENT_DATETIME)
	BEGIN
		DECLARE @return_value int = 0;
		DECLARE @attemptCount int;
		DECLARE @points int;
		DECLARE @msg varchar(max);

		IF(@campaign_id = 165)
		BEGIN
			-- check if user has already participated for 6 times
			SET @attemptCount = (select count(1) from wink_game_customer_result where campaign_id = @campaign_id and customer_id = @customer_id and cast(created_at as date) = cast(@CURRENT_DATETIME as date));
			IF (@attemptCount<6)
			BEGIN
				
				DECLARE @bonusPts int = 20;
				DECLARE @entryId int = 25;

				SET @points = (SELECT points FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id);
				
				IF EXISTS(select 1 from winktag_survey_option where campaign_id = @campaign_id and option_id = @option_id)
				BEGIN
					IF @location is null or @location = '' or @location = '(null)'
					BEGIN
						SET @location = 'User location cannot be detected';
					END

					DECLARE @characterNum int;

					IF NOT EXISTS (
					SELECT 1 
					from wink_game_customer_result
					where campaign_id = @campaign_id 
					and customer_id = @customer_id 
					and cast(created_at as date) = cast(@CURRENT_DATETIME as date)
					and option_id = @option_id
					)
					BEGIN
						
						SELECT @msg = image_name 
						FROM winktag_survey_option
						WHERE option_id = @option_id;

						DECLARE @winnerMsgHeader varchar(100) = '<b style="color:#ea0e95;">CONGRATULATIONS!</b><br><br>';
						DECLARE @winnerBody varchar(150) = '<b>You have won the WINK+ CITY BONUS!<br>20 points have been credited to your WINK+ account!</b><br><br>';
						DECLARE @winnerEnd varchar(100) = 'Visit all 6 stations of WINK+ CITY for more rewards!'
						DECLARE @winnerEndFinal varchar(100) = 'Thank you for completing the WINK+ CITY tour.'

						DECLARE @msgHeader varchar(100) = '<b style="color:#ea0e95;">SAFETY GUIDELINE</b><br><br>';
						DECLARE @msgBody varchar(150) = '<br><br>You have earned 2 points! Please claim your points via WINK+ GO before they expire.<br><br>';
						DECLARE @msgEnd varchar(100) = 'Visit all 6 stations of WINK+ CITY and get rewarded!'
						DECLARE @msgFinal varchar(100) = 'Congratulations! You have completed the WINK+ CITY Tour!'

						IF(@winner = '1')
						BEGIN
							IF NOT EXISTS (SELECT 1 FROM wink_game_customer_result 
								where campaign_id = @campaign_id 
								and customer_id = @customer_id 
								and cast(created_at as date) = cast(@CURRENT_DATETIME as date)
								and winner like '1'
							)
							BEGIN
								DECLARE @dailyWinnerInventory int = 50;

								declare @noOfDays int
								SELECT @noOfDays = DATEDIFF(day, '2021-05-21', cast(@CURRENT_DATETIME as date));
								print('day difference: ');
								print(@noOfDays);

								declare @pastWinnerCount int
								SELECT @pastWinnerCount = COUNT(*) 
								FROM winners_points 
								where entry_id = @entryId 
								AND cast(created_at as date) < cast(@CURRENT_DATETIME as date);
				
				
								print('past winner count: ');
								print(@pastWinnerCount);

								declare @maxWinnerCount int
								-- 50 winners a day
								set @maxWinnerCount = @noOfDays * @dailyWinnerInventory - @pastWinnerCount +@dailyWinnerInventory;
								print('max winner count: ');
								print(@maxWinnerCount);
				
								--check if total inventory is met
								IF( 
									(
										SELECT COUNT(*) FROM winners_points 
										WHERE entry_id = @entryId and cast(created_at as date) = cast(@CURRENT_DATETIME as date)
									) 
									< @maxWinnerCount
								)
								BEGIN
									SET @points = @points + @bonusPts;
									set @msg = @winnerMsgHeader+@winnerBody;
									IF(@attemptCount < 5)
									BEGIN
										set @msg = @msg+@winnerEnd;
									END
									ELSE
									BEGIN
										set @msg = @msg+@winnerEndFinal;
									END
								
								END
								ELSE
								BEGIN
									-- inventory count for winners is exhausted for the day
									SET @winner = '0';
								
									set @msg = @msgHeader+@msg+@msgBody;

									IF(@attemptCount < 5)
									BEGIN
										set @msg = @msg+@msgEnd;
									END
									ELSE
									BEGIN
										set @msg = @msg+@msgFinal;
									END
								END
							END
							ELSE
							BEGIN
								SET @winner = '0';
							END
							
						END
						ELSE
						BEGIN
							set @msg = @msgHeader+@msg+@msgBody;
							IF(@attemptCount < 5)
							BEGIN
								set @msg = @msg+@msgEnd;
							END
							ELSE
							BEGIN
								set @msg = @msg+@msgFinal;
							END
						END

						INSERT INTO [dbo].[wink_game_customer_result]
					   ([session_id]
					   ,[customer_id]
					   ,[campaign_id]
					   ,[option_id]
					   ,[ip_address]
					   ,[gps_location]
					   ,[point]
					   ,[winner]
					   ,[created_at]
					   ,[redemption_status])
						VALUES
					   (@session_id
					   ,@customer_id
					   ,@campaign_id
					   ,@option_id
					   ,@ip_address
					   ,@location
					   ,@points
					   ,@winner
					   ,@CURRENT_DATETIME
					   ,'0');

						IF(@@ROWCOUNT>0)
						BEGIN
							-- once the total inventory is met, disable the campaign immediately
							IF(
								(SELECT COUNT(1) FROM wink_game_customer_result WHERE campaign_id = @campaign_id)
								>= 76500
							)
							BEGIN
								UPDATE winktag_campaign
								SET winktag_status = '0'
								WHERE campaign_id = @campaign_id
								AND updated_at = @CURRENT_DATETIME;
							END
							UPDATE wink_game_customer_log 
							SET survey_complete_status = 1
							WHERE customer_id = @customer_id 
							AND CAMPAIGN_ID = @campaign_id 
							AND cast(created_at as date) = cast(@CURRENT_DATETIME as date);

							DECLARE @responseCode varchar(5) = '1';

							IF(@winner = '1')
							BEGIN
								INSERT INTO [dbo].[winners_points]
									([entry_id]
									,[customer_id]
									,[points]
									,[location]
									,[created_at])
								VALUES
									(@entryId
									,@customer_id
									,@bonusPts
									,''
									,@CURRENT_DATETIME);
								IF(@@ROWCOUNT>0)
								BEGIN
									
									IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
									BEGIN
										UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+@bonusPts 
										WHERE CUSTOMER_ID =@CUSTOMER_ID;
									END
									ELSE
									BEGIN
										INSERT INTO customer_balance 
										(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans)
										VALUES
										(@CUSTOMER_ID,@bonusPts,0,0,0,0,0,0);
									END
									SET @responseCode = '2';
								END
							END
							
							DECLARE @winkGoPts int = @points;

							IF(@winner = '1')
							BEGIN
								SET @winkGoPts = @winkGoPts-@bonusPts;
							END

							IF(@winkGoPts > 0)
							BEGIN
								-- here to insert winkgo points.
							
								EXEC @return_value = [dbo].[WINK_GO_CUSTOMER_EARNED_POINTS]
								@customer_id = @customer_id,
								@campaign_id = @campaign_id,
								@points = @winkGoPts
								IF(@return_value>0)
								BEGIN
									SELECT @responseCode as response_code, @msg as response_message, @session_id as session_id
									return
								END
							END
							ELSE
							BEGIN
								SELECT @responseCode as response_code, @msg as response_message, @session_id as session_id
								return
							END
							
					
						END
						ELSE
						BEGIN
							SELECT '0' as response_code, 'Insertion failed' as response_message, @session_id as session_id
							return
						END
					END
				
				END
				ELSE
				BEGIN
					SELECT '0' as response_code, 'Invalid option' as response_message, @session_id as session_id
					return
				END

	
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you! You have already participated for today.' as response_message
				return
			END
		END
		ELSE IF(@campaign_id = 134)
		BEGIN
			-- check if user has already participated for 4 times
			SET @attemptCount = (select count(1) from wink_game_customer_result where campaign_id = @campaign_id and customer_id = @customer_id and session_id = @session_id);
			IF (@attemptCount<4)
			BEGIN

				IF(@winner = '1')
				BEGIN
					SET @points = (SELECT points FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id);
					IF(@attemptCount < 3)
					BEGIN
						set @msg = 'Congrats! You have won the prize. Play again?';
					END
					ELSE
					BEGIN
						set @msg = 'Congrats! You have won the prize. Wait for the next round to win more prizes.';
					END
				END
				ELSE
				BEGIN
					SET @points = 0;
					IF(@attemptCount < 3)
					BEGIN
						set @msg = 'Nothing to see here. Please choose another building.';
					END
					ELSE
					BEGIN
						set @msg = 'Nothing to see here. Wait for the next round and try again.';
					END
				END
			
				IF(@attemptCount = 3)
				BEGIN
					UPDATE wink_game_session
					set expired_at = @CURRENT_DATETIME
					where id = @session_id
				END

				IF EXISTS(select 1 from winktag_survey_option where campaign_id = @campaign_id and option_id = @option_id)
				BEGIN
					IF @location is null or @location = '' or @location = '(null)'
					BEGIN
						SET @location = 'User location cannot be detected';
					END


					INSERT INTO [dbo].[wink_game_customer_result]
				   ([session_id]
				   ,[customer_id]
				   ,[campaign_id]
				   ,[option_id]
				   ,[ip_address]
				   ,[gps_location]
				   ,[point]
				   ,[winner]
				   ,[created_at]
				   ,[redemption_status])
					VALUES
				   (@session_id
				   ,@customer_id
				   ,@campaign_id
				   ,@option_id
				   ,@ip_address
				   ,@location
				   ,@points
				   ,@winner
				   ,@CURRENT_DATETIME
				   ,'0');


					IF(@@ROWCOUNT>0)
					BEGIN
						UPDATE wink_game_customer_log SET survey_complete_status = 1 
						WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id and session_id = @session_id;

						IF(@points > 0)
						BEGIN
							-- here to insert winkgo points.
							EXEC @return_value = [dbo].[WINK_GO_CUSTOMER_EARNED_POINTS]
							@customer_id = @customer_id,
							@campaign_id = @campaign_id,
							@points = @points
							IF(@return_value>0)
								BEGIN
									SELECT '1' as response_code, @msg as response_message, @session_id as session_id
									return
								END
						
							/*	
							IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
							BEGIN
								UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+@POINTS 
								WHERE CUSTOMER_ID =@CUSTOMER_ID;
								SELECT '1' as response_code, @msg as response_message, @session_id as session_id
								return
							END
							ELSE
							BEGIN
								INSERT INTO customer_balance 
								(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans)
								VALUES
								(@CUSTOMER_ID,@POINTS,0,0,0,0,0,0) ;

								IF(@@ROWCOUNT>0)
								BEGIN
									SELECT '1' as response_code, @msg as response_message, @session_id as session_id
									return
								END
							END
							*/
						
						END
						ELSE
						BEGIN
							SELECT '1' as response_code, @msg as response_message, @session_id as session_id
							return
						END
					
					END
					ELSE
					BEGIN
						SELECT '0' as response_code, 'Insertion failed' as response_message, @session_id as session_id
						return
					END

				END
				ELSE
				BEGIN
					SELECT '0' as response_code, 'Invalid option' as response_message, @session_id as session_id
					return
				END

	
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you! You have already participated for this round.' as response_message
				return
			END

		END
		
		
	END
	ELSE
	BEGIN
		IF(@campaign_id = 165)
		BEGIN
			SELECT '0' AS response_code, 'This game has already ended. Please enter a new game code.' as response_message
			return
		END
		ELSE IF(@campaign_id = 134)
		BEGIN
			SELECT '0' AS response_code, 'This game has already ended.' as response_message
			return
		END
	END


	
	
END
	




