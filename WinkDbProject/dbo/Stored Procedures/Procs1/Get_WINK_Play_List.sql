

CREATE PROC [dbo].[Get_WINK_Play_List]
(@customer_id int)
AS
BEGIN
 
	IF(@customer_id IS NULL OR @customer_id = 0)
	BEGIN
		SELECT top(0) * FROM winktag_campaign;
		RETURN;
	END

	DECLARE @CURRENT_DATETIME Datetime;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

	print(@CURRENT_DATETIME)

	Declare @age int
	Declare @phone_no varchar(10)
	Declare @gender varchar(10)
	DECLARE @wid varchar(50);
	Declare @customer_created_date datetime

	Declare @cnyAttempts int 
	declare @cnyHasWon  int
	set @cnyHasWon = 0;
	Declare @orchardShopsPrize int
	Declare @SPGRoadshow int
	Declare @gardenBBPrize int

	Declare @SatisfactionSize int
	Declare @SatisfactionQualified int = 0
	DECLARE @referralNewUser int = 0;
	DECLARE @referralStart datetime;
	DECLARE @referralEnd datetime;

	DECLARE @totalNLBSurveySize int
	Declare @TLAprDemoQualified int = 0
	DECLARE @totalNDP2021Size int = 0

	select @wid=WID, @customer_created_date =created_at, @gender=gender, @customer_id= customer_id ,@phone_no = phone_no,@age =floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) 
	from customer 
	where customer_id= @customer_id 
	and [status] like 'enable'

	
	SELECT @totalNDP2021Size = COUNT(*) FROM winktag_customer_survey_answer_detail where campaign_id=167 and option_answer like '%The Road Ahead%'


	SELECT @totalNLBSurveySize = COUNT(*) FROM winktag_customer_earned_points WHERE campaign_id = 157;



	SELECT @cnyAttempts = COUNT(*) FROM winktag_customer_survey_answer_detail where campaign_id = 48 and cast(created_at as date) =cast(@CURRENT_DATETIME as date) and customer_id = @customer_id;

	IF EXISTS(SELECT 1 FROM winktag_customer_survey_answer_detail where campaign_id = 48 and cast(created_at as date) = cast(@CURRENT_DATETIME as date) and customer_id = @customer_id and option_answer = '1')
	BEGIN
		SET @cnyHasWon = 1;
	END


	SELECT @orchardShopsPrize = COUNT(*) FROM qr_campaign where customer_id = @customer_id and campaign_id = 61 and winning_status = '1' and redemption_status = '0';

	SELECT @gardenBBPrize = COUNT(*) FROM qr_campaign where customer_id = @customer_id and campaign_id = 130 and winning_status = '1' and redemption_status = '0';

	SELECT @SPGRoadshow = COUNT(*) FROM qr_campaign where customer_id = @customer_id and campaign_id = 65 and redemption_status = '0';
	print('SPG Roadshow');
	print(@SPGRoadshow);

	SELECT @SatisfactionSize = COUNT(*) from winktag_customer_earned_points where campaign_id = 144;
	print('Satisfaction size: ')
	print(@SatisfactionSize);

	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'Internal_ClientSatisfaction_01_33991')
	BEGIN
		set @SatisfactionQualified = 1;
	END

	SELECT @referralStart = from_date, @referralEnd = to_date FROM winktag_campaign WHERE campaign_id = 151;
	print('referral')
	print(@referralStart)
	print(@referralEnd)
	print(@customer_created_date)
	IF(@customer_created_date BETWEEN @referralStart AND @referralEnd)
	BEGIN
		IF NOT EXISTS(
			SELECT 1 FROM winktag_customer_survey_answer_detail WHERE campaign_id = 151 AND customer_id = @customer_id
		)
		BEGIN
			print('new user')
			SET @referralNewUser = 1;
		END
	END

	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'TL_Demo_01_%')
	BEGIN
		set @TLAprDemoQualified = 1;
	END

	declare @winkwfh21Answered int;
	SELECT @winkwfh21Answered = COUNT(1) 
	from wink_game_customer_result 
	where campaign_id = 165 
	and customer_id = @CUSTOMER_ID 
	and cast(created_at as date) = cast(@CURRENT_DATETIME as date);
	print('WINK+ WFH 2021');

	print(@winkwfh21Answered);

	DECLARE @staffTrainingQuizIIEnabled int = 0

	IF EXISTS(SELECT 1 FROM training_email_wid_link WHERE wid like @wid AND campaign_id = 169)
	BEGIN
		print('Refresher quiz II linked');
		DECLARE @totalQuizQueII int = 0
		DECLARE @latestLinkDate datetime

		SELECT @totalQuizQueII = COUNT(question_id) from winktag_survey_question where campaign_id = 169;
		print(@totalQuizQueII);

		SELECT TOP(1) @latestLinkDate = created_at
		FROM training_email_wid_link
		WHERE wid like @wid
		AND campaign_id = 169
		ORDER BY created_at DESC;
		
		IF(
			(
				SELECT COUNT(*) 
				FROM winktag_customer_survey_answer_detail
				WHERE campaign_id = 169
				AND customer_id = @customer_id
				AND created_at > @latestLinkDate
			)<@totalQuizQueII
		)
		BEGIN
			SET @staffTrainingQuizIIEnabled = 1;
			print('enable refresher quiz')
		END
	END

	DECLARE @completedTlMC int = 0
	DECLARE @tlMCAns varchar(50);
	SELECT @tlMCAns = answer FROM winktag_customer_survey_answer_detail WHERE campaign_id = 170 AND customer_id = @customer_id;
	print('tl answer');
	print(@tlMCAns);

	IF (@tlMCAns IS NOT NULL)
	BEGIN
		IF(@tlMCAns like 'MC%' OR @tlMCAns like '%,MC%')
		BEGIN
			SET @completedTlMC = 1;
		END
	END
	print(@completedTlMC);

	--DECLARE @MBXMASEnabled int = 0, @MBXMASCampaignId int = 174;
	--DECLARE @totalPtsInventory int = 168000;
	--DECLARE @totalIssuedPts int = 0;
	--IF EXISTS (
	--	SELECT 1 FROM winktag_customer_action_log
	--	WHERE campaign_id = @MBXMASCampaignId
	--	AND customer_id = @customer_id
	--	AND survey_complete_status = 0
	--)
	--BEGIN
	--	select @totalIssuedPts= ISNULL(SUM(points),0)
	--	from (
	--		SELECT points FROM customer_earned_points 
	--		WHERE (qr_code like 'MBXMAS%' AND qr_code not like 'MBXMAS_WINK%')

	--		UNION ALL

	--		SELECT points FROM winktag_customer_earned_points
	--		WHERE campaign_id = @MBXMASCampaignId
	--	) as issuedPts;

	--	print('total points issued');
	--	print(@totalIssuedPts);
	--	IF(@totalPtsInventory > @totalIssuedPts)
	--	BEGIN
	--		-- user has incomplete voting
	--		set @MBXMASEnabled = 1;
	--		print('incomplete voting')
	--	END
	--	ELSE 
	--	BEGIN
	--		print('no more inventory')
	--	END
	--END
	--ELSE IF EXISTS(
	--	SELECT 1 FROM customer_earned_points 
	--	WHERE CUSTOMER_ID = @CUSTOMER_ID 
	--	AND QR_CODE like 'MBXMAS_WINK_iView_%'
	--	AND CAST(created_at AS DATE) = CAST(@CURRENT_DATETIME AS DATE)
	--)
	--BEGIN
	--	-- if user has scanned the QR code
	--	print('xmas QR code scanned')
	--	IF NOT EXISTS (
	--		SELECT 1 FROM winktag_customer_earned_points
	--		WHERE campaign_id = @MBXMASCampaignId
	--		AND customer_id = @customer_id
	--		AND CAST(created_at AS DATE) = CAST(@CURRENT_DATETIME AS DATE)
	--	)
	--	BEGIN
	--		select @totalIssuedPts= ISNULL(SUM(points),0)
	--		from (
	--			SELECT points FROM customer_earned_points 
	--			WHERE (qr_code like 'MBXMAS%' AND qr_code not like 'MBXMAS_WINK%')

	--			UNION ALL

	--			SELECT points FROM winktag_customer_earned_points
	--			WHERE campaign_id = @MBXMASCampaignId
	--		) as issuedPts;

	--		print('total points issued');
	--		print(@totalIssuedPts);
	--		IF(@totalPtsInventory > @totalIssuedPts)
	--		BEGIN
	--			-- user has not started the voting for today
	--			set @MBXMASEnabled = 1;
	--			print('user has not voted for today yet')
	--		END
	--		ELSE 
	--		BEGIN
	--			print('no more inventory')
	--		END
	--	END
	--	ELSE
	--	BEGIN
	--		print('participated for today')
	--	END
	--END

	DECLARE @STLCnyEnabled int = 0, @STLCnyampaignId int = 175;
	DECLARE @STLCnyW1Start datetime = '2021-12-20 09:00:00.000';
	DECLARE @STLCnyW4End datetime = '2022-01-14 23:59:59.000';

	IF(@CURRENT_DATETIME BETWEEN @STLCnyW1Start AND @STLCnyW4End)
	BEGIN
		IF NOT EXISTS (
			select 1 
			from winktag_customer_earned_points 
			where campaign_id = @STLCnyampaignId 
			and customer_id = @customer_id 
			and cast(created_at as date) = cast(@CURRENT_DATETIME as date)
		)
		BEGIN
		
			DECLARE @STLCnyW1End datetime = '2021-12-24 23:59:59.000';

			DECLARE @STLCnyW2Start datetime = '2021-12-27 09:00:00.000';
			DECLARE @STLCnyW2End datetime = '2021-12-31 23:59:59.000';

			DECLARE @STLCnyW3Start datetime = '2022-01-03 09:00:00.000';
			DECLARE @STLCnyW3End datetime = '2022-01-07 23:59:59.000';

			DECLARE @STLCnyW4Start datetime = '2022-01-10 09:00:00.000';
		
			DECLARE @stlCnyInventory12 int = 100;
			DECLARE @stlCnyInventory34 int = 150;

			IF(@CURRENT_DATETIME BETWEEN @STLCnyW1Start AND @STLCnyW1End)
			BEGIN
				IF(
					(
						SELECT COUNT(1)
						FROM winktag_customer_earned_points
						WHERE campaign_id = @STLCnyampaignId
						AND (created_at BETWEEN @STLCnyW1Start AND @STLCnyW1End)
					) < @stlCnyInventory12
				)
				BEGIN
					SET @STLCnyEnabled = 1;
				END
			END
			ELSE IF(@CURRENT_DATETIME BETWEEN @STLCnyW2Start AND @STLCnyW2End)
			BEGIN
				IF(
					(
						SELECT COUNT(1)
						FROM winktag_customer_earned_points
						WHERE campaign_id = @STLCnyampaignId
						AND (created_at BETWEEN @STLCnyW2Start AND @STLCnyW2End)
					) < @stlCnyInventory12
				)
				BEGIN
					SET @STLCnyEnabled = 1;
				END
			END
			ELSE IF(@CURRENT_DATETIME BETWEEN @STLCnyW3Start AND @STLCnyW3End)
			BEGIN
				IF(
					(
						SELECT COUNT(1)
						FROM winktag_customer_earned_points
						WHERE campaign_id = @STLCnyampaignId
						AND (created_at BETWEEN @STLCnyW3Start AND @STLCnyW3End)
					) < @stlCnyInventory34
				)
				BEGIN
					SET @STLCnyEnabled = 1;
				END
			END
			ELSE IF(@CURRENT_DATETIME BETWEEN @STLCnyW4Start AND @STLCnyW4End)
			BEGIN
				IF(
					(
						SELECT COUNT(1)
						FROM winktag_customer_earned_points
						WHERE campaign_id = @STLCnyampaignId
						AND (created_at BETWEEN @STLCnyW4Start AND @STLCnyW4End)
					) < @stlCnyInventory34
				)
				BEGIN
					SET @STLCnyEnabled = 1;
				END
			END
		END
	END

	--ClientSatisfaction2022 Campaign
	DECLARE @ClientSat2022CampaignId int = 176;
	DECLARE @Satisfaction2022Qualified int = 0;
	Declare @Satisfaction2022Size int

	SELECT @Satisfaction2022Size = COUNT(*) from winktag_customer_earned_points where campaign_id = 176;
	print('Satisfaction size: ')
	print(@Satisfaction2022Size);

	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'Internal_ClientSatisfaction_03_34028')
	BEGIN
		set @Satisfaction2022Qualified = 1;
	END

	--ClientSatisfaction2023 Campaign
	DECLARE @ClientSat2023CampaignId int = 193;
	DECLARE @Satisfaction2023Qualified int = 0;
	Declare @Satisfaction2023Size int

	SELECT @Satisfaction2023Size = COUNT(*) from winktag_customer_earned_points where campaign_id = 193;
	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'Internal_ClientSatisfaction_04_34035')
	BEGIN
		set @Satisfaction2023Qualified = 1;
	END 


	DECLARE @WINKQuestionnaire1Id int = 178;

	DECLARE @WINKQuestionnaire2Id int = 179;
	Declare @TH2022Size int = 0, @TH2022CampaignId int = 183, @TH2022Qualified int = 0;
	SELECT @TH2022Size = COUNT(*) from winktag_customer_earned_points where campaign_id = @TH2022CampaignId;
	print('Town Hall size: ')
	print(@TH2022Size);

	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'TH_Survey_2022_%')
	BEGIN
		set @TH2022Qualified = 1;
	END

	--SMRTAnniversaryTest
	DECLARE @SMRTAnniversaryTestCampaignId int = 187;
	DECLARE @SMRTAnniversaryTestQualified int = 0;
	Declare @SMRTAnniversaryTestSize int

	SELECT @SMRTAnniversaryTestSize = COUNT(*) from winktag_customer_earned_points where campaign_id = 187;
	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS 
	         WHERE CUSTOMER_ID = @CUSTOMER_ID 
			AND QR_CODE like 'SMRTANNI_Event%' AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date))	
	BEGIN
		set @SMRTAnniversaryTestQualified = 1;
	END

	--SMRT35thAnniversaryPhase1
	DECLARE @SMRT35thAnniversaryPhase1CampaignId int = 189;
	DECLARE @SMRT35thAnniversaryPhase1Qualified int = 0;
	Declare @SMRT35thAnniversaryPhase1Size int

	SELECT @SMRT35thAnniversaryPhase1Size = COUNT(*) from winktag_customer_earned_points where campaign_id = @SMRT35thAnniversaryPhase1CampaignId;
	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS 
	         WHERE CUSTOMER_ID = @CUSTOMER_ID 
			 AND QR_CODE like 'SMRT35thANNIP1_Event%' AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date))
	BEGIN
		set @SMRT35thAnniversaryPhase1Qualified = 1;
	END
	--SMRT35thAnniversaryPhase2--
	DECLARE @SMRT35thAnniversaryPhase2CampaignId int = 191;
	DECLARE @SMRT35thAnniversaryPhase2Qualified int = 0; --change 1 for testing purpose --
	Declare @SMRT35thAnniversaryPhase2Size int;
	--After scan QRCode --
	--set @SMRT35thAnniversaryPhase2Qualified=0;
SELECT @SMRT35thAnniversaryPhase2Size = COUNT(*) from winktag_customer_earned_points where 
campaign_id = @SMRT35thAnniversaryPhase2CampaignId;
	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS 
	         WHERE CUSTOMER_ID = @CUSTOMER_ID 
			 AND QR_CODE like 'SMRT35thANNIP2_Event%' AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date))
	BEGIN
		set @SMRT35thAnniversaryPhase2Qualified = 1;
	END
	--SMRT35thAnniversaryPhase3--
	DECLARE @SMRT35thAnniversaryPhase3CampaignId int = 194;
	DECLARE @SMRT35thAnniversaryPhase3Qualified int = 0; 
	Declare @SMRT35thAnniversaryPhase3Size int;
	
	SELECT @SMRT35thAnniversaryPhase3Size = COUNT(*) from winktag_customer_earned_points where 
	campaign_id = @SMRT35thAnniversaryPhase3CampaignId;
	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS 
	         WHERE CUSTOMER_ID = @CUSTOMER_ID 
			 AND QR_CODE like 'SMRT35thANNIP3_Event%' AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date))
		BEGIN
		set @SMRT35thAnniversaryPhase3Qualified = 1;
		END
	--SMRT35thAnniversaryPhase4--
	DECLARE @SMRT35thAnniversaryPhase4CampaignId int = 198;
	DECLARE @SMRT35thAnniversaryPhase4Qualified int = 0; 
	Declare @SMRT35thAnniversaryPhase4Size int;
	
	SELECT @SMRT35thAnniversaryPhase4Size = COUNT(*) from winktag_customer_earned_points where 
	campaign_id = @SMRT35thAnniversaryPhase4CampaignId;
	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS 
	         WHERE CUSTOMER_ID = @CUSTOMER_ID 
			 AND QR_CODE like 'SMRT35thANNIP4_Event%' AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date))
		BEGIN
		set @SMRT35thAnniversaryPhase4Qualified = 1;
		END
	
	--SMRT35thAnniversaryPhase5--
	DECLARE @SMRT35thAnniversaryPhase5CampaignId int = 199;
	DECLARE @SMRT35thAnniversaryPhase5Qualified int = 0; 
	Declare @SMRT35thAnniversaryPhase5Size int;
	
	SELECT @SMRT35thAnniversaryPhase5Size = COUNT(*) from winktag_customer_earned_points where 
	campaign_id = @SMRT35thAnniversaryPhase5CampaignId;
	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS 
	         WHERE CUSTOMER_ID = @CUSTOMER_ID 
			 AND QR_CODE like 'SMRT35thANNIP5_Event%' AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date))
		BEGIN
		set @SMRT35thAnniversaryPhase5Qualified = 1;
		END

	--SMRT35thAnniversaryPhase6--
	DECLARE @SMRT35thAnniversaryPhase6CampaignId int = 200;
	DECLARE @SMRT35thAnniversaryPhase6Qualified int = 0; 
	Declare @SMRT35thAnniversaryPhase6Size int;
	
	SELECT @SMRT35thAnniversaryPhase6Size = COUNT(*) from winktag_customer_earned_points where 
	campaign_id = @SMRT35thAnniversaryPhase6CampaignId;
	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS 
	         WHERE CUSTOMER_ID = @CUSTOMER_ID 
			 AND QR_CODE like 'SMRT35thANNIP6_Event%' AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date))
		BEGIN
		set @SMRT35thAnniversaryPhase6Qualified = 1;
		END

	--SMRT35thAnniversaryPhase7--
	DECLARE @SMRT35thAnniversaryPhase7CampaignId int = 201;
	DECLARE @SMRT35thAnniversaryPhase7Qualified int = 0; 
	Declare @SMRT35thAnniversaryPhase7Size int;
	
	SELECT @SMRT35thAnniversaryPhase7Size = COUNT(*) from winktag_customer_earned_points where 
	campaign_id = @SMRT35thAnniversaryPhase7CampaignId;
	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS 
	         WHERE CUSTOMER_ID = @CUSTOMER_ID 
			 AND QR_CODE like 'SMRT35thANNIP7_Event%' AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date))
		BEGIN
		set @SMRT35thAnniversaryPhase7Qualified = 1;
		END

	--GreenLiving--
	DECLARE @GreenLivingId int = 197;
	Declare @GreenLivingSize int;
	SELECT @GreenLivingSize = COUNT(*) from winktag_customer_earned_points where 
	campaign_id = @GreenLivingId;
	
    --BusShelterTender--
	DECLARE @BusShelterTenderId int = 204;
	Declare @BusShelterTenderSize int;
	SELECT @BusShelterTenderSize = COUNT(*) from winktag_customer_earned_points where 
	campaign_id = @BusShelterTenderId;

    --TownHallHiveSurvey2023--
	DECLARE @TownHallHiveSurvey2023CampaignId int = 208;
	DECLARE @TownHallHiveSurvey2023Qualified int = 0;
	Declare @TownHallHiveSurvey2023Size int

	SELECT @TownHallHiveSurvey2023Size = COUNT(*) from winktag_customer_earned_points 
	where campaign_id = @TownHallHiveSurvey2023CampaignId;
	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS 
	         WHERE CUSTOMER_ID = @CUSTOMER_ID 
			 AND QR_CODE like 'TownHallHiveSurvey2023_Event%')
	BEGIN
		set @TownHallHiveSurvey2023Qualified = 1;
	END

    --TownHall2023MarsilingStaytion--
	DECLARE @TownHall2023MarsilingStaytionId int = 210;
	DECLARE @TownHall2023MarsilingStaytionQualified int = 0;
	Declare @TownHall2023MarsilingStaytionSize int

	SELECT @TownHall2023MarsilingStaytionSize = COUNT(*) from winktag_customer_earned_points 
	where campaign_id = @TownHall2023MarsilingStaytionId;
	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS 
	         WHERE CUSTOMER_ID = @CUSTOMER_ID 
			 AND QR_CODE like 'TownHallMarsilingStaytionSurvey2023_Event%')
	BEGIN
		set @TownHall2023MarsilingStaytionQualified = 1;
	END

    --WinkHuntNewUser--
    DECLARE @WinkHuntIsNewUserFromDate datetime;
    DECLARE @WinkHuntNewUserQualified INT = 0;
    DECLARE @WinkHuntNewUserCampaignId int = 211;
	DECLARE @WinkHuntNewUserSize int;
    DECLARE @WinkHuntNewUserSizeLimit int;
    SELECT @WinkHuntIsNewUserFromDate = from_date, @WinkHuntNewUserSizeLimit = size
    FROM winktag_campaign
    WHERE campaign_id = @WinkHuntNewUserCampaignId;
	SELECT @WinkHuntNewUserSize = COUNT(*) 
        FROM TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS L
        JOIN TBL_WINKPLAY_WINKHUNT_CODES AS C
        ON L.WP_WH_CODES_ID = C.WP_WH_CODES_ID
        WHERE C.campaign_id = @WinkHuntNewUserCampaignId;
    IF EXISTS(SELECT 1 
    FROM customer
    WHERE customer_id = @customer_id AND created_at >= @WinkHuntIsNewUserFromDate)
    BEGIN
        SET @WinkHuntNewUserQualified = 1;
    END

    --WinkHuntExistingUser--
    DECLARE @WinkHuntIsExistingUserFromDate datetime;
    DECLARE @WinkHuntExistingUserQualified INT = 0;
    DECLARE @WinkHuntExistingUserCampaignId int = 212;
	DECLARE @WinkHuntExistingUserSize int;
    DECLARE @WinkHuntExistingUserSizeLimit int;
    SELECT @WinkHuntIsExistingUserFromDate = from_date, @WinkHuntExistingUserSizeLimit = size
    FROM winktag_campaign
    WHERE campaign_id = @WinkHuntExistingUserCampaignId;
	SELECT @WinkHuntExistingUserSize = COUNT(*) 
        FROM TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS L
        JOIN TBL_WINKPLAY_WINKHUNT_CODES AS C
        ON L.WP_WH_CODES_ID = C.WP_WH_CODES_ID
        WHERE C.campaign_id = @WinkHuntExistingUserCampaignId;
    IF EXISTS(SELECT 1 
    FROM customer
    WHERE customer_id = @customer_id AND created_at < @WinkHuntIsExistingUserFromDate)
    BEGIN
        SET @WinkHuntExistingUserQualified = 1;
    END

    --WinkHuntSurveyP1Campaign--
	DECLARE @WinkHuntSurveyP1CampaignId int = 215;
	Declare @WinkHuntSurveyP1CampaignSize int;
	SELECT @WinkHuntSurveyP1CampaignSize = COUNT(*) from winktag_customer_earned_points where 
	campaign_id = @WinkHuntSurveyP1CampaignId;
    DECLARE @WinkHuntSurveyP1CampaignSizeLimit int;
    SELECT @WinkHuntSurveyP1CampaignSizeLimit = size from winktag_campaign where 
    campaign_id = @WinkHuntSurveyP1CampaignId;

	 --WinkHuntSurveyP2Campaign--
	DECLARE @WinkHuntSurveyP2CampaignId int = 218;
	DECLARE @WinkHuntSurveyP2CampaignSize int;
	SELECT @WinkHuntSurveyP2CampaignSize = COUNT(*) from winktag_customer_earned_points where 
	campaign_id = @WinkHuntSurveyP2CampaignId;
    DECLARE @WinkHuntSurveyP2CampaignSizeLimit int;
    SELECT @WinkHuntSurveyP2CampaignSizeLimit = size from winktag_campaign where 
    campaign_id = @WinkHuntSurveyP2CampaignId;


	--WinkHuntRewardCards--
	DECLARE @WinkHuntRewardCardsId int = 217;
	Declare @WinkHuntRewardCardsSize int
	SELECT @WinkHuntRewardCardsSize = COUNT(*) from winktag_customer_earned_points 
	where campaign_id = @WinkHuntRewardCardsId;

	SELECT * FROM winktag_campaign as w 
	WHERE w.survey_type not like 'merchant' 
	AND w.winktag_type not like 'wink_fee'
	AND w.winktag_type not like 'template_survey'
	AND w.WINKTAG_STATUS like '1'
	AND w.internal_testing_status = 0
	AND campaign_id !=48
	AND campaign_id != 61
	AND campaign_id != 65
	AND campaign_id != 110
	AND campaign_id != 116
	AND campaign_id != 130
	AND campaign_id ! =144
	AND campaign_id !=151
	AND campaign_id !=157
	AND campaign_id != 160
	AND campaign_id != 162
	AND campaign_id != 163
	AND campaign_id != 165
	AND campaign_id != 167
	AND campaign_id ! =169
	AND campaign_id ! =170
	--and campaign_id != @MBXMASCampaignId
	and campaign_id != @STLCnyampaignId
	and campaign_id != 176
	and w.campaign_id != @WINKQuestionnaire1Id
	and w.campaign_id != @WINKQuestionnaire2Id
	and campaign_id != @TH2022CampaignId
	and campaign_id != @SMRTAnniversaryTestCampaignId
	AND w.campaign_id != @SMRT35thAnniversaryPhase1CampaignId
	AND w.campaign_id != @SMRT35thAnniversaryPhase2CampaignId
	AND w.campaign_id != @ClientSat2023CampaignId
	AND w.campaign_id != @SMRT35thAnniversaryPhase3CampaignId
	AND w.campaign_id != @GreenLivingId
	AND w.campaign_id != @SMRT35thAnniversaryPhase4CampaignId
	AND w.campaign_id != @SMRT35thAnniversaryPhase5CampaignId
	AND w.campaign_id != @SMRT35thAnniversaryPhase6CampaignId
	AND w.campaign_id != @SMRT35thAnniversaryPhase7CampaignId
    AND w.campaign_id != @BusShelterTenderId
    AND w.campaign_id != @TownHallHiveSurvey2023CampaignId
    AND w.campaign_id != @TownHall2023MarsilingStaytionId
    AND w.campaign_id != @WinkHuntNewUserCampaignId
    AND w.campaign_id != @WinkHuntExistingUserCampaignId
    AND w.campaign_id != @WinkHuntSurveyP1CampaignId
	AND w.campaign_id != @WinkHuntRewardCardsId
    AND w.campaign_id != @WinkHuntSurveyP2CampaignId

	union --- CNY campaign
	select * from winktag_campaign WHERE WINKTAG_STATUS = 1 
	and campaign_id = 48
	AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
	AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)  
	AND cast(@CURRENT_DATETIME as time) between '08:00:00.000' and '23:59:59.000'
	AND @cnyAttempts <3
	AND @cnyHasWon = 0

	union 
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	AND campaign_id = 61
	AND @orchardShopsPrize > 0

	union 
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	AND campaign_id = 130
	AND @gardenBBPrize > 0

	union
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	AND campaign_id = 65
	AND @SPGRoadshow > 0
	
	union 
	---- NDP Thematic campaign - Scratch Card
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	AND cast(@CURRENT_DATETIME as time) not between '00:00:00.000' and '08:29:59.000'
	And w.campaign_id = 110
	AND w.campaign_id not in (
					
		Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_action_log as e
		where e.customer_id =@customer_id
		AND cast(e.created_at as DATE) = cast(@CURRENT_DATETIME as DATE)
		AND survey_complete_status = '1'
	)

	union 
	---- Mid-Autumn 2019
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	AND cast(@CURRENT_DATETIME as time) not between '00:00:00.000' and '08:29:59.000'
	And w.campaign_id = 116
	AND w.campaign_id not in (
					
		Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points as e
		where e.customer_id =@customer_id
		AND cast(e.created_at as DATE) = cast(@CURRENT_DATETIME as DATE)
	)
	union 
	-- WINK+ Engagement Training campaign
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	AND campaign_id = 169
	AND @staffTrainingQuizIIEnabled = 1

	union 
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = 144
	AND @SatisfactionQualified = 1
	AND w.campaign_id not in (Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points where customer_id =@customer_id)
	AND @SatisfactionSize < 150

	union 
	SELECT w.[campaign_id],w.[campaign_name],w.[campaign_image_large],w.[campaign_image_small],w.[points],w.[interval_status]
	,w.[interval] ,@referralNewUser as limit ,w.[winktag_type],w.[winktag_status],w.[created_at],w.[updated_at]
	,w.[from_date],w.[to_date],w.[interval_type],w.[content],w.[survey_type],w.[position],w.[winktag_report]
	,w.[size],w.[min_count],w.[max_count],w.[sp_type],w.[internal_testing_status]
	FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = 151

	union 
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = 157
	AND @totalNLBSurveySize < 700

	union 
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And (w.campaign_id = 160 or w.campaign_id = 162)
	AND @TLAprDemoQualified = 1
	AND w.campaign_id not in (Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points where customer_id =@customer_id)
	
	union 
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	AND CAST(@CURRENT_DATETIME as time) between '05:30:00.000' and '23:59:59.999'
	AND campaign_id = 165
	AND @winkwfh21Answered < 6
	
	--NDP2021
	union
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = 167
	AND @totalNDP2021Size < 80
	AND NOT EXISTS (
						SELECT '1' FROM winktag_customer_survey_answer_detail
						WHERE customer_id = @customer_id
						AND campaign_id = 167
	)

	union 
	-- TransitLink MasterCard Campaign - Code
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	AND campaign_id = 170
	AND @completedTlMC = 0

	--union 
	---- MyBestXmas
	--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	--AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	--AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	--AND campaign_id = @MBXMASCampaignId
	--AND @MBXMASEnabled = 1

	union 
	-- STL CNY 2022
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	AND campaign_id = @STLCnyampaignId
	AND @STLCnyEnabled = 1

	union 
	-- Client Satisfaction 2022
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = @ClientSat2022CampaignId
	AND @Satisfaction2022Qualified = 1
	AND w.campaign_id not in (Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points where customer_id =@customer_id)
	AND @Satisfaction2022Size < 100

	union 
	-- WINK Questionnaire 1
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	AND campaign_id = @WINKQuestionnaire1Id
	AND w.campaign_id not in (Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points where customer_id =@customer_id)
	
	union 
	-- WINK Questionnaire 2
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	AND campaign_id = @WINKQuestionnaire2Id
	AND w.campaign_id not in (Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points where customer_id =@customer_id)

	union 
	-- Town Hall 2022
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = @TH2022CampaignId
	AND @TH2022Qualified = 1
	AND NOT EXISTS (
		SELECT '1' FROM winktag_customer_survey_answer_detail
		WHERE customer_id = @customer_id
		AND campaign_id = @TH2022CampaignId
	)
	AND @TH2022Size < 110

	union 
    --SMRTAnniversaryTest
    SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = @SMRTAnniversaryTestCampaignId 
	AND @SMRTAnniversaryTestQualified = 1
	AND NOT EXISTS (
		SELECT '1' FROM winktag_customer_survey_answer_detail
		WHERE customer_id = @customer_id
		AND campaign_id = @SMRTAnniversaryTestCampaignId
		AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date)
	)
	AND @SMRTAnniversaryTestSize < 5000

	union 
    --SMRT35thAnniversaryPhase1
    SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = @SMRT35thAnniversaryPhase1CampaignId 
	AND @SMRT35thAnniversaryPhase1Qualified = 1
	AND NOT EXISTS (
		SELECT '1' FROM winktag_customer_survey_answer_detail
		WHERE customer_id = @customer_id
		AND campaign_id = @SMRT35thAnniversaryPhase1CampaignId
		AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date)
	)
	AND @SMRT35thAnniversaryPhase1Size < 25
	union

	 --SMRT35thAnniversaryPhase2
    SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = @SMRT35thAnniversaryPhase2CampaignId 
	AND @SMRT35thAnniversaryPhase2Qualified = 1
	AND NOT EXISTS (
		SELECT '1' FROM winktag_customer_survey_answer_detail
		WHERE customer_id = @customer_id
		AND campaign_id = @SMRT35thAnniversaryPhase2CampaignId
		AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date)
	)
	AND @SMRT35thAnniversaryPhase2Size < 6500

	union

	 --SMRT35thAnniversaryPhase3
    SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = @SMRT35thAnniversaryPhase3CampaignId 
	AND @SMRT35thAnniversaryPhase3Qualified = 1
	AND NOT EXISTS (
		SELECT '1' FROM winktag_customer_survey_answer_detail
		WHERE customer_id = @customer_id
		AND campaign_id = @SMRT35thAnniversaryPhase3CampaignId
		AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date)
	)
	AND @SMRT35thAnniversaryPhase3Size < 6500

	union
	--SMRT35thAnniversaryPhase4
    SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = @SMRT35thAnniversaryPhase4CampaignId 
	AND @SMRT35thAnniversaryPhase4Qualified = 1
	AND NOT EXISTS (
		SELECT '1' FROM winktag_customer_survey_answer_detail
		WHERE customer_id = @customer_id
		AND campaign_id = @SMRT35thAnniversaryPhase4CampaignId
		AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date)
	)
	AND @SMRT35thAnniversaryPhase4Size < 6500

	union
	--SMRT35thAnniversaryPhase5--
    SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = @SMRT35thAnniversaryPhase5CampaignId 
	AND @SMRT35thAnniversaryPhase5Qualified = 1
	AND NOT EXISTS (
		SELECT '1' FROM winktag_customer_survey_answer_detail
		WHERE customer_id = @customer_id
		AND campaign_id = @SMRT35thAnniversaryPhase5CampaignId
		AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date)
	)
	AND @SMRT35thAnniversaryPhase5Size < 7000

	union
	--SMRT35thAnniversaryPhase6--
    SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = @SMRT35thAnniversaryPhase6CampaignId 
	AND @SMRT35thAnniversaryPhase6Qualified = 1
	AND NOT EXISTS (
		SELECT '1' FROM winktag_customer_survey_answer_detail
		WHERE customer_id = @customer_id
		AND campaign_id = @SMRT35thAnniversaryPhase6CampaignId
		AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date)
	)
	AND @SMRT35thAnniversaryPhase6Size < 6000

	union
	--SMRT35thAnniversaryPhase7--
    SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = @SMRT35thAnniversaryPhase7CampaignId 
	AND @SMRT35thAnniversaryPhase7Qualified = 1
	AND NOT EXISTS (
		SELECT '1' FROM winktag_customer_survey_answer_detail
		WHERE customer_id = @customer_id
		AND campaign_id = @SMRT35thAnniversaryPhase7CampaignId
		AND CAST(created_at as DATE) = CAST(@CURRENT_DATETIME as date)
	)
	AND @SMRT35thAnniversaryPhase7Size < 6500

	union 
	-- Client Satisfaction 2023
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = @ClientSat2023CampaignId
	AND @Satisfaction2023Qualified = 1
	AND w.campaign_id not in (Select distinct(campaign_id) FROM [winkwink].[dbo].winktag_customer_earned_points where customer_id =@customer_id)
	AND @Satisfaction2023Size < 100

	union
    --GreenLiving --
    SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = @GreenLivingId
	AND NOT EXISTS (
		SELECT '1' FROM winktag_customer_survey_answer_detail
		WHERE customer_id = @customer_id
		AND campaign_id = @GreenLivingId
		)
	AND @GreenLivingSize < 500

    union
    --BusShelterTender--
    SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = @BusShelterTenderId
	AND NOT EXISTS (
		SELECT '1' FROM winktag_customer_survey_answer_detail
		WHERE customer_id = @customer_id
		AND campaign_id = @BusShelterTenderId
		)
	AND @BusShelterTenderSize < 500

    union
    --TownHallHiveSurvery2023--
	SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	And w.campaign_id = @TownHallHiveSurvey2023CampaignId
	AND @TownHallHiveSurvey2023Qualified = 1
	AND NOT EXISTS (
		SELECT '1' FROM winktag_customer_survey_answer_detail
		WHERE customer_id = @customer_id
		AND campaign_id = @TownHallHiveSurvey2023CampaignId
	)
	AND @TownHallHiveSurvey2023Size < 135

    union
    --TownHall2023MarsilingStaytion--
    SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
    AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
    AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
    And w.campaign_id = @TownHall2023MarsilingStaytionId
    AND @TownHall2023MarsilingStaytionQualified = 1
    AND NOT EXISTS (
      SELECT '1' FROM winktag_customer_survey_answer_detail
      WHERE customer_id = @customer_id
      AND campaign_id = @TownHall2023MarsilingStaytionId
    )
    AND @TownHall2023MarsilingStaytionSize < 135

    UNION
    --WinkHuntNewUser--
    SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	AND w.campaign_id = @WinkHuntNewUserCampaignId
    AND @WinkHuntNewUserQualified = 1
	AND NOT EXISTS (
		SELECT 1 FROM TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS L
        JOIN TBL_WINKPLAY_WINKHUNT_CODES AS C
        ON L.WP_WH_CODES_ID = C.WP_WH_CODES_ID
        WHERE C.campaign_id = @WinkHuntNewUserCampaignId 
        AND L.customer_id = @customer_id
	)
	AND @WinkHuntNewUserSize < @WinkHuntNewUserSizeLimit
    
    UNION
    --WinkHuntExistingUser--
    SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	AND w.campaign_id = @WinkHuntExistingUserCampaignId
    AND @WinkHuntExistingUserQualified = 1
	AND NOT EXISTS (
		SELECT 1 FROM TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS L
        JOIN TBL_WINKPLAY_WINKHUNT_CODES AS C
        ON L.WP_WH_CODES_ID = C.WP_WH_CODES_ID
        WHERE C.campaign_id = @WinkHuntExistingUserCampaignId 
        AND L.customer_id = @customer_id
	)
	AND @WinkHuntExistingUserSize < @WinkHuntExistingUserSizeLimit

    UNION
    --WinkHuntSurveyP1Campaign--
    SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
        AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
        AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
        And w.campaign_id = @WinkHuntSurveyP1CampaignId
        AND NOT EXISTS (
            SELECT '1' FROM winktag_customer_survey_answer_detail
            WHERE customer_id = @customer_id
            AND campaign_id = @WinkHuntSurveyP1CampaignId
            )
        AND @WinkHuntSurveyP1CampaignSize < @WinkHuntSurveyP1CampaignSizeLimit  

	UNION
		--WinkHuntSurveyP2Campaign--
		SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
		AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
		AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
		And w.campaign_id = @WinkHuntSurveyP2CampaignId 
		AND NOT EXISTS (
				SELECT '1' FROM winktag_customer_survey_answer_detail
				WHERE customer_id = @customer_id
				AND campaign_id = @WinkHuntSurveyP2CampaignId				
				)
				AND @WinkHuntSurveyP2CampaignSize < @WinkHuntSurveyP2CampaignSizeLimit
     union
		--WinkHuntRewardCards--
		SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
		AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
		AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
		And w.campaign_id = @WinkHuntRewardCardsId 
		AND @WinkHuntRewardCardsSize < 100
	union 
    --- Internal testing
	select * from winktag_campaign 
	WHERE internal_testing_status = 1 
	AND WINKTAG_STATUS like '0' 
	AND survey_type not like 'merchant' 
	AND winktag_type not like 'wink_fee'
	AND winktag_type not like 'template_survey'
	AND campaign_id  in (
		select campaign_id from winktag_approved_phone_list as a
		join customer as c
		on a.phone_no = c.phone_no
		where c.customer_id =@customer_id
	)

	--AND campaign_id!=167

	--union --- Internal testing for NDP2021
	--				select *
	--				from winktag_campaign as w WHERE internal_testing_status = 1 and  WINKTAG_STATUS = 0 AND winktag_type != 'template_survey' 
	--				AND CONVERT(DATETIME,@CURRENT_DATETIME) >= CONVERT(DATETIME,from_date)
	--				AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
	--				AND @totalNDP2021Size < 80
	--				AND campaign_id = 167
	--				AND NOT EXISTS (
	--					SELECT '1' FROM winktag_customer_survey_answer_detail
	--					WHERE customer_id = @customer_id
	--				--	AND option_answer = @beautyoneCurCategory
	--					AND campaign_id = 167
	--				)
	--				AND campaign_id  in (select campaign_id from winktag_approved_phone_list as a
	--				join customer as c
	--				on a.phone_no = c.phone_no
	--				where c.customer_id =     @customer_id
	--				)
			
	order by position asc
END

