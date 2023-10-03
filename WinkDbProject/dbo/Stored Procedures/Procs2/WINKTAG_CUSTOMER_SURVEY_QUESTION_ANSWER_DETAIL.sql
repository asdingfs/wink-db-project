
CREATE PROC [dbo].[WINKTAG_CUSTOMER_SURVEY_QUESTION_ANSWER_DETAIL]
@campaign_id int,
@customer_id int,
@question_id int,
@option_id int,
@option varchar(250),
@answer varchar(1000),
@location varchar(250),
@ip_address varchar(50)
AS

BEGIN

	DECLARE @option_answer varchar(250)
	DECLARE @question_no varchar(10) = ''
	DECLARE @row_count int = 0
	DECLARE @curSize int
	DECLARE @vday2019_answer varchar(max)
	DECLARE @wid varchar(50);

	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 
	--1)CHECK CUSTOMER
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_CUSTOMER WHERE customer_id = @customer_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Customer' as response_message
		return
	END

	--2)CHECK CAMPAIGN
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
	BEGIN
		IF(@campaign_id != 177)
		BEGIN
			SELECT '0' AS response_code, 'We have reached the maximum number of respondents.<br>Please try again next time.' as response_message
			return
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Thank you for your participation, we have reached the maximum number of votes.' as response_message
			return
		END
	END


	--3)CHECK ANSWER TYPE
	
	IF (SELECT option_type FROM winktag_survey_option WHERE option_id = @option_id AND question_id = @question_id AND campaign_id = @campaign_id) = 'textbox' OR (SELECT option_type FROM winktag_survey_option WHERE option_id = @option_id AND question_id = @question_id AND campaign_id = @campaign_id) = 'textbox_exclusive'
		SET @option_answer = @answer
	ELSE
		SET @option_answer = (SELECT option_answer FROM winktag_survey_option WHERE option_id = @option_id AND question_id = @question_id AND campaign_id = @campaign_id)	
	

	--4)GET QUESTION NO
	IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'euro_group_2017'--check for euro group
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	--ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'MidAutumn2021Report'--check for Mid Autumn 2021
	--BEGIN
	--	SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
	--	IF @question_no is null
	--		SET @question_no = ''
	--END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'Beijing_101Report'--check for euro group
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'PopcornManiaReport'--check for euro group
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'DesignCouncilReport'--check for design council
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'KouKouContestReport'--check for Kou Kou Contest
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'HalloweenReport'--check for Halloween
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'DysonReport'--check for Dyson
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'RalphReport'--check for Wreck-It Ralph 2
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'TrichokareReport'--check for Trichokare
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'ChristmasReport'--check for Christmas Word Play
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'BeautyoneReport'--check for Beauty One
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'MitsubishiReport'--check for Mitsubishi
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'CnyReport'--check for CNY Fortune Wheel
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'Valentines2019Report'--check for Valentines2019
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		SET @vday2019_answer = @answer;
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'ShawTheatresReport'--check for Shaw Theatres
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'DisneyOnIceReport'--check for Disney On Ice
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'BookDepositoryReport'--check for Book Depository
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'AvengersEndgameReport'--check for Avengers Endgame
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'KouKouHandrailsReport'--check for KouKou Handrails
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'KouKouLiftReport'--check for KouKou Lift
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'GenecoReport'--check for Geneco
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'KouKouTrainRushReport'--check for Geneco
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'KouKouEatDrinkReport'--check for KouKou Eat Drink
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'SSBReport'--check for Singapore Savings Bonds
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'EZBuyReport'--check for EZBuy
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'KouKouMobilityDevicesReport'--check for KouKou Mobility Devices
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'GOFixReport'--check for GOfix
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'AIGReport'--check for AIG
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'StaffBrandingReport'--check for SMRT Staff Branding
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'FitbitReport'--check for Fitbit
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'KouKouGapReport'--check for KouKou Mind the Gaps
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'ToyStoryReport'--check for Toy Story 4
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'KouKouGripReport'--check for KouKou Hand Grip
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'SPGMCReport'--check for SimplyGo Mastercard
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'Qoo10Report'--check for Qoo10
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'UOBSPGReport'--check for UOB SimplyGo
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'AvivaReport'--check for Aviva
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'Qoo10IIReport'--check for Qoo10 II
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'LozonReport'--check for Lozon
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'InfoTechReport'--check for Info-Tech
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'BookDepository2Report'--check for Book Depository2
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	--- ALWAYS PUT IN BEFORE ELSE CONDITION
	--- WINK+ PLAY TEMPLATE
	ELSE IF (SELECT winktag_type FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'template_survey'--check for WINK+ Play Template 
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'AIG2Report'--check for AIG2
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'WorldRemitReport'--check for WorldRemitReport
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'DeepavaliReport'--check for deepavali
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'GreenBuildingReport'--check for Green Building
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'JumanjiReport'--check for JumanjiReport
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'WestMallReport'--check for West Mall
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'CNYSushiReport'--check for CNY Sushi
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'CNY2020Report'--check for CNY 2020
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'SonicReport'--check for Sonic
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'ClientReport'--check for Client Satisfaction Survey
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'TripleAReport'--check for Triple A Engagement Campaign
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'TransitLinkReport'--check for TransitLink Campaign
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'Client2021Report'--check for Client Satiscation Campaign 2021
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'TLAprCodeReport'--check for TransitLink Apr Campaign - Code
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'TLAprReferralReport'--check for TransitLink Apr Campaign - Referral
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'TLMCGatesReport'--check for TransitLink MasterCard WINK Gates Campaign
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'TLMCFinaleReport'--check for TransitLink MasterCard Travel Bonus Campaign
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'MyBestXmasReport'--check for My Best Xmas Campaign
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'STLCNY2022Report'--check for STL CNY 2022
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'Client2022Report'--check for Client Satisfation Campaign 2022
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) like 'QuestionnaireReport%'--check for WINK Questionnaire
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'Client2023Report'--check for Client Satisfation Campaign 2023
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
    ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'BusShelterTenderReport'--check for Bus Shelter Tender Survey 2023
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
    ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'TownHallHiveSurvey2023Report'--check for TownHallHiveSurvey2023
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
    ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'TownHall2023MarsilingStaytionReport'--check for TownHall2023MarsilingStaytion
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
    ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'WinkHuntSurveyPhase1Report'--check for WinkHuntSurveyP1Report
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END

	 ELSE IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'WinkHuntSurveyPhase2Report'--check for WinkHuntSurveyP2Report
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	ELSE
	BEGIN
		SET @question_no = (SELECT question_no FROM winktag_survey_question WHERE campaign_id = @campaign_id AND question_id = @question_id)
		IF @question_no is null
			SET @question_no = ''
	END


	

	--5)CHECK LOCATION		
	IF @location is null or @location = '' or @location = '(null)'
		SET @location = 'User location cannot be detected'

	DECLARE @latestTrainingLinkDate datetime
	--6)CHECK ROW COUNT
	IF(@campaign_id != 169 and @campaign_id != 102 and @campaign_id != 142 and @campaign_id!=157)
	BEGIN
		SET @row_count = (SELECT COUNT(*) FROM winktag_customer_earned_points WHERE campaign_id = @campaign_id AND customer_id = @customer_id)+1
	END
	ELSE IF(@campaign_id = 169)
	BEGIN
		SELECT @wid=WID 
		FROM customer
		WHERE customer_id = @customer_id;

		SELECT TOP(1) @latestTrainingLinkDate = created_at
		FROM training_email_wid_link
		WHERE wid like @wid
		AND campaign_id = @campaign_id
		ORDER BY created_at DESC;

		SET @row_count = (SELECT COUNT(*) FROM winktag_customer_survey_answer_detail WHERE campaign_id = @campaign_id AND customer_id = @customer_id AND created_at > @latestTrainingLinkDate)+1
	END
	ELSE
	BEGIN
		SET @row_count = (SELECT COUNT(*) FROM winktag_customer_survey_answer_detail WHERE campaign_id = @campaign_id AND customer_id = @customer_id)+1
	END
	
	
    BEGIN

	
	If(@campaign_id = 27)
	BEGIN
		if NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id)
		BEGIN
		SET @option_answer = (SELECT image_name FROM winktag_survey_option WHERE option_id = @option_id AND question_id = @question_id AND campaign_id = @campaign_id)	
		INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
		([customer_id]
		,[campaign_id]
		,[question_id]
		,[option_id]
		,[option_answer]
		,[answer]
		,[created_at]
		,[question_no]
		,[row_count]
		,[GPS_location]
		,[ip_address]
		)
		VALUES
		(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count,@location, @ip_address)
	
		END
	
	


	
		ELSE
		

		BEGIN
			SELECT '0' AS response_code, 'You have already participated in the WINK+ Mother&#39;s Day Giveaway.' as response_message
			return
		END


	END
	
	
	ELSE If(@campaign_id = 32)
	BEGIN
		if NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id)
		BEGIN
		SET @option_answer = (SELECT image_name FROM winktag_survey_option WHERE option_id = @option_id AND question_id = @question_id AND campaign_id = @campaign_id)	
		INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
		([customer_id]
		,[campaign_id]
		,[question_id]
		,[option_id]
		,[option_answer]
		,[answer]
		,[created_at]
		,[question_no]
		,[row_count]
		,[GPS_location]
		,[ip_address]
		)
		VALUES
		(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count,@location, @ip_address)
				BEGIN
				SELECT '0' AS response_code, ' What an amazing goal! You will soon find out if you’re one of the 5 lucky winners!.' as response_message
				return
				END
		END
	
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Thank you! You have already scored one goal in the World Cup. Winners will be notified soon!.' as response_message
			return
		END


	END
	
	ELSE If(@campaign_id = 35)
	BEGIN
	if NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id)
	BEGIN
	
		INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
		([customer_id]
		,[campaign_id]
		,[question_id]
		,[option_id]
		,[option_answer]
		,[answer]
		,[created_at]
		,[question_no]
		,[row_count]
		,[GPS_location]
		,[ip_address]
		)
		VALUES
		(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count,@location, @ip_address)
				BEGIN
				SELECT '0' AS response_code, 'Thank you for participating! Winners will be announced soon.' as response_message
				return
				END
	END
	
	ELSE
		BEGIN
			SELECT '0' AS response_code, '
			Thank you! You have already participated!' as response_message
			return
		END
	END

	ELSE If(@campaign_id = 38)
	BEGIN
		if NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id)
		BEGIN
	
			INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
		([customer_id]
		,[campaign_id]
		,[question_id]
		,[option_id]
		,[option_answer]
		,[answer]
		,[created_at]
		,[question_no]
		,[row_count]
		,[GPS_location]
		,[ip_address]
		)
		VALUES
		(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count,@location, @ip_address)
				BEGIN
				SELECT '0' AS response_code, 'Thank you for participating! Winners will be announced soon.' as response_message
				return
				END
		END
	END
	ELSE If(@campaign_id = 39)
	BEGIN
		if NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id)
			BEGIN
	
				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count]
				,[GPS_location]
				,[ip_address]
				)
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count,@location, @ip_address)
				BEGIN
					SELECT '0' AS response_code, 'Thank you for participating! Winners will be announced soon.' as response_message
					return
				END
			END
	 
		ELSE

			BEGIN
				SELECT '0' AS response_code, '
				Thank you! You have already participated!' as response_message
				return
			END
	END

	ELSE If(@campaign_id = 46)
	BEGIN
	   	IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id = @question_id)
			BEGIN
				
				
				IF(@option = '1')
				BEGIN
					UPDATE [dbo].[winktag_survey_option]
					SET image_name= image_name + 1
					where option_id = @option_id;
				END
				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count]
				)
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option,@answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count);
		
			END
		ELSE

			BEGIN
				SELECT '0' AS response_code, '
				Thank you! You have already participated!' as response_message
				return
			END
	END

	ELSE If(@campaign_id = 54)
	BEGIN
	   	IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and option_id = @option_id)
			BEGIN
				
				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count]
				)
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option,@option_answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count);
		
			END
		ELSE

			BEGIN
				SELECT '0' AS response_code, '
				Thank you! You have already participated!' as response_message
				return
			END
	END

	ELSE If(@campaign_id = 48)
	BEGIN
		declare @isEligible int
		declare @curWinnerSize int;
		declare @totalCount int;

		set @isEligible = 1;

		SELECT @curWinnerSize = image_name, @totalCount = option_type from winktag_survey_option where option_id = @option_id;


		IF ((select COUNT(*) from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id= @question_id) = 3) 
			set @isEligible = 0;

		IF EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id= @question_id and option_answer = '1') 
			set @isEligible = 0;


	   	IF (@isEligible = 1)
			BEGIN
				
				IF(@option = '1')
				BEGIN
					IF(@curWinnerSize = @totalCount)
					BEGIN
						set @option = '0';
					END
					ELSE
					BEGIN
						UPDATE [dbo].[winktag_survey_option]
						SET image_name= image_name + 1
						where option_id = @option_id;
					END
					
				END
				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count]
				)
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option,@answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count);
		
			END
		ELSE

			BEGIN
				SELECT '0' AS response_code, '
				Thank you! You have already participated!' as response_message
				return
			END
	END

	ELSE If(@campaign_id = 59)
	BEGIN
	   	IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and option_id = @option_id)
			BEGIN
				
				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count]
				)
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@vday2019_answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count);
		
			END
		ELSE

			BEGIN
				SELECT '0' AS response_code, '
				Thank you! You have already participated!' as response_message
				return
			END
	END

	ELSE IF(@campaign_id = 63)
	BEGIN
		INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
		([customer_id]
		,[campaign_id]
		,[question_id]
		,[option_id]
		,[option_answer]
		,[answer]
		,[created_at]
		,[question_no]
		,[row_count])
		VALUES
		(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count)
	END
	ELSE IF(@campaign_id = 99)
	BEGIN
		INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
		([customer_id]
		,[campaign_id]
		,[question_id]
		,[option_id]
		,[option_answer]
		,[answer]
		,[created_at]
		,[question_no]
		,[row_count])
		VALUES
		(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count)
	END
	ELSE If(@campaign_id = 101)
	BEGIN
	   	IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
			BEGIN
				DECLARE @lastEntry TIME;

				SELECT TOP (1) @lastEntry = cast (created_at as TIME)
				FROM [winkwink].[dbo].[winktag_customer_action_log] 
				WHERE campaign_id = 101 and customer_id = @customer_id ORDER BY created_at DESC;

				IF(DATEDIFF(MINUTE, @lastEntry, cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) AS Time)) >= 5)
				BEGIN
					SELECT '0' AS response_code, 'Oh what a pity, you&apos;ve taken too long!<br>Please restart the game now .' as response_message
					return
				END

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count]
				)
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option,@answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count);
		
			END
		ELSE

			BEGIN
				SELECT '0' AS response_code, '
				Thank you! You have already participated!' as response_message
				return
			END
	END

	ELSE IF(@campaign_id = 102)
	BEGIN
		if NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id = @question_id)
		BEGIN
			UPDATE winktag_customer_action_log SET survey_complete_status = 1 WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id;

			IF(@question_id = 291)
			BEGIN
				UPDATE qr_campaign SET redemption_status = '1' where customer_id = @customer_id AND campaign_id = @campaign_id;
				INSERT INTO [dbo].[winktag_customer_earned_points]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[created_at]
				,[GPS_location]
				,[ip_address]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@location,@ip_address,@row_count);
			END

			INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
			([customer_id]
			,[campaign_id]
			,[question_id]
			,[option_id]
			,[option_answer]
			,[answer]
			,[created_at]
			,[question_no]
			,[GPS_location]
			,[ip_address]
			,[row_count])
			VALUES
			(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@location,@ip_address,@row_count);

			

		END
		
	END
	ELSE IF(@campaign_id = 103)
	BEGIN
		if NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id = @question_id)
		BEGIN
			UPDATE winktag_customer_action_log SET survey_complete_status = 1 WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id;

			UPDATE qr_campaign SET redemption_status = '1' where customer_id = @customer_id AND campaign_id = @campaign_id;
		
			INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
			([customer_id]
			,[campaign_id]
			,[question_id]
			,[option_id]
			,[option_answer]
			,[answer]
			,[created_at]
			,[question_no]
			,[GPS_location]
			,[ip_address]
			,[row_count])
			VALUES
			(@customer_id,@campaign_id,@question_id,@option_id,@answer,@answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@location,@ip_address,@row_count);

		END
		
	END
	ELSE IF(@campaign_id = 110)
	BEGIN
		if NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and option_id = @option_id and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
			BEGIN
		
					INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
					([customer_id]
					,[campaign_id]
					,[question_id]
					,[option_id]
					,[option_answer]
					,[answer]
					,[created_at]
					,[question_no]
					,[row_count])
					VALUES
					(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count)
			
		END
	END
	ELSE IF(@campaign_id = 137 or @campaign_id = 116)
	BEGIN
		if NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and option_id = @option_id and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
			BEGIN
		
					INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
					([customer_id]
					,[campaign_id]
					,[question_id]
					,[option_id]
					,[option_answer]
					,[answer]
					,[created_at]
					,[question_no]
					,[row_count])
					VALUES
					(@customer_id,@campaign_id,@question_id,@option_id,@option,@answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count)
			
		END
	END
	ELSE If(@campaign_id = 128)
	BEGIN
	   	IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
			BEGIN
				DECLARE @lastDeepavaliEntry TIME;

				SELECT TOP (1) @lastDeepavaliEntry = cast (created_at as TIME)
				FROM [winkwink].[dbo].[winktag_customer_action_log] 
				WHERE campaign_id = 128 and customer_id = @customer_id ORDER BY created_at DESC;

				IF(DATEDIFF(MINUTE, @lastDeepavaliEntry, cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) AS Time)) >= 5)
				BEGIN
					SELECT '0' AS response_code, 'Oh what a pity, you&apos;ve taken too long!<br>Please restart the game now .' as response_message
					return
				END

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count]
				)
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option,@answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count);
		
			END
		ELSE

			BEGIN
				SELECT '0' AS response_code, '
				Thank you! You have already participated!' as response_message
				return
			END
	END
	ELSE IF(@campaign_id = 135)
	BEGIN
		INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
		([customer_id]
		,[campaign_id]
		,[question_id]
		,[option_id]
		,[option_answer]
		,[answer]
		,[created_at]
		,[question_no]
		,[row_count])
		VALUES
		(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count)
	END
	ELSE If(@campaign_id = 136)
	BEGIN
	   	IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and cast(created_at as date) = cast(@CURRENT_DATETIME as date))
			BEGIN
				DECLARE @gpLastEntry TIME;

				SELECT TOP (1) @gpLastEntry = cast (created_at as TIME)
				FROM [winkwink].[dbo].[winktag_customer_action_log] 
				WHERE campaign_id = 136 and customer_id = @customer_id ORDER BY created_at DESC;

				IF(DATEDIFF(MINUTE, @gpLastEntry, cast(@CURRENT_DATETIME AS Time)) >= 5)
				BEGIN
					SELECT '0' AS response_code, 'Oops sorry, you&apos;ve taken too long!<br>Please restart the game now .' as response_message
					return
				END

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count]
				)
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option,@answer,@CURRENT_DATETIME,@question_no,@row_count);
		
			END
		ELSE

			BEGIN
				SELECT '0' AS response_code, '
				Thank you! You have already participated!' as response_message
				return
			END
	END
	ELSE If(@campaign_id = 138)
	BEGIN
	   	IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
			BEGIN
				DECLARE @asLastEntry TIME;

				SELECT TOP (1) @asLastEntry = cast (created_at as TIME)
				FROM [winkwink].[dbo].[winktag_customer_action_log] 
				WHERE campaign_id = 138 and customer_id = @customer_id ORDER BY created_at DESC;

				IF(DATEDIFF(MINUTE, @asLastEntry, cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) AS Time)) >= 5)
				BEGIN
					SELECT '0' AS response_code, 'Oh what a pity, you&apos;ve taken too long!<br>Please restart the game now .' as response_message
					return
				END

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count]
				)
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option,@answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count);
		
			END
		ELSE

			BEGIN
				SELECT '0' AS response_code, '
				Thank you! You have already participated!' as response_message
				return
			END
	END

	ELSE IF(@campaign_id = 140)
	BEGIN
		IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and option_id = @option_id)
		BEGIN
			
			IF(@option = '1')
			BEGIN

				declare @CNYSushiInventory int;
				declare @CNYSushiCurCount int;

				SELECT @CNYSushiCurCount = image_name, @CNYSushiInventory = option_type from winktag_survey_option where option_id = @option_id;

				IF(@CNYSushiCurCount = @CNYSushiInventory)
				BEGIN
					set @option = '0';
				END
				ELSE
				BEGIN
					UPDATE [dbo].[winktag_survey_option]
					SET image_name= image_name + 1
					where option_id = @option_id;
				END
					
			END

			INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
			([customer_id]
			,[campaign_id]
			,[question_id]
			,[option_id]
			,[option_answer]
			,[answer]
			,[created_at]
			,[question_no]
			,[row_count]
			)
			VALUES
			(@customer_id,@campaign_id,@question_id,@option_id,@option,@answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count);
		
		END
		
		
		ELSE

			BEGIN
				SELECT '0' AS response_code, '
				Thank you! You have already participated!' as response_message
				return
			END
	END
	ELSE IF(@campaign_id = 141)
	BEGIN
		IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and option_id = @option_id)
		BEGIN
			
			IF(@option = '1')
			BEGIN

				declare @CNY2020Inventory int;
				declare @CNY2020CurCount int;

				SELECT @CNY2020CurCount = image_name, @CNY2020Inventory = option_type from winktag_survey_option where option_id = @option_id;

				print('winning inventory');
				print(@CNY2020Inventory)

				print('winning count');
				print(@CNY2020CurCount)

				IF(@CNY2020CurCount = @CNY2020Inventory)
				BEGIN

					declare @CNY20201Inventory int;
					declare @CNY20201CurCount int;

					SELECT @CNY20201CurCount = image_name, @CNY20201Inventory = option_type from winktag_survey_option where option_id = (@option_id+1);

					print('1 pt inventory');
					print(@CNY20201Inventory)

					print('1 pt count');
					print(@CNY20201CurCount)

					IF(@CNY20201CurCount < @CNY20201Inventory )
					BEGIN
						set @option = '0';

						UPDATE [dbo].[winktag_survey_option]
						SET image_name= image_name + 1
						where option_id = (@option_id+1);
					END
					ELSE
					BEGIN
						set @option = '2';
					END

					set @option_id = (@option_id+1);
					
				END
				ELSE
				BEGIN
					UPDATE [dbo].[winktag_survey_option]
					SET image_name= image_name + 1
					where option_id = @option_id;
				END
					
			END
			ELSE IF(@option = '0')
			BEGIN
				declare @CNY20200Inventory int;
				declare @CNY20200CurCount int;

				SELECT @CNY20200CurCount = image_name, @CNY20200Inventory = option_type from winktag_survey_option where option_id = @option_id;

				IF(@CNY20201CurCount = @CNY20201Inventory )
				BEGIN
					set @option = '2';
				END
				ELSE
				BEGIN
					UPDATE [dbo].[winktag_survey_option]
					SET image_name= image_name + 1
					where option_id = @option_id;
				END
			END

			INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
			([customer_id]
			,[campaign_id]
			,[question_id]
			,[option_id]
			,[option_answer]
			,[answer]
			,[created_at]
			,[question_no]
			,[row_count]
			)
			VALUES
			(@customer_id,@campaign_id,@question_id,@option_id,@option,@answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count);
		
		END
		
		
		ELSE

			BEGIN
				SELECT '0' AS response_code, '
				Thank you! You have already participated!' as response_message
				return
			END
	END
	ELSE IF(@campaign_id = 142)
	BEGIN
		if NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id = @question_id)
		BEGIN
			UPDATE winktag_customer_action_log SET survey_complete_status = 1 WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id;

			IF(@question_id = 409)
			BEGIN
				UPDATE qr_campaign SET redemption_status = '1' where customer_id = @customer_id AND campaign_id = @campaign_id;
				INSERT INTO [dbo].[winktag_customer_earned_points]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[created_at]
				,[GPS_location]
				,[ip_address]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@location,@ip_address,@row_count);
			END

			INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
			([customer_id]
			,[campaign_id]
			,[question_id]
			,[option_id]
			,[option_answer]
			,[answer]
			,[created_at]
			,[question_no]
			,[GPS_location]
			,[ip_address]
			,[row_count])
			VALUES
			(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@location,@ip_address,@row_count);

			

		END
		
	END
	ELSE IF(@campaign_id = 143)
	BEGIN
		INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
		([customer_id]
		,[campaign_id]
		,[question_id]
		,[option_id]
		,[option_answer]
		,[answer]
		,[created_at]
		,[question_no]
		,[row_count])
		VALUES
		(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count)
	END
	ELSE IF(@campaign_id = 146)
	BEGIN
		IF(@answer is null or @answer ='')
		SET @answer = ' '
	 	IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
		INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
		([customer_id]
		,[campaign_id]
		,[question_id]
		,[option_id]
		,[option_answer]
		,[answer]
		,[created_at]
		,[question_no]
		,[row_count])
		VALUES
		(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count)
	END
	ELSE If(@campaign_id = 151)
	BEGIN
		IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and option_id = @option_id)
		BEGIN
			DECLARE @referralRegTime datetime
			
			SELECT @referralRegTime = created_at, @wid = WID FROM customer WHERE customer_id = @customer_id;
			IF((@referralRegTime BETWEEN '2020-08-17 09:00:00.000' AND '2020-09-24 08:59:59.000') AND (@wid not like @answer))
			BEGIN
				--check if WID is valid
				IF NOT EXISTS(SELECT 1 FROM customer WHERE wid like @answer)
				BEGIN
					SELECT '0' AS response_code, 'Oops! That WINK+ ID is invalid. Please try again!' as response_message;
					RETURN
				END
				ELSE
				BEGIN
					INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
					([customer_id]
					,[campaign_id]
					,[question_id]
					,[option_id]
					,[option_answer]
					,[answer]
					,[created_at]
					,[question_no]
					,[row_count])
					VALUES
					(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count);
				END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Oops! That WINK+ ID is invalid. Please try again!' as response_message;
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Thank you! You have already participated!' as response_message;
			RETURN
		END
	END
	ELSE If(@campaign_id = 156)
	BEGIN
	   	IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and option_id = @option_id)
		BEGIN
			IF EXISTS (SELECT 1 FROM wink_thirdparty_codes WHERE campaignId = @campaign_id AND code like @answer AND usedStatus = 0)
			BEGIN
				UPDATE wink_thirdparty_codes
				SET usedStatus = 1, updatedAt = @CURRENT_DATETIME
				WHERE campaignId = @campaign_id 
				AND code like @answer 
				AND usedStatus = 0;

				IF @@ROWCOUNT > 0
				BEGIN
					INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
					([customer_id]
					,[campaign_id]
					,[question_id]
					,[option_id]
					,[option_answer]
					,[answer]
					,[created_at]
					,[question_no]
					,[row_count]
					)
					VALUES
					(@customer_id,@campaign_id,@question_id,@option_id,@option,@answer,@CURRENT_DATETIME,@question_no,@row_count);
				END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'That code is invalid.<br>Please try again.' as response_message
				return
			END

			
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Thank you! You have already participated!' as response_message
			RETURN
		END
	END

	ELSE IF(@campaign_id = 157)
	BEGIN
		if NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id = @question_id)
		BEGIN
			declare @survey_complete_status BIT;
			if (@question_id = 461) SET @survey_complete_status = 1
			else SET @survey_complete_status = 0

			UPDATE winktag_customer_action_log SET survey_complete_status = @survey_complete_status WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id;

			INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
			([customer_id]
			,[campaign_id]
			,[question_id]
			,[option_id]
			,[option_answer]
			,[answer]
			,[created_at]
			,[question_no]
			,[GPS_location]
			,[ip_address]
			,[row_count])
			VALUES
			(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@location,@ip_address,@row_count);

			

		END
		
	END
	ELSE If(@campaign_id = 160)
	BEGIN
	   	IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and option_id = @option_id)
		BEGIN
			IF EXISTS (SELECT 1 FROM wink_thirdparty_codes WHERE campaignId = @campaign_id AND code like @answer AND usedStatus = 0)
			BEGIN
				UPDATE wink_thirdparty_codes
				SET usedStatus = 1, updatedAt = @CURRENT_DATETIME
				WHERE campaignId = @campaign_id 
				AND code like @answer 
				AND usedStatus = 0;

				IF @@ROWCOUNT > 0
				BEGIN
					INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
					([customer_id]
					,[campaign_id]
					,[question_id]
					,[option_id]
					,[option_answer]
					,[answer]
					,[created_at]
					,[question_no]
					,[row_count]
					)
					VALUES
					(@customer_id,@campaign_id,@question_id,@option_id,@option,@answer,@CURRENT_DATETIME,@question_no,@row_count);
				END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Please enter a valid activation code.' as response_message
				return
			END

			
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Thank you! You have already participated!' as response_message
			RETURN
		END
	END
	ELSE If(@campaign_id = 162)
	BEGIN
	   	IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and option_id = @option_id)
		BEGIN
			IF EXISTS (SELECT 1 FROM wink_thirdparty_referral_codes WHERE campaignId = @campaign_id AND referralCode like @answer AND usedStatus = 0)
			BEGIN
				UPDATE wink_thirdparty_referral_codes
				SET usedStatus = 1, updatedAt = @CURRENT_DATETIME
				WHERE campaignId = @campaign_id 
				AND referralCode like @answer 
				AND usedStatus = 0;

				IF @@ROWCOUNT > 0
				BEGIN
					INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
					([customer_id]
					,[campaign_id]
					,[question_id]
					,[option_id]
					,[option_answer]
					,[answer]
					,[created_at]
					,[question_no]
					,[row_count]
					)
					VALUES
					(@customer_id,@campaign_id,@question_id,@option_id,@option,@answer,@CURRENT_DATETIME,@question_no,@row_count);
				END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Please enter a valid referral code.' as response_message
				return
			END

			
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Thank you! You have already participated!' as response_message
			RETURN
		END
	END
	
	--ELSE If(@campaign_id = 168)
	--BEGIN
	--	DECLARE @stlScanCount int;
	--	SELECT @stlScanCount = count(*)
	--	FROM customer_earned_points
	--	WHERE customer_id = @customer_id 
	--	AND qr_code like 'STL_MA2021_%'
	--	AND cast(created_at as date) between '2021-08-17' AND '2021-10-17';


	--   	IF ((select count(1) from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and option_id = @option_id)<@stlScanCount)
	--	BEGIN
	--		-- check user's daily limit
	--		--<insert code>

	--		INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
	--				([customer_id]
	--				,[campaign_id]
	--				,[question_id]
	--				,[option_id]
	--				,[option_answer]
	--				,[answer]
	--				,[created_at]
	--				,[question_no]
	--				,[row_count]
	--				)
	--		VALUES
	--		(@customer_id,@campaign_id,@question_id,@option_id,@option,@answer,@CURRENT_DATETIME,@question_no,@row_count);
	--	END
	--	ELSE
	--	BEGIN
	--		SELECT '0' AS response_code, 'Thank you! You have already participated!' as response_message
	--		RETURN
	--	END
	--END
	ELSE IF(@campaign_id = 169)
	BEGIN
		IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id = @question_id and created_at > @latestTrainingLinkDate)
		BEGIN
			UPDATE winktag_customer_action_log SET survey_complete_status = 1 WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id;

			DECLARE @staffTrainingPt int = 0;

			IF(@question_id = 503)
			BEGIN
				IF(@option_id = 2161)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 504)
			BEGIN
				IF(@option_id = 2167)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 505)
			BEGIN
				IF(@option_id = 2171)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 506)
			BEGIN
				IF(@option_id = 2175)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 507)
			BEGIN
				IF(@option_id = 2177)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 508)
			BEGIN
				IF(@option_id = 2181)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 509)
			BEGIN
				IF(@option_id = 2185)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 510)
			BEGIN
				IF(@option_id = 2188)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 511)
			BEGIN
				IF(@option_id = 2192)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 512)
			BEGIN
				IF(@option_id = 2197)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 513)
			BEGIN
				IF(@option_id = 2201)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 514)
			BEGIN
				IF(@option_id = 2203)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 515)
			BEGIN
				IF(@option_id = 2206)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 516)
			BEGIN
				IF(@option_id = 2211)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 517)
			BEGIN
				IF(@option_id = 2215)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 518)
			BEGIN
				IF(@option_id = 2218)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 519)
			BEGIN
				IF(@option_id = 2221)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 520)
			BEGIN
				IF(@option_id = 2224)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 521)
			BEGIN
				IF(@option_id = 2226)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 522)
			BEGIN
				IF(@option_id = 2228)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 523)
			BEGIN
				IF(@option_id = 2232)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 524)
			BEGIN
				IF(@option_id = 2236)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 525)
			BEGIN
				IF(@option_id = 2240)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 526)
			BEGIN
				IF(@option_id = 2242)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END
			ELSE IF(@question_id = 527)
			BEGIN
				IF(@option_id = 2244)
				BEGIN
					SET @staffTrainingPt = 1;
				END
			END

			IF NOT EXISTS (SELECT 1 FROM winktag_customer_earned_points WHERE campaign_id = @campaign_id AND customer_id = @customer_id and created_at > @latestTrainingLinkDate)
			BEGIN
				INSERT INTO [dbo].[winktag_customer_earned_points]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[created_at]
				,[GPS_location]
				,[ip_address]
				,[additional_point_status]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@location,@ip_address,0,@row_count);
			END

			INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
			([customer_id]
			,[campaign_id]
			,[question_id]
			,[option_id]
			,[option_answer]
			,[answer]
			,[created_at]
			,[question_no]
			,[GPS_location]
			,[ip_address]
			,[row_count])
			VALUES
			(@customer_id,@campaign_id,@question_id,@option_id,@staffTrainingPt,@option_answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@location,@ip_address,@row_count);
			
		END
	END
	ELSE IF(@campaign_id = 170)
	BEGIN
		DECLARE @invalidMsg varchar(250) = 'Oops, you seem to have keyed in an invalid code.<br>Do double check the code that was sent to your email and enter it below!';
		IF NOT EXISTS(select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id = @question_id)
		BEGIN
			-- check if the input code has been used or valid
			IF EXISTS (SELECT 1 FROM wink_thirdparty_codes WHERE campaignId = @campaign_id AND code like @answer AND usedStatus = 0)
			BEGIN
				UPDATE wink_thirdparty_codes
				SET usedStatus = 1, updatedAt = @CURRENT_DATETIME
				WHERE campaignId = @campaign_id 
				AND code like @answer 
				AND usedStatus = 0;

				UPDATE winktag_customer_action_log 
				SET survey_complete_status = 1
				WHERE customer_id = @customer_id 
				AND CAMPAIGN_ID = @campaign_id;

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option,@answer,@CURRENT_DATETIME,@question_no,@row_count);

				IF NOT EXISTS (SELECT 1 FROM winktag_customer_earned_points WHERE campaign_id = @campaign_id AND customer_id = @customer_id)
				BEGIN
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
				   (@campaign_id,@question_id,@customer_id,0,@location,@ip_address,@CURRENT_DATETIME,@row_count)
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

				INSERT INTO [dbo].[customer_card_types]
					   ([customerId]
					   ,[cardType]
					   ,[createdAt]
					   ,[updatedAt])
				 VALUES
					   (@customer_id
					   ,SUBSTRING(@answer, 1,  2)
					   ,@CURRENT_DATETIME
					   ,@CURRENT_DATETIME);
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, @invalidMsg as response_message
				return
			END
		END
		ELSE
		BEGIN
			DECLARE @curCode varchar(250);

			SELECT @curCode = answer 
			FROM [dbo].[winktag_customer_survey_answer_detail]
			WHERE campaign_id = @campaign_id
			AND customer_id = @customer_id;

			IF(@curCode like @answer)
			BEGIN
				SELECT '0' AS response_code, 'Oops, it seems that you have already entered this code.<br>Head over to WINK+ Gates and start earning points!' as response_message
				return
			END
			ELSE IF(@answer like 'OT%')
			BEGIN
				SELECT '0' AS response_code, 'Oops! You have already unleashed the WINK+ GATES.<br>To upgrade and see other exclusive WINK+ GATES locations, please register your Mastercard&reg; into your SimplyGo app and retrieve your special code.' as response_message
				return
			END

			-- if user has only entered an OT code
			IF(@curCode not like '%MC%')
			BEGIN
				-- check if the code entered starts with MC
				IF(@answer like 'MC%')
				BEGIN
					IF EXISTS (SELECT 1 FROM wink_thirdparty_codes WHERE campaignId = @campaign_id AND code like @answer AND usedStatus = 0)
					BEGIN

						IF(
							(SELECT group_id FROM customer WHERE customer_id= @customer_id) 
							not like '2'
						)
						BEGIN
							UPDATE customer
							SET group_id = '2'
							WHERE customer_id= @customer_id;
						END

						UPDATE wink_thirdparty_codes
						SET usedStatus = 1, updatedAt = @CURRENT_DATETIME
						WHERE campaignId = @campaign_id 
						AND code like @answer 
						AND usedStatus = 0;

						DECLARE @newAns varchar(250) = @curCode+','+@answer;

						UPDATE [dbo].[winktag_customer_survey_answer_detail]
						SET option_answer = @newAns, answer = @newAns
						WHERE customer_id = @customer_id
						AND campaign_id = @campaign_id;

						UPDATE [dbo].[customer_card_types]
						SET cardType = 'OT/MC', updatedAt = @CURRENT_DATETIME
						WHERE customerId = @customer_id;

					END
					ELSE
					BEGIN
						SELECT '0' AS response_code, @invalidMsg as response_message
						return
					END
				END
				ELSE
				BEGIN
					SELECT '0' AS response_code, @invalidMsg as response_message
					RETURN
				END
			END	
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'You have already entered a code for this campaign.' as response_message
				return
			END
		END
	END
	ELSE If(@campaign_id = 173)
	BEGIN
	   	IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and option_id = @option_id)
		BEGIN
			IF EXISTS (SELECT 1 FROM wink_thirdparty_codes WHERE campaignId = @campaign_id AND code like @answer AND usedStatus = 0)
			BEGIN
				UPDATE wink_thirdparty_codes
				SET usedStatus = 1, updatedAt = @CURRENT_DATETIME
				WHERE campaignId = @campaign_id 
				AND code like @answer 
				AND usedStatus = 0;

				IF(@@ROWCOUNT > 0)
				BEGIN
					INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
					([customer_id]
					,[campaign_id]
					,[question_id]
					,[option_id]
					,[option_answer]
					,[answer]
					,[created_at]
					,[question_no]
					,[row_count]
					)
					VALUES
					(@customer_id,@campaign_id,@question_id,@option_id,@option,@answer,@CURRENT_DATETIME,@question_no,@row_count);
				END
				ELSE
				BEGIN
					SELECT '0' AS response_code, 'Please try again later.' as response_message
					return
				END	
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Oops! The code you have entered is invalid.' as response_message
				return
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Oops! Looks like you have already received your points!' as response_message
			RETURN
		END
	END
	--ELSE IF(@campaign_id = 174)
	--BEGIN
	--	IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and option_id = @option_id and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
	--	BEGIN
	--		DECLARE @totalPtsInventory int = 168000;
	--		DECLARE @campaignStart datetime = '2021-11-25 05:30:00.000';
	--		DECLARE @campaignEnd datetime = '2021-12-31 23:59:59.000';

	--		IF(@CURRENT_DATETIME BETWEEN @campaignStart AND @campaignEnd)
	--		BEGIN
	--			DECLARE @totalIssuedPts int = 0;

	--			select @totalIssuedPts= ISNULL(SUM(points),0)
	--			from (
	--				SELECT points FROM customer_earned_points 
	--				WHERE (qr_code like 'MBXMAS%' AND qr_code not like 'MBXMAS_WINK%')

	--				UNION ALL

	--				SELECT points FROM winktag_customer_earned_points
	--				WHERE campaign_id = @campaign_id
	--			) as issuedPts;

	--			print('total points issued');
	--			print(@totalIssuedPts);
	--			IF(@totalPtsInventory > @totalIssuedPts)
	--			BEGIN
	--				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
	--				([customer_id]
	--				,[campaign_id]
	--				,[question_id]
	--				,[option_id]
	--				,[option_answer]
	--				,[answer]
	--				,[created_at]
	--				,[question_no]
	--				,[row_count])
	--				VALUES
	--				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
	--			END
	--			ELSE
	--			BEGIN
	--				SELECT '0' AS response_code, 'Oh no! We have run out of points. Better luck next time!' as response_message
	--				RETURN
	--			END
	--		END
	--		ELSE
	--		BEGIN
	--			SELECT '0' AS response_code, 'This campaign has ended.' as response_message
	--			RETURN
	--		END
			
	--	END
	--	ELSE
	--	BEGIN
	--		SELECT '0' AS response_code, 'Don''t be naughty! You''ve voted! Come another day to vote again!' as response_message
	--		RETURN
	--	END
	--END
	ELSE IF(@campaign_id = 175)
	BEGIN
		IF NOT EXISTS (
			select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and option_id = @option_id 
			and cast(created_at as date) = cast(@CURRENT_DATETIME as date)
		)
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
				DECLARE @merchCodeOptId int = 2256;
				DECLARE @spendAmtOptId int = 2257;
				DECLARE @msgInvalidCode varchar(50) = 'Invalid code, please try again';

				IF(@option_id = @merchCodeOptId)
				BEGIN
					IF NOT EXISTS(
						SELECT 1 
						FROM winktag_redemption_staffs
						WHERE campaign_id = @campaign_id
						AND staff_status like '1'
						AND staff_code like @option_answer
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvalidCode as response_message
						RETURN
					END
				END

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
			
				IF(@option_id = @merchCodeOptId)
				BEGIN
					SELECT @option_answer = staff_name
					FROM winktag_redemption_staffs
					WHERE campaign_id = @campaign_id
					AND staff_status like '1'
					AND staff_code like @answer;
				END
				ELSE IF(@option_id = @spendAmtOptId)
				BEGIN
					IF NOT EXISTS(
						SELECT 1
						FROM winktag_customer_survey_answer_detail
						WHERE campaign_id = @campaign_id
						AND customer_id = @customer_id
						AND CAST(created_at AS DATE) = CAST(@CURRENT_DATETIME AS DATE)
						AND option_id = @merchCodeOptId
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvalidCode as response_message
						RETURN
					END
				END

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, promotion has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'WINK+ points redemption limit met for the day' as response_message
			RETURN
		END
	END
	ELSE IF(@campaign_id = 184)
	BEGIN
		DECLARE @internalAcqNewUser int = 0;
		if(
			(SELECT created_at
			FROM CUSTOMER
			WHERE customer_id = @customer_id) BETWEEN
			'2016-06-08 09:00:00.000'
			AND
			'2025-12-31 23:59:59.000'
		)
		BEGIN
			SET @internalAcqNewUser = 1;
		END

		IF(@internalAcqNewUser = 1)
		BEGIN
			IF NOT EXISTS (
			select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and option_id = @option_id 
			)
			BEGIN
				IF EXISTS (
					SELECT 1
					FROM smrt_staff_id
					WHERE staff_id = @answer
				)
				BEGIN
					INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
					([customer_id]
					,[campaign_id]
					,[question_id]
					,[option_id]
					,[option_answer]
					,[answer]
					,[created_at]
					,[question_no]
					,[row_count])
					VALUES
					(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@answer,@CURRENT_DATETIME,@question_no,@row_count);
				END
				ELSE
				BEGIN
					SELECT '0' AS response_code, 'Oops! Please double check your STAFF ID and try again!' as response_message
					RETURN
				END
				
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you! You have already participated!' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Oops! Looks like you have already downloaded WINK+ before!' as response_message
			RETURN
		END
		
	END
	ELSE If(@campaign_id = 185)
	BEGIN
		IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and option_id = @option_id)
		BEGIN
			DECLARE @internalRefNewUser int = 0;
			if(
				(SELECT created_at
				FROM CUSTOMER
				WHERE customer_id = @customer_id) BETWEEN
				'2016-06-08 09:00:00.000'
				AND
				'2025-12-31 23:59:59.000'
			)
			BEGIN
				SET @internalRefNewUser = 1;
			END

			
			IF(@internalRefNewUser = 1)
			BEGIN
				IF EXISTS (
					SELECT 1
					FROM smrt_staff_id
					WHERE staff_id = @answer
				)
				BEGIN
					DECLARE @internalAcqAns varchar(250)

					SELECT @internalAcqAns = answer
					FROM [dbo].[winktag_customer_survey_answer_detail]
					WHERE campaign_id = 184;

					IF(@internalAcqAns not like @answer)
					BEGIN
						INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
						([customer_id]
						,[campaign_id]
						,[question_id]
						,[option_id]
						,[option_answer]
						,[answer]
						,[created_at]
						,[question_no]
						,[row_count])
						VALUES
						(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@answer,@CURRENT_DATETIME,@question_no,@row_count);
					END
					ELSE
					BEGIN
						SELECT '0' AS response_code, 'Oops! You cannot enter your own STAFF ID' as response_message
						RETURN
					END
				END
				ELSE
				BEGIN
					SELECT '0' AS response_code, 'Oops! Please double check the STAFF ID and try again!' as response_message
					RETURN
				END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Oops! Looks like you have already downloaded WINK+ before!' as response_message;
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Thank you! You have already participated!' as response_message;
			RETURN
		END
	END
	ELSE IF(@campaign_id = 187)
    BEGIN
		IF NOT EXISTS (
			select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and question_id = @question_id 
			and cast(created_at as date) = cast(@CURRENT_DATETIME as date)
		)
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

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, promotion has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'redemption limit met for the day' as response_message
			RETURN
		END
	END	
	-- SMRT 35 Anniversary Phase 1 --
	ELSE IF(@campaign_id = 189)
    BEGIN
		IF NOT EXISTS (
			select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and question_id = @question_id 
			and cast(created_at as date) = cast(@CURRENT_DATETIME as date)
		)
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

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'redemption limit met for the day' as response_message
			RETURN
		END
	END
		-- SMRT35thAnniversaryPhase2--
	ELSE IF(@campaign_id = 191)
    BEGIN
		IF NOT EXISTS (
			select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and question_id = @question_id 
			and cast(created_at as date) = cast(@CURRENT_DATETIME as date)
		)
		BEGIN
			
			DECLARE @SMRT35thAnniPhase2fromDate datetime = '2022-10-20 09:00:00.000';
			DECLARE @SMRT35thAnniPhase2ToDate datetime = '2023-11-03 23:59:59.000';

			IF(@CURRENT_DATETIME BETWEEN @SMRT35thAnniPhase2fromDate AND @SMRT35thAnniPhase2ToDate)
			BEGIN

				DECLARE @SMRT35thAnniPhase2Inventory int = 6500;
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

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'redemption limit met for the day' as response_message
			RETURN
		END
	END
	-- SMRT35thAnniversaryPhase3--
	ELSE IF(@campaign_id = 194)
    BEGIN
		IF NOT EXISTS (
			select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and question_id = @question_id 
			and cast(created_at as date) = cast(@CURRENT_DATETIME as date)
		)
		BEGIN
			
			DECLARE @SMRT35thAnniPhase3fromDate datetime = '2022-11-10 09:00:00.000';
			DECLARE @SMRT35thAnniPhase3ToDate datetime = '2023-11-10 23:59:59.000';

			IF(@CURRENT_DATETIME BETWEEN @SMRT35thAnniPhase3fromDate AND @SMRT35thAnniPhase3ToDate)
			BEGIN

				DECLARE @SMRT35thAnniPhase3Inventory int = 6500;
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

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'redemption limit met for the day' as response_message
			RETURN
		END
	END
	-- SMRT35thAnniversaryPhase4--
	ELSE IF(@campaign_id = 198)
    BEGIN
		IF NOT EXISTS (
			select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and question_id = @question_id 
			and cast(created_at as date) = cast(@CURRENT_DATETIME as date)
		)
		BEGIN
			
			DECLARE @SMRT35thAnniPhase4fromDate datetime = '2022-11-29 09:00:00.000';
			DECLARE @SMRT35thAnniPhase4ToDate datetime = '2023-12-18 23:59:59.000';

			IF(@CURRENT_DATETIME BETWEEN @SMRT35thAnniPhase4fromDate AND @SMRT35thAnniPhase4ToDate)
			BEGIN

				DECLARE @SMRT35thAnniPhase4Inventory int = 6500;
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

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'redemption limit met for the day' as response_message
			RETURN
		END
	END
	--SMRT35thAnniversaryPhase5--
	ELSE IF(@campaign_id = 199)
    BEGIN
		IF NOT EXISTS (
			select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and question_id = @question_id 
			and cast(created_at as date) = cast(@CURRENT_DATETIME as date)
		)
		BEGIN
			
			DECLARE @SMRT35thAnniPhase5fromDate datetime = '2022-12-09 09:00:00.000';
			DECLARE @SMRT35thAnniPhase5ToDate datetime = '2024-01-02 23:59:59.000';

			IF(@CURRENT_DATETIME BETWEEN @SMRT35thAnniPhase5fromDate AND @SMRT35thAnniPhase5ToDate)
			BEGIN

				DECLARE @SMRT35thAnniPhase5Inventory int = 7000;
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

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'redemption limit met for the day' as response_message
			RETURN
		END
	END

	--SMRT35thAnniversaryPhase6--
	ELSE IF(@campaign_id = 200)
    BEGIN
		IF NOT EXISTS (
			select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and question_id = @question_id 
			and cast(created_at as date) = cast(@CURRENT_DATETIME as date)
		)
		BEGIN
			
			DECLARE @SMRT35thAnniPhase6fromDate datetime = '2022-12-28 09:00:00.000';
			DECLARE @SMRT35thAnniPhase6ToDate datetime = '2024-01-15 23:59:59.000';

			IF(@CURRENT_DATETIME BETWEEN @SMRT35thAnniPhase6fromDate AND @SMRT35thAnniPhase6ToDate)
			BEGIN

				DECLARE @SMRT35thAnniPhase6Inventory int = 6000;
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

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'redemption limit met for the day' as response_message
			RETURN
		END
	END

	--SMRT35thAnniversaryPhase7--
	ELSE IF(@campaign_id = 201)
    BEGIN
		IF NOT EXISTS (
			select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and question_id = @question_id 
			and cast(created_at as date) = cast(@CURRENT_DATETIME as date)
		)
		BEGIN
			
			DECLARE @SMRT35thAnniPhase7fromDate datetime = '2023-01-04 09:00:00.000';
			DECLARE @SMRT35thAnniPhase7ToDate datetime = '2024-01-04 23:59:59.000';

			IF(@CURRENT_DATETIME BETWEEN @SMRT35thAnniPhase7fromDate AND @SMRT35thAnniPhase7ToDate)
			BEGIN

				DECLARE @SMRT35thAnniPhase7Inventory int = 6500;
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

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'redemption limit met for the day' as response_message
			RETURN
		END
	END

	-- GreenLiving--
	ELSE IF(@campaign_id = 197)
    BEGIN
		IF NOT EXISTS (
			select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and question_id = @question_id 
			
		)
		BEGIN
			
			DECLARE @GreenLivingfromDate datetime = '2022-11-16 08:30:00.000';
			DECLARE @GreenLivingToDate datetime = '2023-11-16 09:01:57.927';

			IF(@CURRENT_DATETIME BETWEEN @GreenLivingfromDate AND @GreenLivingToDate)
			BEGIN

				DECLARE @GreenLivingInventory int = 500;
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

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'redemption limit met for the day' as response_message
			RETURN
		END
	END

	-- Client Satisfaction 2023
	ELSE IF(@campaign_id = 193)
    BEGIN
		IF NOT EXISTS (
			select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and option_id = @option_id
		)
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

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'You have already participated in this survey!' as response_message
			RETURN
		END
	END

    -- Bus Shelter Tender Survey 2023
	ELSE IF(@campaign_id = 204)
    BEGIN
		IF NOT EXISTS (
			select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and option_id = @option_id
		)
		BEGIN
			
			DECLARE @BusShelterTenderfromDate datetime = '2023-04-14 09:15:00.000';
			DECLARE @BusShelterTenderToDate datetime = '2023-05-12 23:59:59.000';

			IF(@CURRENT_DATETIME BETWEEN @BusShelterTenderfromDate AND @BusShelterTenderToDate)
			BEGIN

				DECLARE @BusShelterTenderInventory int = 500;	
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

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'You have already participated in this survey!' as response_message
			RETURN
		END
	END
    -- TownHallHiveSurvey2023 
	ELSE IF(@campaign_id = 208)
    BEGIN
		IF NOT EXISTS (
			select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and option_id = @option_id
		)
		BEGIN
			
			DECLARE @TownHallHiveSurvey2023fromDate datetime = '2023-06-20 09:00:00.000';
			DECLARE @TownHallHiveSurvey2023ToDate datetime = '2023-07-20 23:59:59.000';

			IF(@CURRENT_DATETIME BETWEEN @TownHallHiveSurvey2023fromDate AND @TownHallHiveSurvey2023ToDate)
			BEGIN

				DECLARE @TownHallHiveSurvey2023Inventory int = 135;	
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

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'You have already participated in this survey!' as response_message
			RETURN
		END
	END
    -- Town Hall 2023 Marsiling Staytion Survey
	ELSE IF(@campaign_id = 210)
    BEGIN
		IF NOT EXISTS (
			select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and option_id = @option_id
		)
		BEGIN
			
			DECLARE @TownHall2023MarsilingStaytionfromDate datetime = '2023-06-21 17:10:00.000';
			DECLARE @TownHall2023MarsilingStaytionToDate datetime = '2023-06-23 18:00:00.000';

			IF(@CURRENT_DATETIME BETWEEN @TownHall2023MarsilingStaytionfromDate AND @TownHall2023MarsilingStaytionToDate)
			BEGIN

				DECLARE @TownHall2023MarsilingStaytionInventory int = 135;	
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

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'You''ve scanned this! Head to WINK+ play to do the quiz now!' as response_message
			RETURN
		END
	END
    --WinkHuntSurveyP1Campaign--
	ELSE IF(@campaign_id = 215)
    BEGIN
		IF NOT EXISTS (
		select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and option_id = @option_id	
		)
		BEGIN
			
			DECLARE @WinkHuntSurveyP1CampaignfromDate datetime = '2023-09-06 09:00:00.000';
			DECLARE @WinkHuntSurveyP1CampaignToDate datetime = '2023-09-30 23:59:59.000';

			IF(@CURRENT_DATETIME BETWEEN @WinkHuntSurveyP1CampaignfromDate AND @WinkHuntSurveyP1CampaignToDate)
			BEGIN

				DECLARE @WinkHuntSurveyP1CampaignInventory int = 5000;
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

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Oops! You just missed out! Stay tuned for more promotions!' as response_message
			RETURN
		END
	END
    
	    --WinkHuntSurveyP2Campaign--
	ELSE IF(@campaign_id = 218)
    BEGIN
		IF NOT EXISTS (
		select 1 
			from winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and customer_id = @customer_id 
			and option_id = @option_id	
		)
		BEGIN
			
			DECLARE @WinkHuntSurveyP2CampaignfromDate datetime = '2023-09-20 09:00:00.000';
			DECLARE @WinkHuntSurveyP2CampaignToDate datetime = '2023-10-03 23:59:59.000';

			IF(@CURRENT_DATETIME BETWEEN @WinkHuntSurveyP2CampaignfromDate AND @WinkHuntSurveyP2CampaignToDate)
			BEGIN

				DECLARE @WinkHuntSurveyP2CampaignInventory int = 10;
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

				INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
				([customer_id]
				,[campaign_id]
				,[question_id]
				,[option_id]
				,[option_answer]
				,[answer]
				,[created_at]
				,[question_no]
				,[row_count])
				VALUES
				(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, survey has ended' as response_message
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Oops! You just missed out! Stay tuned for more promotions!' as response_message
			RETURN
		END
	END
	 --WinkHuntRewardCards--
	ELSE IF(@campaign_id = 217)
    BEGIN
				
			DECLARE @WinkHuntRewardCardsfromDate datetime = '2023-09-12 09:00:00.000';
			DECLARE @WinkHuntRewardCardsToDate datetime = '2023-09-30 23:59:59.000';

			IF(@CURRENT_DATETIME BETWEEN @WinkHuntRewardCardsfromDate AND @WinkHuntRewardCardsToDate)
			BEGIN

				DECLARE @WinkHuntRewardCardsInventory int = 100;
				DECLARE @msgInvExhaustedWinkHuntRewardCards varchar(150) = 'Oops! You just missed out! Stay tuned for more promotions!';
				--check campaign size
				IF(
						(
							SELECT COUNT(1)
							FROM winktag_customer_earned_points
							WHERE campaign_id = @campaign_id
							AND (created_at BETWEEN @WinkHuntRewardCardsfromDate AND @WinkHuntRewardCardsToDate)
						) >= @WinkHuntRewardCardsInventory
					)
					BEGIN
						SELECT '0' AS response_code, @msgInvExhaustedWinkHuntRewardCards as response_message
						RETURN
					END
					--check valid code --
					IF EXISTS(SELECT * from TBL_WINKPLAY_WINKHUNT_CODES where promo_code like @option_answer AND used_status = 0 AND campaign_id=217)
					BEGIN
						--insert into
						INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
						([customer_id]
						,[campaign_id]
						,[question_id]
						,[option_id]
						,[option_answer]
						,[answer]
						,[created_at]
						,[question_no]
						,[row_count])
						VALUES
						(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,@CURRENT_DATETIME,@question_no,@row_count)
					
					END
					ELSE
					BEGIN
						SELECT '0' AS response_code, 'Oops! That code seems invalid! Try again!' as response_message
						RETURN
					END
				
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Thank you for your participation, campaign has ended' as response_message
				RETURN
			END
		END
		--ELSE
		--BEGIN
		--	SELECT '0' AS response_code, 'redemption limit met for the day' as response_message
		--	RETURN
		--END
	--END
	ELSE
	BEGIN
		IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and option_id = @option_id)
		BEGIN			
			INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
			([customer_id]
			,[campaign_id]
			,[question_id]
			,[option_id]
			,[option_answer]
			,[answer]
			,[created_at]
			,[question_no]
			,[row_count])
			VALUES
			(@customer_id,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count)
		END
		ELSE
		BEGIN
			print('exists');
			SELECT '0' AS response_code, '
			Thank you! You have already participated!' as response_message
			return
		END 
	END

	END
	 
		 
	IF @@ROWCOUNT > 0
	BEGIN
		If(@campaign_id = 27)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be notified soon!' as response_message
			return

		END
		ELSE If(@campaign_id = 28)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be notified soon!' as response_message
			return

		END
		ELSE If(@campaign_id = 32)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be notified soon!' as response_message
			return

		END
		ELSE If(@campaign_id = 35)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be announced soon.' as response_message
			return

		END
		ELSE If(@campaign_id = 38)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be announced soon.' as response_message
			return

		END
		ELSE If(@campaign_id = 39)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be announced soon.' as response_message
			return

		END
		ELSE If(@campaign_id = 34)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!  ' as response_message
			return

		END
		ELSE If(@campaign_id = 40)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 25 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 41)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be notified via email.' as response_message
			return

		END
		ELSE If(@campaign_id = 42)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be notified via email.' as response_message
			return

		END
		ELSE If(@campaign_id = 43)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be notified via email.' as response_message
			return

		END
		ELSE If(@campaign_id = 44)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 25 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 45)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 20 WINK<sup>+</sup> points.<br><br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.
			<br><br>To earn an additional 25 WINK<sup>+</sup> points, you may choose to book an appointment with Trichokare!' as response_message
			return

		END
		ELSE IF(@campaign_id = 46)
		BEGIN
			print(@option);
			IF(@option = '0')
			BEGIN
				SELECT '1' AS response_code, 'Thank you for your entry.<br>Good luck!' as response_message
				return
			END
			ELSE IF(@option = '1')
			BEGIN
				SELECT '2' AS response_code, 'Congratulations!<br>You Have Won a Festive Prize!<br><br>Please refer to your email for details of prize collection.' as response_message
				return
			END

		END
		ELSE If(@campaign_id = 54)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 5 WINK<sup>+</sup> points.<br><br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.
			<br><br>To earn an additional 15 WINK<sup>+</sup> points, just make an appointment with Shakura Pigmentation Beauty now! 
			<br><br><sup>*</sup>T&Cs Apply' as response_message
			return

		END
		ELSE If(@campaign_id = 56)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 20 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END	
		ELSE IF(@campaign_id = 48)
		BEGIN
			print(@option);
			IF(@option = '0')
			BEGIN
				
				SELECT '1' AS response_code, 'Thank you for your entry.<br>Good luck!' as response_message
				return
			
			END
			ELSE IF(@option = '1')
			BEGIN
				SELECT '2' AS response_code, 'Congratulations, you have won!<br>Winners will be notified in 5 - 7 working days via the email registered on your WINK+ account.' as response_message
				return
			END

		END
		ELSE If(@campaign_id = 59)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be notified via email.' as response_message
			return

		END
		ELSE If(@campaign_id = 60)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be notified via email.' as response_message
			return

		END
		ELSE If(@campaign_id = 62)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for your entry! Winners will be contacted soon via email!' as response_message
			return

		END
		ELSE If(@campaign_id = 63 or @campaign_id = 99  or @campaign_id = 143)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winner will be notified via email.' as response_message
			return

		END
		ELSE If(@campaign_id = 64)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 66)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for your entry!' as response_message
			return

		END
		ELSE If(@campaign_id = 67)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for your entry!' as response_message
			return

		END
		ELSE IF(@campaign_id = 69)
		BEGIN
			
			IF (select option_id from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id = 181) = 1030
			BEGIN
				SELECT '1' AS response_code, 'Thank you for your entry!' as response_message
				return
			END
			ELSE
				BEGIN
					SELECT '1' AS response_code, 'Sorry no WINK<sup style="line-height: 0px;">+</sup> points earned.<br>You didn''t select the correct safety message.<br>Better luck next time!' as response_message
					return
				END


		END
		ELSE IF(@campaign_id = 70)
		BEGIN
			
			IF (select option_id from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id = 190) = 1097
			BEGIN
				SELECT '1' AS response_code, 'Thank you for your entry!' as response_message
				return
			END
			ELSE
				BEGIN
					SELECT '1' AS response_code, 'Sorry no WINK<sup style="line-height: 0px;">+</sup> points earned.<br>You didn''t select the correct safety message.<br>Better luck next time!' as response_message
					return
				END


		END

		ELSE If(@campaign_id = 71)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END

		ELSE If(@campaign_id = 72)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 74)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 25 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END

		ELSE IF(@campaign_id = 75)
		BEGIN
			
			IF (select option_id from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id = 203) = 1169
			BEGIN
				SELECT '1' AS response_code, 'Thank you for your entry!' as response_message
				return
			END
			ELSE
				BEGIN
					SELECT '1' AS response_code, 'Sorry no WINK<sup style="line-height: 0px;">+</sup> points earned.<br>You didn''t select the correct safety message.<br>Better luck next time!' as response_message
					return
				END


		END

		ELSE If(@campaign_id = 76)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 77)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 85)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for your entry!' as response_message
			return

		END
		ELSE If(@campaign_id = 95)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE IF(@campaign_id = 97)
		BEGIN
			
			IF (select option_id from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id = 241) = 1340
			BEGIN
				SELECT '1' AS response_code, 'Thank you for your entry!' as response_message
				return
			END
			ELSE
				BEGIN
					SELECT '1' AS response_code, 'Sorry no WINK<sup style="line-height: 0px;">+</sup> points earned.<br>You didn''t select the correct safety message.<br>Better luck next time!' as response_message
					return
				END


		END
		
		ELSE If(@campaign_id = 138 or @campaign_id = 101)
		BEGIN

			SELECT '1' AS response_code, 'Woohoo! You have completed the game in '+@answer+'!<br>Winners will be notified via the email address registered on their WINK+ accounts.' as response_message
			return

		END
		ELSE IF(@campaign_id = 104)
		BEGIN
			
			IF (select option_id from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id = 293) = 1483
			BEGIN
				SELECT '1' AS response_code, 'Thank you for your entry!' as response_message
				return
			END
			ELSE
				BEGIN
					SELECT '1' AS response_code, 'Sorry no WINK<sup style="line-height: 0px;">+</sup> points earned.<br>You didn''t select the correct safety message.<br>Better luck next time!' as response_message
					return
				END


		END
		ELSE If(@campaign_id = 105)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be notified via email.' as response_message
			return

		END
		ELSE If(@campaign_id = 106)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 50 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 107)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be notified via email.' as response_message
			return

		END
		ELSE If(@campaign_id = 108)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 109)
		BEGIN

			SELECT '1' AS response_code, 'Thank you! Shortlisted WINK<sup>+</sup> Champ Leaders will be contacted via email.' as response_message
			return

		END
		ELSE If(@campaign_id = 111)
		BEGIN
			DECLARE @registration datetime
			DECLARE @pts varchar(10)

			SELECT @registration = created_at from customer where customer_id = @customer_id;
			IF(@registration BETWEEN '2019-07-10 08:00:00.000' AND '2019-07-16 23:59:59.000')
			BEGIN
				SET @pts = '100';
			END
			ELSE
			BEGIN
				SET @pts = '50';
			END

			SELECT '1' AS response_code, 'Congrats! '+@pts+' WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 113)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 50 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 114)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 115)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 117)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 118)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 119)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be notified via email.' as response_message
			return

		END
		ELSE If(@campaign_id = 137 or @campaign_id = 116)
		BEGIN

			SELECT '1' AS response_code, 'Play daily to hit your highest score! Winners will be notified via the email address registered on your account.' as response_message
			return

		END
		ELSE If(@campaign_id = 120)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 125)
		BEGIN

			
			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 126)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be notified via email. See you at Gardens by the Bay for ''Neon Jungle'' (18 - 27 Oct)!' as response_message
			return

		END

		ELSE If(@campaign_id = 127)
		BEGIN
			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return
		END

		ELSE If(@campaign_id = 128)
		BEGIN

			SELECT '1' AS response_code, 'Woohoo! You have completed the game in '+@answer+'!<br>Winners will be notified via the email address registered on your WINK+ account.' as response_message
			return

		END
		ELSE If(@campaign_id = 129)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 132)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be notified via email.' as response_message
			return

		END
		ELSE If(@campaign_id = 133)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winners will be notified via email.' as response_message
			return

		END
		ELSE If(@campaign_id = 135)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winner will be notified via email.' as response_message
			return

		END
		ELSE If(@campaign_id = 136)
		BEGIN

			SELECT '1' AS response_code, 'Woohoo! You have completed the game in '+@answer+'!<br>Winners will be notified via the email address registered on your WINK+ account.' as response_message
			return

		END
		ELSE If(@campaign_id = 139)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 15 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return

		END
		ELSE If(@campaign_id = 140)
		BEGIN
			IF(@option = '0')
			BEGIN
				
				SELECT '1' AS response_code, 'Thank you for participating! Play again on 24-28 January for more WINK<sup>+</sup> rewards! Happy CNY 2020!' as response_message
				return
			
			END
			ELSE IF(@option = '1')
			BEGIN
				SELECT '1' AS response_code, 'Splendid! You have won a pair of $5 Sushi Plus vouchers!<br>Redemption guidelines will be sent to your WINK<sup>+</sup> registered email within the next 24 hours.<br>Play again on 24-28 January for more WINK<sup>+</sup> rewards!' as response_message
				return
			END

		END
		ELSE If(@campaign_id = 141)
		BEGIN
			IF(@option = '0')
			BEGIN
				
				SELECT '1' AS response_code, 'You have earned 1 point! Thank you for participating and have a prosperous new year!' as response_message
				return
			
			END
			ELSE IF(@option = '1')
			BEGIN
				IF(@answer like '388')
				BEGIN
					SELECT '1' AS response_code, 'How fortunate! You have won '+@answer+' points! Points will be credited to your WINK<sup>+</sup> account.' as response_message
					return
				END
				ELSE IF(@answer like '888')
				BEGIN
					SELECT '1' AS response_code, 'Prosperity abounds! You have won '+@answer+' points! Points will be credited to your WINK<sup>+</sup> account.' as response_message
					return
				END
				
			END
			ELSE IF(@option = '2')
			BEGIN
				SELECT '1' AS response_code, 'All prizes have been fully redeemed! Thank you for your participation and have a prosperous new year!' as response_message
				return
			END

		END
		ELSE If(@campaign_id = 144)
		BEGIN
			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 50 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return
		END
		ELSE If(@campaign_id = 148)
		BEGIN
			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 5 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return
		END
		ELSE If(@campaign_id = 151)
		BEGIN
			
			SELECT '1' AS response_code, 'Welcome to WINK+! Congrats, you have earned 30 WINK+ Points! Take note of your personal WINK+ ID '+ @wid +' and earn more points when you refer friends too.' as response_message
			return
		END
		ELSE If(@campaign_id = 156)
		BEGIN
			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 50 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return
		END
		ELSE If(@campaign_id = 158)
		BEGIN
			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 50 WINK<sup>+</sup> points.<br> WINK<sup>+</sup> points will be credited to your WINK<sup>+</sup> account.' as response_message
			return
		END
		ELSE If(@campaign_id = 160)
		BEGIN
			SELECT '1' AS response_code, 'Activation successful!<br>You may now earn points by travelling thru WINK<sup>+</sup> GATES!' as response_message
			return
		END
		ELSE If(@campaign_id = 162)
		BEGIN
			SELECT '1' AS response_code, 'Congratulations!<br>Your referrer and you will each get 50 points!' as response_message
			return
		END
		ELSE If(@campaign_id = 169 AND @question_id = 527)
		BEGIN
			DECLARE @trainingEarnPtsId int = 0
			SELECT TOP(1) @trainingEarnPtsId = id 
			FROM winktag_customer_earned_points
			WHERE campaign_id = @campaign_id
			AND customer_id = @customer_id
			ORDER BY created_at DESC;

			UPDATE winktag_customer_earned_points
			SET additional_point_status = 1
			WHERE id = @trainingEarnPtsId;

			DECLARE @trainingScore int = 0
			SELECT @trainingScore = ISNULL(sum(cast(option_answer AS INT)),0)
			FROM winktag_customer_survey_answer_detail
			WHERE campaign_id = @CAMPAIGN_ID
			AND customer_id = @customer_id
			AND created_at > @latestTrainingLinkDate;

			SELECT '1' AS response_code, 'Your score is '+CAST(@trainingScore AS VARCHAR(10))+'/25.<br><br>The passing mark is 17/25. You may attempt the quiz again at your own convenience.<br><br>Thank you for participating!' as response_message
			return
		END
		ELSE If(@campaign_id = 170)
		BEGIN
			DECLARE @curAns varchar(250);
			SELECT @curAns = answer
			FROM winktag_customer_survey_answer_detail
			WHERE campaign_id = @campaign_id
			AND customer_id = @customer_id;

			DECLARE @mcMsg varchar(1000)= 'Congratulations! You can now see the WINK+ Gates and the exclusive gates for registering with your Mastercard&reg;.<br>Time to hit the gates and start earning points!';
			DECLARE @otMsg varchar(1000)= 'Congratulations! You can now see the WINK+ Gates and hit the gates to start earning points!';
			IF(@curAns not like '%,%')
			BEGIN
				IF(@curAns like 'MC%')
				BEGIN
					SELECT '1' AS response_code, @mcMsg as response_message
					return
				END
				ELSE IF(@curAns like 'OT%')
				BEGIN
					SELECT '1' AS response_code, @otMsg as response_message
					return
				END
			END
			ELSE
			BEGIN
				SELECT '1' AS response_code, @mcMsg as response_message
				return
			END
		END
		ELSE If(@campaign_id = 173)
		BEGIN
			SELECT '1' AS response_code, '' as response_message
			return
		END
		ELSE If(@campaign_id = 174)
		BEGIN
			SELECT '1' AS response_code, '' as response_message
			return
		END
		ELSE If(@campaign_id = 175)
		BEGIN
			SELECT '1' AS response_code, '' as response_message
			return
		END
		ELSE If(@campaign_id = 176 or @campaign_id = 193)
		BEGIN
			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 50 WINK<sup>+</sup> points.' as response_message
			return
		END
		ELSE If(@campaign_id = 178 or @campaign_id = 179 or @campaign_id = 180 or @campaign_id = 181 or @campaign_id = 182)
		BEGIN
			SELECT '1' AS response_code, '' as response_message
			return
		END
		ELSE If(@campaign_id = 179)
		BEGIN
			SELECT '1' AS response_code, 'Thank you for participating!<br>You have earned 10 WINK<sup>+</sup> points!' as response_message
			return
		END
		ELSE If(@campaign_id = 183)
		BEGIN
			SELECT '1' AS response_code, '' as response_message
			return
		END
		ELSE If(@campaign_id = 184)
		BEGIN
			SELECT '1' AS response_code, '' as response_message
			return
		END
		ELSE If(@campaign_id = 185)
		BEGIN
			SELECT '1' AS response_code, '' as response_message
			return
		END
		ELSE If(@campaign_id = 187)
		BEGIN
			SELECT '1' AS response_code, '' as response_message
			return
		END
		ELSE If(@campaign_id = 189)
		BEGIN
			SELECT '1' AS response_code, '' as response_message
			return
		END
		--SMRT35thAnniversaryPhase 2,3,4,5,6,7 --
		ELSE If(@campaign_id = 191 or @campaign_id=194 or @campaign_id=198 or @campaign_id=199 or @campaign_id=200 or @campaign_id=201)
		BEGIN
			SELECT '1' AS response_code, '' as response_message
			return
		END

		--GreenLiving--
		ELSE If(@campaign_id = 197)
		BEGIN
			SELECT '1' AS response_code, '' as response_message
			return
		END

        --BusShelterTender--
		ELSE If(@campaign_id = 204)
		BEGIN
			SELECT '1' AS response_code, '' as response_message
			return
		END

        --TownHallHiveSurvey2023 && Town Hall 2023 Marsiling Staytion--
		ELSE If(@campaign_id = 208 or @campaign_id = 210)
		BEGIN
			SELECT '1' AS response_code, '' as response_message
			return
		END

        --Wink Hunt Survey P1 Campaign--
		ELSE If(@campaign_id = 215)
		BEGIN
			SELECT '1' AS response_code, 'Check your email for your WINK Hunt game card promo code!' as response_message
			return
		END

		  --Wink Hunt Survey P2 Campaign--
		ELSE If(@campaign_id = 218)
		BEGIN
			SELECT '1' AS response_code, 'Check your email for your WINK Hunt game card promo code!' as response_message
			return
		END

		--WinkHuntRewardCards--
		ELSE If(@campaign_id = 217)
		BEGIN
			SELECT '1' AS response_code, '' as response_message
			return
		END
		BEGIN
			--- WINK PLAY TEMPLATE
			IF (SELECT winktag_type FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'template_survey'
			BEGIN
				SELECT '1' AS response_code, msg_final AS response_message FROM winkplay_campaign_details WHERE campaign_id = @campaign_id
			END
			ELSE
			BEGIN
				SELECT '1' AS response_code, 'Thank you for participating!' as response_message
				return
			END
		END

		
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Insert Fail' as response_message
		return
	END
	
	
	
END

