

CREATE PROC [dbo].[WINKTAG_CUSTOMER_EARNED_POINTS_DETAIL]
@customer_id int,
@campaign_id int,
@question_id int,
@location varchar(250),
@ip_address varchar(50)

AS
BEGIN
DECLARE @interval_status int
DECLARE @interval int
DECLARE @limit int
DECLARE @winktag_type varchar(50)
DECLARE	@survey_type varchar(50)
DECLARE @RETURN_NO VARCHAR(10) = '0'
DECLARE @POINTS int
DECLARE @MESSAGE VARCHAR(250)
DECLARE @POINTS_DESC VARCHAR(10) = ' points.'
DECLARE @POINTS_DESC_EURO VARCHAR(15) = ' points are'
DECLARE @row_count int = 0
DECLARE @campaign_type varchar(50)
DECLARE @campaign_start DATE
DECLARE @wp_wh_codes_id int

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

	--2)CHECK CAMPAIGN
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

	--3)CHECK CAMPAIGN Limit for all campaigns
	IF  @CAMPAIGN_ID = 167
	BEGIN
		IF (SELECT COUNT(*) FROM winktag_customer_survey_answer_detail WHERE CAMPAIGN_ID = @CAMPAIGN_ID and  option_answer like '%The Road Ahead%') >= (SELECT SIZE FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
		BEGIN
			SELECT '0' AS response_code, 'Campaign limit reach' as response_message
			return
		END
	END
	ELSE IF (SELECT COUNT(*) FROM winktag_customer_earned_points WHERE CAMPAIGN_ID = @CAMPAIGN_ID) >= (SELECT SIZE FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
	BEGIN
		SELECT '0' AS response_code, 'Campaign limit reach' as response_message
		return
	END
	

	--3)CHECKING WILL BE PROCEEDED BASED ON CAMPAIGN

	--3.0)EASB: CHECK AGE RANGE AND SIZE FOR NIELSEN
	IF (SELECT winktag_report FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id) = 'EASB'
	BEGIN
		DECLARE @age int
		--a)CHECK AGE RANGE
		set @age = (select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) from customer where customer_id =@customer_id)

		IF (@age < 18 OR @age > 35)
		BEGIN
			SELECT '0' AS response_code, 'Open to selected participants' as response_message
			return
		END

		--b)CHECK SIZE
		IF (SELECT COUNT(*) FROM winktag_customer_earned_points WHERE CAMPAIGN_ID = @CAMPAIGN_ID) >= (SELECT SIZE FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
		BEGIN
			IF(@campaign_id != 177)
			BEGIN
				SELECT '0' AS response_code, 'Campaign limit reach' as response_message
				return
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, we have reached the maximum number of votes.' as response_message
				return
			END
		END
	END

	--3.1)SMA2017: CHECK CUSTOMER SCANNED SMA QR CODE OR NOT FOR SMA2017 CAMPAIGN (those who scanned SMA QR code will only be allowed to participate in WINK Tag Survey)
	IF (SELECT winktag_report FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id) = 'SMA2017'
	BEGIN

		--a)CHECK CUSTOMER SCANNED SMA QR CODE OR NOT 
		IF NOT EXISTS(SELECT * FROM CUSTOMER_EARNED_POINTS WHERE QR_CODE = 'SMA_SMA_21_49653' AND CUSTOMER_ID = @CUSTOMER_ID)
		BEGIN
			SELECT '0' AS response_code, 'By invitation only' as response_message
			return
		END

	END

	--4)CHECK LIMIT
	SET @interval_status = (SELECT interval_status FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)

	IF @interval_status = 0 -- there is no interval
	BEGIN
		SET @limit = (SELECT limit FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
		SET @winktag_type = (SELECT winktag_type FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)

		IF @limit = 0
		BEGIN
			SET @RETURN_NO='1'-- success and give points
			GOTO NextStep
		END
		ELSE
		BEGIN
			IF @winktag_type = 'survey' OR @winktag_type = 'TripleA' OR @winktag_type = 'template_survey'
			BEGIN
				SET @survey_type = (SELECT survey_type FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
				IF @survey_type = 'all'
				BEGIN
					IF (SELECT COUNT(*) FROM winktag_customer_earned_points WHERE customer_id = @customer_id AND campaign_id=@campaign_id) < @limit
					BEGIN
						SET @RETURN_NO='1'-- success and give points
						GOTO NextStep
					END
					ELSE
					BEGIN
						--SELECT '0' AS response_code, 'Our records indicate that you have already participated in this survey.' as response_message

						IF (SELECT winktag_report FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id) = 'airshow2018'
							SELECT '0' AS response_code, 'You have already participated in this promotion.' as response_message
						ELSE
							SELECT '0' AS response_code, 'You have completed this survey.' as response_message

						return;
					END
				END
			END
		END
	END



	--######################Pass authentication process######################
	NextStep:
	IF @RETURN_NO = '1'
	BEGIN
		DECLARE @STLCnyCampaignId int = 175, 
		--@MBXMasCampaignId int = 174, 
		@TLMCFinaleCampaignId int = 173, @tlAprCodeCampaignId int = 160, @tlAprRefCampaignId int = 162, @tlAprWid varchar(50), @tlAprCusId int, @tlAprEmail varchar(200),
		@tlAprName varchar(220), @tlAprEntryId int = 22;


		--CAMPAIGN TYPE
		SET @campaign_type = (SELECT winktag_report FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
        --WINKhuntRewardCards--
		If (@question_id =0 AND @campaign_id =217)
		    Begin
			--1. retrieve promo from answer_detail table --
			Declare @txt_answer as varchar(50)
			set @txt_answer = (select answer from [winktag_customer_survey_answer_detail] 
			where campaign_id=@campaign_id and customer_id=@customer_id and question_id =720 order by created_at desc
			offset 0 rows
			fetch first 1 row only)

			print(@txt_answer)
			--2. retrieve points from TBL_WINKPLAY_WINKHUNT_CODES --
		  select @POINTS = wink_point_value, @wp_wh_codes_id =WP_WH_CODES_ID
		  from TBL_WINKPLAY_WINKHUNT_CODES
		  where promo_code = @txt_answer
		  and campaign_id=@campaign_id
          and used_status=0
            End
		ELSE IF (@question_id = 0)
			SET @POINTS = (SELECT points FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
		ELSE
			SET @POINTS = (SELECT points FROM winktag_survey_question WHERE campaign_id = @campaign_id AND question_id = @question_id)


		IF @POINTS <= 1
		BEGIN
			SET @POINTS_DESC = ' point.'
			SET @POINTS_DESC_EURO = ' point is'
		END

		IF @location is null or @location = '' or @location = '(null)'
			SET @location = 'User location cannot be detected'

		IF(@campaign_id = @STLCnyCampaignId)
		BEGIN
			
			DECLARE @STLCnyW1Start datetime = '2021-12-20 09:00:00.000';
			DECLARE @STLCnyW1End datetime = '2021-12-24 23:59:59.000';

			DECLARE @STLCnyW2Start datetime = '2021-12-27 09:00:00.000';
			DECLARE @STLCnyW2End datetime = '2021-12-31 23:59:59.000';

			DECLARE @STLCnyW3Start datetime = '2022-01-03 09:00:00.000';
			DECLARE @STLCnyW3End datetime = '2022-01-07 23:59:59.000';

			DECLARE @STLCnyW4Start datetime = '2022-01-10 09:00:00.000';
			DECLARE @STLCnyW4End datetime = '2022-01-14 23:59:59.000';

			IF(@CURRENT_DATETIME <= @STLCnyW4End)
			BEGIN
				DECLARE @stlCnyInventory12 int = 100;
				DECLARE @stlCnyInventory34 int = 150;
				DECLARE @msgInvExhausted varchar(150) = 'WINK+ points redemption limit met for the week';

				IF(@CURRENT_DATETIME BETWEEN @STLCnyW1Start AND @STLCnyW1End)
				BEGIN
					IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @STLCnyW1Start AND @STLCnyW1End)
						) >= @stlCnyInventory12
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhausted as response_message
						RETURN
					END
				END
				ELSE IF(@CURRENT_DATETIME BETWEEN @STLCnyW2Start AND @STLCnyW2End)
				BEGIN
					IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @STLCnyW2Start AND @STLCnyW2End)
						) >= @stlCnyInventory12
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhausted as response_message
						RETURN
					END
				END
				ELSE IF(@CURRENT_DATETIME BETWEEN @STLCnyW3Start AND @STLCnyW3End)
				BEGIN
					IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @STLCnyW3Start AND @STLCnyW3End)
						) >= @stlCnyInventory34
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhausted as response_message
						RETURN
					END
				END
				ELSE IF(@CURRENT_DATETIME BETWEEN @STLCnyW4Start AND @STLCnyW4End)
				BEGIN
					IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @STLCnyW4Start AND @STLCnyW4End)
						) >= @stlCnyInventory34
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhausted as response_message
						RETURN
					END
				END
				ELSE
				BEGIN
					SELECT '0' AS response_code, 'WINK+ points redemption valid only from Mon - Fri' as response_message
					RETURN
				END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, promotion has ended' as response_message
				RETURN;
			END
		END

		IF (@campaign_id = 187)
        BEGIN
			DECLARE @fromDate datetime = '2022-07-20 11:42:12.523';
			DECLARE @toDate datetime = '2022-07-27 11:47:17.110';
			IF(@CURRENT_DATETIME BETWEEN @fromDate AND @toDate)
			BEGIN
				DECLARE @SMRTAnniTestInventory int = 5000;
				DECLARE @msgInvExhaustedSMRTAnniTest varchar(150) = 'redemption limit met for the survey';
				IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @fromDate AND @toDate)
						) >= @SMRTAnniTestInventory
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhaustedSMRTAnniTest as response_message
						RETURN
					END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, promotion has ended' as response_message
				RETURN
			END
          END

		IF (@campaign_id = 189)
        BEGIN
			DECLARE @SMRT35thAnniPhase1fromDate datetime = '2022-09-13 09:00:00.000';
			DECLARE @SMRT35thAnniPhase1ToDate datetime = '2023-09-26 23:59:59.000';
			IF(@CURRENT_DATETIME BETWEEN @SMRT35thAnniPhase1fromDate AND @SMRT35thAnniPhase1ToDate)
			BEGIN
				DECLARE @SMRT35thAnniPhase1Inventory int = 25;
				DECLARE @msgInvExhaustedSMRT35thAnniPhase1 varchar(150) = 'You missed it! Check our socials to see when you can play!';
				IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @SMRT35thAnniPhase1fromDate AND @SMRT35thAnniPhase1ToDate)
						) >= @SMRT35thAnniPhase1Inventory
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhaustedSMRT35thAnniPhase1 as response_message
						RETURN
					END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
          END

		  IF (@campaign_id = 191)
        BEGIN
			DECLARE @SMRT35thAnniPhase2fromDate datetime = '2022-10-20 09:00:00.000';
			DECLARE @SMRT35thAnniPhase2ToDate datetime = '2023-11-03 23:59:59.000';
			IF(@CURRENT_DATETIME BETWEEN @SMRT35thAnniPhase2fromDate AND @SMRT35thAnniPhase2ToDate)
			BEGIN
				DECLARE @SMRT35thAnniPhase2Inventory int = 6500
				DECLARE @msgInvExhaustedSMRT35thAnniPhase2 varchar(150) = 'You missed it! Check our socials to see when you can play!';
				IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @SMRT35thAnniPhase2fromDate AND @SMRT35thAnniPhase2ToDate)
						) >= @SMRT35thAnniPhase2Inventory
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhaustedSMRT35thAnniPhase2 as response_message
						RETURN
					END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
          END
		  --SMRT35thAnniversaryPhase3--
		    IF (@campaign_id = 194)
        BEGIN
			DECLARE @SMRT35thAnniPhase3fromDate datetime = '2022-11-10 09:00:00.000';
			DECLARE @SMRT35thAnniPhase3ToDate datetime = '2023-11-10 23:59:59.000';
			IF(@CURRENT_DATETIME BETWEEN @SMRT35thAnniPhase3fromDate AND @SMRT35thAnniPhase3ToDate)
			BEGIN
				DECLARE @SMRT35thAnniPhase3Inventory int = 6500
				DECLARE @msgInvExhaustedSMRT35thAnniPhase3 varchar(150) = 'You missed it! Check our socials to see when you can play!';
				IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @SMRT35thAnniPhase3fromDate AND @SMRT35thAnniPhase3ToDate)
						) >= @SMRT35thAnniPhase3Inventory
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhaustedSMRT35thAnniPhase3 as response_message
						RETURN
					END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
          END
		    --SMRT35thAnniversaryPhase4--
		    IF (@campaign_id = 198)
        BEGIN
			DECLARE @SMRT35thAnniPhase4fromDate datetime = '2022-11-29 09:00:00.000';
			DECLARE @SMRT35thAnniPhase4ToDate datetime = '2023-12-18 23:59:59.000';
			IF(@CURRENT_DATETIME BETWEEN @SMRT35thAnniPhase4fromDate AND @SMRT35thAnniPhase4ToDate)
			BEGIN
				DECLARE @SMRT35thAnniPhase4Inventory int = 6500
				DECLARE @msgInvExhaustedSMRT35thAnniPhase4 varchar(150) = 'You missed it! Check our socials to see when you can play!';
				IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @SMRT35thAnniPhase4fromDate AND @SMRT35thAnniPhase4ToDate)
						) >= @SMRT35thAnniPhase4Inventory
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhaustedSMRT35thAnniPhase4 as response_message
						RETURN
					END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
          END

		   --SMRT35thAnniversaryPhase5--
		    IF (@campaign_id = 199)
        BEGIN
			DECLARE @SMRT35thAnniPhase5fromDate datetime = '2022-12-09 09:00:00.000';
			DECLARE @SMRT35thAnniPhase5ToDate datetime = '2024-01-02 23:59:59.000';
			IF(@CURRENT_DATETIME BETWEEN @SMRT35thAnniPhase5fromDate AND @SMRT35thAnniPhase5ToDate)
			BEGIN
				DECLARE @SMRT35thAnniPhase5Inventory int = 7000
				DECLARE @msgInvExhaustedSMRT35thAnniPhase5 varchar(150) = 'You missed it! Check our socials to see when you can play!';
				IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @SMRT35thAnniPhase5fromDate AND @SMRT35thAnniPhase5ToDate)
						) >= @SMRT35thAnniPhase5Inventory
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhaustedSMRT35thAnniPhase5 as response_message
						RETURN
					END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
          END

		 --SMRT35thAnniversaryPhase6--
		    IF (@campaign_id = 200)
        BEGIN
			DECLARE @SMRT35thAnniPhase6fromDate datetime = '2022-12-28 09:00:00.000';
			DECLARE @SMRT35thAnniPhase6ToDate datetime = '2024-01-15 23:59:59.000';
			IF(@CURRENT_DATETIME BETWEEN @SMRT35thAnniPhase6fromDate AND @SMRT35thAnniPhase6ToDate)
			BEGIN
				DECLARE @SMRT35thAnniPhase6Inventory int = 6000
				DECLARE @msgInvExhaustedSMRT35thAnniPhase6 varchar(150) = 'You missed it! Check our socials to see when you can play!';
				IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @SMRT35thAnniPhase6fromDate AND @SMRT35thAnniPhase6ToDate)
						) >= @SMRT35thAnniPhase6Inventory
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhaustedSMRT35thAnniPhase6 as response_message
						RETURN
					END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
          END

		--SMRT35thAnniversaryPhase7--
		    IF (@campaign_id = 201)
        BEGIN
			DECLARE @SMRT35thAnniPhase7fromDate datetime = '2022-01-04 09:00:00.000';
			DECLARE @SMRT35thAnniPhase7ToDate datetime = '2024-01-04 23:59:59.000';
			IF(@CURRENT_DATETIME BETWEEN @SMRT35thAnniPhase7fromDate AND @SMRT35thAnniPhase7ToDate)
			BEGIN
				DECLARE @SMRT35thAnniPhase7Inventory int = 6500
				DECLARE @msgInvExhaustedSMRT35thAnniPhase7 varchar(150) = 'You missed it! Check our socials to see when you can play!';
				IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @SMRT35thAnniPhase7fromDate AND @SMRT35thAnniPhase7ToDate)
						) >= @SMRT35thAnniPhase7Inventory
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhaustedSMRT35thAnniPhase7 as response_message
						RETURN
					END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
          END

		   --GreenLiving--
		    IF (@campaign_id = 197)
        BEGIN
			DECLARE @GreenLivingfromDate datetime = '2022-11-16 08:30:00.000';
			DECLARE @GreenLivingToDate datetime = '2023-11-16 09:01:57.927';
			IF(@CURRENT_DATETIME BETWEEN @GreenLivingfromDate AND @GreenLivingToDate)
			BEGIN
				DECLARE @GreenLivingInventory int = 500
				DECLARE @msgInvExhaustedGreenLiving varchar(150) = 'Check our social media pages to see when you can play again!';
				IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @GreenLivingfromDate AND @GreenLivingToDate)
						) >= @GreenLivingInventory
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhaustedGreenLiving as response_message
						RETURN
					END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
          END

		-- Client Satisfaction 2023
		ELSE IF(@campaign_id = 193)
		BEGIN
		DECLARE @ClientSat2023fromDate datetime = '2022-11-07 09:00:00.000';
		DECLARE @ClientSat2023ToDate datetime = '2023-11-07 23:59:59.000';
		IF(@CURRENT_DATETIME BETWEEN @ClientSat2023fromDate AND @ClientSat2023ToDate)
		BEGIN
			DECLARE @ClientSat2023Inventory int = 100;
			DECLARE @msgInvExhaustedClientSat2023 varchar(150) = 'redemption limit met for the survey';
			IF(
					(
						SELECT COUNT(1)
						FROM winktag_customer_earned_points
						WHERE campaign_id = @campaign_id
						AND (created_at BETWEEN @ClientSat2023fromDate AND @ClientSat2023ToDate)
					) >= @ClientSat2023Inventory
				)
				BEGIN
					SELECT '0' AS response_code, @msgInvExhaustedClientSat2023 as response_message
					RETURN
				END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
			RETURN
		END
        END
			
        --BusShelterTender--
		    IF (@campaign_id = 204)
        BEGIN
			DECLARE @BusShelterTenderfromDate datetime = '2023-04-14 09:15:00.000';
			DECLARE @BusShelterTenderToDate datetime = '2023-05-12 23:59:59.000';
			IF(@CURRENT_DATETIME BETWEEN @BusShelterTenderfromDate AND @BusShelterTenderToDate)
			BEGIN
				DECLARE @BusShelterTenderInventory int = 500
				DECLARE @msgInvExhaustedBusShelterTender varchar(150) = 'Check our social media pages to see when you can play again!';
				IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @BusShelterTenderfromDate AND @BusShelterTenderToDate)
						) >= @BusShelterTenderInventory
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhaustedBusShelterTender as response_message
						RETURN
					END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
          END

          --TownHallHiveSurvey2023--
		    IF (@campaign_id = 208)
        BEGIN
			DECLARE @TownHallHiveSurvey2023fromDate datetime = '2023-06-20 09:00:00.000';
			DECLARE @TownHallHiveSurvey2023ToDate datetime = '2023-07-20 23:59:59.000';
			IF(@CURRENT_DATETIME BETWEEN @TownHallHiveSurvey2023fromDate AND @TownHallHiveSurvey2023ToDate)
			BEGIN
				DECLARE @TownHallHiveSurvey2023Inventory int = 135
				DECLARE @msgInvExhaustedTownHallHiveSurvey2023 varchar(150) = 'Check our social media pages to see when you can play again!';
				IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @TownHallHiveSurvey2023fromDate AND @TownHallHiveSurvey2023ToDate)
						) >= @TownHallHiveSurvey2023Inventory
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhaustedTownHallHiveSurvey2023 as response_message
						RETURN
					END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END

            --TownHall2023MarsilingStaytion--
            IF (@campaign_id = 210)
                    BEGIN
                        DECLARE @TownHall2023MarsilingStaytionfromDate datetime = '2023-06-21 17:10:00.000';
                        DECLARE @TownHall2023MarsilingStaytionToDate datetime = '2023-06-23 18:00:00.000';
                        IF(@CURRENT_DATETIME BETWEEN @TownHall2023MarsilingStaytionfromDate AND @TownHall2023MarsilingStaytionToDate)
                        BEGIN
                            DECLARE @TownHall2023MarsilingStaytionInventory int = 135
                            DECLARE @msgInvExhaustedTownHall2023MarsilingStaytion varchar(150) = 'Check our social media pages to see when you can play again!';
                            IF(
                                    (
                                        SELECT COUNT(1)
                            FROM winktag_customer_earned_points
                            WHERE campaign_id = @campaign_id
                                AND (created_at BETWEEN @TownHall2023MarsilingStaytionfromDate AND @TownHall2023MarsilingStaytionToDate)
                                    ) >= @TownHall2023MarsilingStaytionInventory
                                )
                                BEGIN
                                SELECT '0' AS response_code, @msgInvExhaustedTownHall2023MarsilingStaytion as response_message
                                RETURN
                            END
                        END
                        ELSE
                        BEGIN
                    SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
                    RETURN
                END
            END
          END

 		 --WinkHuntSurveyP1Campaign--	  
		    IF (@campaign_id = 215)
        BEGIN
			DECLARE @WinkHuntSurveyP1CampaignfromDate datetime = '2023-09-06 08:30:00.000';
			DECLARE @WinkHuntSurveyP1CampaignToDate datetime = '2023-09-30 23:59:59.000';
			IF(@CURRENT_DATETIME BETWEEN @WinkHuntSurveyP1CampaignfromDate AND @WinkHuntSurveyP1CampaignToDate)
			BEGIN
				DECLARE @WinkHuntSurveyP1CampaignInventory int = 5000
				DECLARE @msgInvExhaustedWinkHuntSurveyP1Campaign varchar(150) = 'Oops! You just missed out! Stay tuned for more promotions!';
				IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @WinkHuntSurveyP1CampaignfromDate AND @WinkHuntSurveyP1CampaignToDate)
						) >= @WinkHuntSurveyP1CampaignInventory
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhaustedWinkHuntSurveyP1Campaign as response_message
						RETURN
					END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
        END         

		 --WinkHuntSurveyP2Campaign--	  
		    IF (@campaign_id = 218)
        BEGIN
			DECLARE @WinkHuntSurveyP2CampaignfromDate datetime = '2023-09-20 09:00:00.000';
			DECLARE @WinkHuntSurveyP2CampaignToDate datetime = '2023-10-03 23:59:59.000';
			IF(@CURRENT_DATETIME BETWEEN @WinkHuntSurveyP2CampaignfromDate AND @WinkHuntSurveyP2CampaignToDate)
			BEGIN
				DECLARE @WinkHuntSurveyP2CampaignInventory int = 10
				DECLARE @msgInvExhaustedWinkHuntSurveyP2Campaign varchar(150) = 'Oops! You just missed out! Stay tuned for more promotions!';
				IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @WinkHuntSurveyP2CampaignfromDate AND @WinkHuntSurveyP2CampaignToDate)
						) >= @WinkHuntSurveyP2CampaignInventory
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhaustedWinkHuntSurveyP2Campaign as response_message
						RETURN
					END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
        END      
		--WinkHuntRewardCards--
		IF (@campaign_id = 217)
        BEGIN
			DECLARE @WinkhuntRewardfromDate datetime = '2023-09-12 09:00:00.000';
			DECLARE @WinkhuntRewardToDate datetime = '2023-09-30 23:59:59.000';
			IF(@CURRENT_DATETIME BETWEEN @WinkhuntRewardfromDate AND @WinkhuntRewardToDate)
			BEGIN
				DECLARE @WinkhuntRewardInventory int = 100
				DECLARE @msgInvExhaustedWinkhuntReward varchar(150) = 'Oops! You just missed out! Stay tuned for more promotions!';
				IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @WinkhuntRewardfromDate AND @WinkhuntRewardToDate)
						) >= @WinkhuntRewardInventory
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhaustedWinkhuntReward as response_message
						RETURN
					END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, campaign has ended' as response_message
				RETURN
			END
          END
		--ELSE IF(@campaign_id = @MBXMasCampaignId)
		--BEGIN
		--	SET @POINTS = 0;
		--	DECLARE @totalPtsInventory int = 168000;
		--	DECLARE @campaignStart datetime = '2021-11-25 05:30:00.000';
		--	DECLARE @campaignEnd datetime = '2021-12-31 23:59:59.000';
		--	IF(@CURRENT_DATETIME BETWEEN @campaignStart AND @campaignEnd)
		--	BEGIN
		--		DECLARE @totalIssuedPts int = 0;

		--		select @totalIssuedPts= ISNULL(SUM(points),0)
		--		from (
		--			SELECT points FROM customer_earned_points 
		--			WHERE (qr_code like 'MBXMAS%' AND qr_code not like 'MBXMAS_WINK%')

		--			UNION ALL

		--			SELECT points FROM winktag_customer_earned_points
		--			WHERE campaign_id = @campaign_id
		--		) as issuedPts;

		--		print('total points issued');
		--		print(@totalIssuedPts);
		--		IF(@totalPtsInventory > @totalIssuedPts)
		--		BEGIN
		--			declare @luckyNum int
		--			SELECT @luckyNum = ROUND(((10 - 1 -1) * RAND() + 1), 0)
		--			print('lucky number: ');
		--			print(@luckyNum);

		--			IF(@luckyNum > 2)
		--			BEGIN
		--				SET @POINTS = 5;
		--				print('won 5 points');
		--			END
		--			ELSE
		--			BEGIN
		--				SET @POINTS = 20;
		--				print('won 20 points');
		--			END
		--		END
		--		ELSE
		--		BEGIN
		--			SELECT '0' AS response_code, 'Oh no! We have run out of points. Better luck next time!.' as response_message
		--			RETURN;
		--		END
		--	END
		--	ELSE
		--	BEGIN
		--		SELECT '0' AS response_code, 'The campaign has ended.' as response_message
		--		RETURN;
		--	END
		--END
		ELSE IF(@campaign_id = @tlAprCodeCampaignId or @campaign_id = @tlAprRefCampaignId or @campaign_id = 156)
		BEGIN
			IF(@campaign_id = @tlAprRefCampaignId)
			BEGIN
				DECLARE @referralCode varchar(12);

				SELECT @referralCode = answer
				FROM winktag_customer_survey_answer_detail
				WHERE customer_id = @customer_id
				AND campaign_id = @campaign_id;

				SELECT @tlAprWid = c.WID, @tlAprCusId = c.customer_id, @tlAprEmail = c.email, @tlAprName = c.first_name+' '+ c.last_name
				FROM customer as c
				WHERE c.customer_id = 
				( 
					SELECT w. customer_id
					FROM winktag_customer_survey_answer_detail as w
					WHERE campaign_id = @tlAprCodeCampaignId
					AND answer like (SUBSTRING(@referralCode, 1, 6))
					AND w.customer_id = c.customer_id
				);

				IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@tlAprCusId)
				BEGIN
					UPDATE customer_balance 
					SET TOTAL_POINTS = TOTAL_POINTS + @POINTS 
					WHERE CUSTOMER_ID =@tlAprCusId;
				END
				ELSE
				BEGIN
					INSERT INTO customer_balance 
					(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans,total_redeemed_amt)
					VALUES
					(@tlAprCusId,@POINTS,0,0,0,0,0,0,0.00) 
				END

				INSERT INTO [dbo].[wink_thirdparty_referral]
					   ([campaignId]
					   ,[refereeCid]
					   ,[refereePts]
					   ,[location]
					   ,[ip]
					   ,[referralCode]
					   ,[referrerWid]
					   ,[referrerCid]
					   ,[referrerName]
					   ,[referrerEmail]
					   ,[referrerPts]
					   ,[createdOn])
				 VALUES
					   (@tlAprRefCampaignId
					   ,@customer_id
					   ,@points
					   ,@location
					   ,@ip_address
					   ,@referralCode
					   ,@tlAprWid
					   ,@tlAprCusId
					   ,@tlAprName
					   ,@tlAprEmail
					   ,@POINTS
					   ,@CURRENT_DATETIME);
				-- add into winner points, so that the points earned thru referral will be reflected in 
				--customers report
				INSERT INTO [dbo].[winners_points]
					   ([entry_id]
					   ,[customer_id]
					   ,[points]
					   ,[location]
					   ,[created_at])
				 VALUES
					   (@tlAprEntryId
					   ,@tlAprCusId
					   ,@POINTS
					   ,''
					   ,@CURRENT_DATETIME);
				
			END
			ELSE IF(@campaign_id = 156)
			BEGIN
				INSERT INTO [dbo].[spg_earned_points]
					   ([card_type]
					   ,[bank]
					   ,[business_date]
					   ,[total_tabs]
					   ,[total_points]
					   ,[created_at]
					   ,[source]
					   ,[customer_id])
				 VALUES
					   (0
					   ,0
					   ,@CURRENT_DATETIME
					   ,0
					   ,@POINTS
					   ,@CURRENT_DATETIME
					   ,'SPG'
					   ,@customer_id);
			END
			
			IF(
				(SELECT group_id FROM customer WHERE customer_id= @customer_id) 
				not like '2'
			)
			BEGIN
				UPDATE customer
				SET group_id = '2'
				WHERE customer_id= @customer_id;
			END
		END
		ELSE IF(@campaign_id = 141)
		BEGIN
			--CNY 2020 points giveaway
			SET @POINTS = 
			(SELECT answer from winktag_customer_survey_answer_detail where customer_id = @customer_id and campaign_id = @campaign_id
			 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date));

		END 
		ELSE IF(@campaign_id = 111)
		BEGIN
			--for WINK+ Champs new users
			DECLARE @registration datetime
			SELECT @registration = created_at from customer where customer_id = @customer_id;
			IF(@registration BETWEEN '2019-07-10 08:00:00.000' AND '2019-07-16 23:59:59.000')
			BEGIN
				SET @POINTS = 100;
			END
		END
		ELSE IF(@campaign_id = 151)
		BEGIN
			--for WINK+ Referral Program new users
			DECLARE @referrerPoints int = 10;
			DECLARE @referrerCID int;
			SELECT @referrerCID = customer_id FROM customer
			WHERE WID like 
			(SELECT answer
			FROM winktag_customer_survey_answer_detail
			WHERE customer_id = @customer_id
			AND campaign_id = @campaign_id
			);
			INSERT INTO [dbo].[winners_points]
				([entry_id]
				,[customer_id]
				,[points]
				,[location]
				,[created_at])
			VALUES
				(11
				,@referrerCID
				,@referrerPoints
				,''
				,@CURRENT_DATETIME);
			IF @@ROWCOUNT > 0
			BEGIN
				UPDATE CUSTOMER_BALANCE 
				SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@referrerCID)+@referrerPoints 
				WHERE CUSTOMER_ID =@referrerCID;
			END

		END

		IF(@campaign_id = 157)
			SET @row_count = (SELECT COUNT(*) FROM winktag_customer_survey_answer_detail WHERE campaign_id = @campaign_id AND customer_id = @customer_id)
		ELSE
			SET @row_count = (SELECT COUNT(*) FROM winktag_customer_earned_points WHERE campaign_id = @campaign_id AND customer_id = @customer_id)+1
		
		INSERT INTO [winktag_customer_earned_points]
           ([campaign_id]
           ,[question_id]
           ,[customer_id]
           ,[points]
           ,[GPS_location]
           ,[ip_address]
           ,[created_at]
		   ,[row_count])
		VALUES
           (@campaign_id,@question_id,@customer_id,@POINTS,@location,@ip_address,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@row_count)

		

		IF @@ROWCOUNT > 0
		BEGIN
			
			--5)CHECK CAMPAIGN LIMIT REACH OR NOT
			IF @CAMPAIGN_ID = 167
			BEGIN
				IF (SELECT COUNT(*) FROM winktag_customer_survey_answer_detail WHERE CAMPAIGN_ID = @CAMPAIGN_ID  and option_answer like '%The Road Ahead%') >= (SELECT SIZE FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
					UPDATE winktag_campaign SET winktag_status = 0 WHERE CAMPAIGN_ID = @campaign_id;
			END
			ELSE IF (SELECT COUNT(*) FROM winktag_customer_earned_points WHERE CAMPAIGN_ID = @CAMPAIGN_ID) >= (SELECT SIZE FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
			BEGIN
				UPDATE winktag_campaign SET winktag_status = 0 WHERE CAMPAIGN_ID = @campaign_id;

				IF(@campaign_id = 151)
				BEGIN
					UPDATE winktag_campaign SET winktag_status = 0 WHERE CAMPAIGN_ID = 152;
				END
			END
			

			-- GET CAMPAIGN START AND END DATES
			SET @campaign_start = (SELECT CAST(from_date AS DATE) FROM winktag_campaign WHERE campaign_id = @campaign_id)
			IF @campaign_start IS NULL OR @campaign_start = ''
				SET @campaign_start = CAST(DATEADD(HOUR,8,GETDATE()) as DATE)

			IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
			BEGIN
				UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+@POINTS 
				WHERE CUSTOMER_ID =@CUSTOMER_ID

				IF(@campaign_id = 146 )
				BEGIN
					EXEC [dbo].[WINK_GO_CUSTOMER_EARNED_POINTS]
					@customer_id = @customer_id,
					@campaign_id = @campaign_id
				END
				ELSE IF(@campaign_id = 141 or @campaign_id = 138 or @campaign_id = 137 or @campaign_id = 136  or @campaign_id=146)
				BEGIN
					--UPDATE winktag_customer_action_log SET survey_complete_status = 1 
					--WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id AND CAST(created_at AS DATE) >= @campaign_start;

					-- For thematic campaigns
					UPDATE winktag_customer_action_log SET survey_complete_status = 1 
					WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date);
				END
				ELSE IF(@campaign_id = 110)
				BEGIN
					-- For scratch card campaigns
					UPDATE [winktag_customer_earned_points]
					set additional_point_status = 1
					where customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date);
				END
				--WinkHuntRewardCards--
				ELSE IF (@campaign_id =217)
				BEGIN
				 --update status in promo code table--
				 Update TBL_WINKPLAY_WINKHUNT_CODES set used_status =1, updated_on=@CURRENT_DATETIME
				 WHERE wp_wh_codes_id =@wp_wh_codes_id and used_status =0

				 --update customer_action_log--
				 UPDATE winktag_customer_action_log SET survey_complete_status = 1 
					WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id

					print('update status')
				END

				ELSE
				BEGIN
					UPDATE winktag_customer_action_log SET survey_complete_status = 1 
					WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id;
				END

				
				IF @campaign_type = 'InternalRefReport'
				BEGIN
					SET @MESSAGE = 'Thank you for your participation!<br>You have earned 200 WINK<sup>+</sup> Points!';
				END
				ELSE IF @campaign_type = 'InternalAcqReport'
				BEGIN
					SET @MESSAGE = 'Thank you for your participation!<br>You have earned 300 WINK<sup>+</sup> Points!';
				END
				ELSE IF @campaign_type = 'Townhall2022Report'
				BEGIN
					SET @MESSAGE = 'Thank you for your participation!<br>You have earned 50 WINK<sup>+</sup> Points!';
				END
				ELSE IF @campaign_type like 'QuestionnaireReport%'
				BEGIN
					SET @MESSAGE = 'Thank you for participating!! You have earned 10 WINK<sup>+</sup> points!';
				END
				ELSE IF @campaign_type = 'TE2Report'
				BEGIN
					SET @MESSAGE = 'Thank you for your participation! You have earned 10 WINK<sup>+</sup> points and also stand a chance to win 10,000 WINK<sup>+</sup> points (worth $100)!';
				END
				ELSE IF @campaign_type = 'TLMCFinaleReport'
				BEGIN
					SET @MESSAGE = 'HOORAY! You have earned yourself a whopping 800 points!';
				END
				ELSE IF @campaign_type = 'STLCNY2022Report'
				BEGIN
					SET @MESSAGE = 'Congratulations! 388 WINK<sup>+</sup> points have been credited to your account';
				END
				ELSE IF @campaign_type = 'SMRTAnniversaryTestReport'
                BEGIN
                    SET @MESSAGE = 'Thank you for your participation';
                END
				ELSE IF @campaign_type = 'SMRT35thAnniversaryPhase1Report' or @campaign_type = 'SMRT35thAnniversaryPhase2Report' or @campaign_type = 'SMRT35thAnniversaryPhase3Report' or @campaign_type = 'SMRT35thAnniversaryPhase4Report' or @campaign_type = 'SMRT35thAnniversaryPhase5Report' or @campaign_type = 'SMRT35thAnniversaryPhase6Report' or @campaign_type = 'SMRT35thAnniversaryPhase7Report'
                BEGIN
                   SET @MESSAGE = 'YAY! You have earned 7 WINK+ Points and qualified for the draw!';
                END
				ELSE IF @campaign_type = 'GreenLivingReport'
                BEGIN
                    SET @MESSAGE = 'Yay! You have earned 20 WINK+ points!';
                END
                ELSE IF @campaign_type = 'BusShelterTenderReport'
                BEGIN
                    SET @MESSAGE = 'Thank you for doing our survey! Stay tuned for more!';
                END
                ELSE IF @campaign_type = 'TownHallHiveSurvey2023Report' or @campaign_type = 'TownHall2023MarsilingStaytionReport'
                BEGIN
                    SET @MESSAGE = 'Yay! You have earned 50 WINK+ points!';
                END
                ELSE IF @campaign_type = 'WinkHuntSurveyP1Report' or @campaign_type = 'WinkHuntSurveyPhase2Report'
                BEGIN
                    SET @MESSAGE = 'Check your email for your WINK Hunt game card promo code!';
                END
			    ELSE IF @campaign_type = 'WINKHuntRewardCardsReport'
                BEGIN
                    SET @MESSAGE = 'YAY! You can now use your points to get more game cards!';
                END
				--ELSE IF @campaign_type = 'MyBestXmasReport'
				--BEGIN
				--	IF(@POINTS = 5)
				--	BEGIN
				--		SET @MESSAGE = 'HO! HO! HO! You''ve won 5 points!';
				--	END
				--	ELSE IF(@POINTS = 20)
				--	BEGIN
				--		SET @MESSAGE = 'HO! HO! HO! You''ve won 20 points! You are a BIG WINNER!';
				--	END
				--END
				ELSE IF @campaign_type = 'euro_group_2017'
					SET @MESSAGE =  CONVERT(varchar(10), @POINTS)+' WINK<sup>+</sup>' + @POINTS_DESC_EURO + ' now in your cart! Click OK to continue to be rewarded <br/>(Beauty Vouchers, extra WINK<sup>+</sup> points, and more!)' 
				ELSE IF @campaign_type = 'SMA2017'
					SET @MESSAGE = 'Congrats! Collect your bathtime treat from the WINK<sup>+</sup> tub!'
				ELSE IF @campaign_type = 'HOF2017'
					SET @MESSAGE = 'Head to the golf simulator for a swing!'
				ELSE IF @campaign_type = 'airshow2018'
					SET @MESSAGE = 'Thank you for participating. Winners will be notified via email with prize collection details.'
				ELSE IF  @campaign_type = 'Beijing_101Report'
					SET @MESSAGE = 'Congratulations!<br>You have earned ' + CONVERT(varchar(10), @POINTS)+' WINK<sup>+</sup> points  and a pair of movie tickets (T & Cs apply).<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.'
				ELSE IF  @campaign_type = 'WFHReport'
				SET @MESSAGE = '<br>Go to Account > WINK<sup>+</sup> Go to claim your 5 WINK+ points or it will expire in 24 hours. <br><br>Participate daily from 23 April to 1 June.<br><br>Once you click OK, you will be redirected to our Facebook page.'
		
				ELSE IF @campaign_type = 'NLBxWINKReport'
					SET @MESSAGE = 'You have earned ' + CONVERT(varchar(10), @POINTS)+ ' points'
				ELSE
					SET @MESSAGE = 'Congratulations!<br>You have earned ' + CONVERT(varchar(10), @POINTS)+@POINTS_DESC


				IF(@campaign_id = @tlAprRefCampaignId)
				BEGIN
					SELECT '1' AS response_code, @MESSAGE as response_message, @tlAprEmail as tlCusEmail, @tlAprName as tlCusName;
					return;
				END
				ELSE
				BEGIN
					SELECT '1' AS response_code, @MESSAGE as response_message
					return;
				END
				
			END
			ELSE
			BEGIN
				INSERT INTO customer_balance 
					(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans,total_redeemed_amt)
					VALUES
					(@CUSTOMER_ID,@POINTS,0,0,0,0,0,0,0.00) 
				IF(@@ROWCOUNT>0)
				BEGIN
					
					IF (@campaign_id = 146 )
					BEGIN
						EXEC [dbo].[WINK_GO_CUSTOMER_EARNED_POINTS]
						@customer_id = @customer_id,
						@campaign_id = @campaign_id
					END
					ELSE IF(@campaign_id = 141 or @campaign_id = 138 or @campaign_id = 137 or @campaign_id = 136  or @campaign_id=146)
					BEGIN
						--UPDATE winktag_customer_action_log SET survey_complete_status = 1 
						--WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id AND CAST(created_at AS DATE) >= @campaign_start;

						-- For thematic campaigns
						UPDATE winktag_customer_action_log SET survey_complete_status = 1 
						WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date);
					END
					ELSE IF(@campaign_id = 110)
					BEGIN
						-- For scratch card campaigns
						UPDATE [winktag_customer_earned_points]
						set additional_point_status = 1
						where customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date);
					END
					--WinkHuntRewardCards--
					ELSE IF (@campaign_id =217)
					BEGIN
					 --update status in promo code table--
					 Update TBL_WINKPLAY_WINKHUNT_CODES set used_status =1, updated_on=@CURRENT_DATETIME
					 WHERE wp_wh_codes_id =@wp_wh_codes_id and used_status =0

					 --update customer_action_log--
					 UPDATE winktag_customer_action_log SET survey_complete_status = 1 
						WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id
						print('update status1')
					END
					ELSE
					BEGIN
						UPDATE winktag_customer_action_log SET survey_complete_status = 1 
						WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id;
					END

					IF @campaign_type = 'InternalRefReport'
					BEGIN
						SET @MESSAGE = 'Thank you for your participation!<br>You have earned 200 WINK<sup>+</sup> Points!';
					END
					ELSE IF @campaign_type = 'InternalAcqReport'
					BEGIN
						SET @MESSAGE = 'Thank you for your participation!<br>You have earned 300 WINK<sup>+</sup> Points!';
					END
					ELSE IF @campaign_type = 'Townhall2022Report'
					BEGIN
						SET @MESSAGE = 'Thank you for your participation!<br>You have earned 50 WINK<sup>+</sup> Points!';
					END
					ELSE IF @campaign_type like 'QuestionnaireReport%'
					BEGIN
						SET @MESSAGE = 'Thank you for participating!! You have earned 10 WINK<sup>+</sup> points!';
					END
					ELSE IF @campaign_type = 'TE2Report'
					BEGIN
						SET @MESSAGE = 'Thank you for your participation! You have earned 10 WINK<sup>+</sup> points and also stand a chance to win 10,000 WINK<sup>+</sup> points (worth $100)!';
					END
					ELSE IF @campaign_type = 'TLMCFinaleReport'
					BEGIN
						SET @MESSAGE = 'HOORAY! You have earned yourself a whopping 800 points!';
					END
					ELSE IF @campaign_type = 'STLCNY2022Report'
					BEGIN
						SET @MESSAGE = 'Congratulations! 388 WINK<sup>+</sup> points have been credited to your account';
					END
				    ELSE IF @campaign_type = 'SMRTAnniversaryTestReport'
                    BEGIN
                        SET @MESSAGE = 'Thank you for your participation';
                    END
					ELSE IF @campaign_type = 'SMRT35thAnniversaryPhase1Report' or @campaign_type = 'SMRT35thAnniversaryPhase2Report' or @campaign_type = 'SMRT35thAnniversaryPhase3Report' or @campaign_type = 'SMRT35thAnniversaryPhase4Report' or @campaign_type = 'SMRT35thAnniversaryPhase5Report' or @campaign_type = 'SMRT35thAnniversaryPhase6Report' or @campaign_type = 'SMRT35thAnniversaryPhase7Report'
                    BEGIN
                        SET @MESSAGE = 'YAY! You have earned 7 WINK+ Points and qualified for the draw!';
                    END
					ELSE IF @campaign_type = 'GreenLivingReport'
					 BEGIN
                    SET @MESSAGE = 'Yay! You have earned 20 WINK+ points!';
					 END
					ELSE IF @campaign_type = 'BusShelterTenderReport'
					 BEGIN
                    SET @MESSAGE = 'Thank you for doing our survey! Stay tuned for more!';
					 END
                     ELSE IF @campaign_type = 'TownHallHiveSurvey2023Report' or @campaign_type = 'TownHall2023MarsilingStaytionReport'
					 BEGIN
                    SET @MESSAGE = 'Yay! You have earned 50 WINK+ points!';
					 END
                     ELSE IF @campaign_type = 'WinkHuntSurveyP1Report' or @campaign_type = 'WinkHuntSurveyPhase2Report'
                     BEGIN
                    SET @MESSAGE = 'Check your email for your WINK Hunt game card promo code!';
                     END
					 ELSE IF @campaign_type = 'WINKHuntRewardCardsReport'
                     BEGIN
                     SET @MESSAGE = 'YAY! You can now use your points to get more game cards!';
                     END
					--ELSE IF @campaign_type = 'MyBestXmasReport'
					--BEGIN
					--	IF(@POINTS = 5)
					--	BEGIN
					--		SET @MESSAGE = 'HO! HO! HO! You''ve won 5 points!';
					--	END
					--	ELSE IF(@POINTS = 20)
					--	BEGIN
					--		SET @MESSAGE = 'HO! HO! HO! You''ve won 20 points! You are a BIG WINNER!';
					--	END
					--END
					ELSE IF @campaign_type = 'euro_group_2017'
						SET @MESSAGE =  CONVERT(varchar(10), @POINTS)+' WINK<sup>+</sup>' + @POINTS_DESC_EURO + ' now in your cart! Click OK to continue to be rewarded <br/>(Beauty Vouchers, extra WINK<sup>+</sup> points, and more!)' 
					ELSE IF @campaign_type = 'SMA2017'
						SET @MESSAGE = 'Congrats! Collect your bathtime treat from the WINK<sup>+</sup> tub!'
					ELSE IF @campaign_type = 'HOF2017'
						SET @MESSAGE = 'Head to the golf simulator for a swing!'
					ELSE IF @campaign_type = 'airshow2018'
						SET @MESSAGE = 'Thank you for participating. Winners will be notified via email with prize collection details.'
				ELSE IF  @campaign_type = 'Beijing_101Report'
					SET @MESSAGE = 'Congratulations!<br>You have earned ' + CONVERT(varchar(10), @POINTS)+' WINK<sup>+</sup> points  and a pair of movie tickets (T & Cs apply).<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.'
			ELSE IF  @campaign_type = 'WFHReport'
					SET @MESSAGE = '<br>Go to Account > WINK<sup>+</sup> Go to claim your 5 WINK+ points or it will expire in 24 hours. <br><br>Participate daily from 23 April to 1 June.<br><br>Once you click OK, you will be redirected to our Facebook page.'
			ELSE IF @campaign_type = 'NLBxWINKReport'
					SET @MESSAGE = 'You have earned ' + CONVERT(varchar(10), @POINTS)+ ' points'
					ELSE
						SET @MESSAGE = 'Congratulations!<br>You have earned ' + CONVERT(varchar(10), @POINTS)+@POINTS_DESC

					IF(@campaign_id = @tlAprRefCampaignId)
					BEGIN
						SELECT '1' AS response_code, @MESSAGE as response_message, @tlAprEmail as tlCusEmail, @tlAprName as tlCusName;
						return;
					END
					ELSE
					BEGIN
						SELECT '1' AS response_code, @MESSAGE as response_message
						return;
					END
				END
				ELSE	
				BEGIN 
					SELECT '0' AS response_code, 'Insert Fail 1' as response_message
					return;
				END
			END
		END		
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Insert Fail 2' as response_message
			return;
		END	
		
	END

	IF @RETURN_NO = '0'
	BEGIN
		SELECT '0' AS response_code, 'Fail' as response_message
		return
	END
END

