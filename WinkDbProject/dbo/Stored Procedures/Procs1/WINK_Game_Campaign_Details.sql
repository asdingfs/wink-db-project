
CREATE PROC [dbo].[WINK_Game_Campaign_Details]
@campaign_id int,
@customer_id int,
@session_id int
AS
BEGIN
	DECLARE @CURRENT_DATE Date ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT 

	declare @count int
	
	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
		DECLARE @campaignType varchar(50)
		SELECT @campaignType = winktag_type FROM WINKTAG_CAMPAIGN where CAMPAIGN_ID = @campaign_id;

		IF (@campaignType = 'survey' or @campaignType = 'wink_city')
		BEGIN
			DECLARE @wid varchar(50);
			DECLARE @previousOpt int;
			DECLARE @characterNum int;
			DECLARE @hasWon int = 0;

			IF(@campaign_id = 165)
			BEGIN
				SELECT @count = COUNT(*) FROM wink_game_customer_result where campaign_id = @campaign_id and customer_id = @customer_id and cast(created_at as date) = @CURRENT_DATE;
			
				SET @wid = (SELECT wid from customer where customer_id = @customer_id);

				SET @previousOpt = (SELECT TOP(1) option_id from wink_game_customer_result where campaign_id = @campaign_id and customer_id = @customer_id and cast(created_at as date) = @CURRENT_DATE order by created_at desc);
				
				SELECT Top(1) @characterNum = [character] from wink_game_customer_log where campaign_id = @campaign_id and customer_id = @customer_id and cast(created_at as date) = @CURRENT_DATE  order by created_at desc;
				
				
				DECLARE @entryId int = 25;

				IF EXISTS(SELECT 1 from winners_points where entry_id = @entryId and customer_id = @customer_id and cast(created_at as date) = @CURRENT_DATE)
				BEGIN
					-- user has already won for today
					SET @hasWon = 1;
				END
				ELSE
				BEGIN
					
					DECLARE @dailyWinnerInventory int = 50;

					declare @noOfDays int
					SELECT @noOfDays = DATEDIFF(day, '2021-05-21', @CURRENT_DATE);
					print('day difference: ');
					print(@noOfDays);

					declare @pastWinnerCount int
					SELECT @pastWinnerCount = COUNT(*) 
					FROM winners_points 
					where entry_id = @entryId 
					AND cast(created_at as date) < @CURRENT_DATE;
				
				
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
							WHERE entry_id = @entryId and cast(created_at as date) = @CURRENT_DATE
						) 
						>= @maxWinnerCount
					)
					BEGIN
						-- inventory count for winners is exhausted for the day
						SET @hasWon = 1;
					END
				END

				SELECT C.campaign_id,Q.question_id,Q.question,A.option_id,A.option_answer,A.image_name,A.option_type, @count as attemptCount,
				CASE
					WHEN A.option_id in 
					(
						select r.option_id 
						from wink_game_customer_result as r 
						where r.campaign_id = @campaign_id 
						and r.customer_id = @customer_id 
						and cast(r.created_at as date) = @CURRENT_DATE
					) THEN '1'
					ELSE '0'
				END AS selected,
				@wid as wid,
				@previousOpt as previousOpt,
				@characterNum as [character],
				@hasWon as hasWon
				FROM winktag_campaign AS C 
				INNER JOIN winktag_survey_question AS Q 
					ON C.CAMPAIGN_ID = Q.CAMPAIGN_ID
				INNER JOIN winktag_survey_option AS A 
					ON Q.QUESTION_ID = A.QUESTION_ID 
					AND C.CAMPAIGN_ID = A.CAMPAIGN_ID
					AND A.[status] = '1'
				WHERE C.CAMPAIGN_ID = @campaign_id 
				ORDER BY question_id,option_id;

				return
			END
			ELSE IF(@campaign_id = 134)
			BEGIN
				SELECT @count = COUNT(*) FROM wink_game_customer_result where campaign_id = @campaign_id and session_id = @session_id and customer_id = @customer_id;
			
				SET @wid = (SELECT wid from customer where customer_id = @customer_id);
				SET @previousOpt = (SELECT TOP(1) option_id from wink_game_customer_result where campaign_id = @campaign_id and customer_id = @customer_id and session_id = @session_id order by created_at desc);
				SET @characterNum = (SELECT Top(1) [character] from wink_game_customer_log where campaign_id = @campaign_id and customer_id = @customer_id and session_id = @session_id);
			
				SELECT C.campaign_id,Q.question_id,Q.question,A.option_id,A.option_answer,A.image_name,A.option_type, @count as attemptCount,
				CASE
					WHEN A.option_id in (select r.option_id from wink_game_customer_result as r where r.campaign_id = @campaign_id and r.customer_id = @customer_id and r.session_id = @session_id) THEN '1'
					ELSE '0'
				END AS selected,
				@wid as wid,
				@previousOpt as previousOpt,
				@characterNum as [character]
				FROM winktag_campaign AS C 
				INNER JOIN winktag_survey_question AS Q 
					ON C.CAMPAIGN_ID = Q.CAMPAIGN_ID
				INNER JOIN winktag_survey_option AS A 
					ON Q.QUESTION_ID = A.QUESTION_ID 
					AND C.CAMPAIGN_ID = A.CAMPAIGN_ID
					AND A.[status] = '1'
				WHERE C.CAMPAIGN_ID = @campaign_id 
				ORDER BY question_id,option_id;

				return
			END
			
			
		END
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

END





