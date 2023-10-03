

CREATE PROC [dbo].[WINKTAG_GET_ACTIVE_CAMPAIGN_BY_CUSTOMER_ID_TEST]
(@customer_id int)
AS
BEGIN

DECLARE @CURRENT_DATETIME Datetime ;   
set @CURRENT_DATETIME = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as datetime )
--EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

print(@CURRENT_DATETIME)

--Declare @curNumOfParticipants int
--Declare @AIG2Size int
--Declare @dysonSize int
--Declare @mitsubishiSize int
Declare @age int
Declare @phone_no varchar(10)
Declare @gender varchar(10)
Declare @customer_created_date datetime
--Declare @trichoLimit int
--Declare @beautyoneSize int
--DECLARE @beautyoneStart Datetime;
--DECLARE @beautyoneInternalDate Datetime;
--SET @beautyoneInternalDate = '2019-01-22';
--DECLARE @beautyoneCurCategory int;
--SET @beautyoneCurCategory = 3;
Declare @cnyAttempts int 
declare @cnyHasWon  int
set @cnyHasWon = 0;
Declare @orchardShopsPrize int
Declare @SPGRoadshow int
--Declare @staffTrainingQuiz varchar(5)
--Declare @staffTrainingQuizII varchar(5)
--Declare @totalQuizQue int
--Declare @totalAnsweredQue int

--Declare @totalQuizQueII int
--Declare @totalAnsweredQueII int
--Declare @viralLeaders varchar(5)
Declare @gardenBBPrize int


Declare @SatisfactionSize int
Declare @SatisfactionQualified int = 0
--Declare @ClientSat2021Size int
--Declare @ClientSat2021Qualified int = 0
--Declare @WinkFromHomeSize int=0

--declare @fromPush int = 0

DECLARE @referralNewUser int = 0;
DECLARE @referralStart datetime;
DECLARE @referralEnd datetime;

DECLARE @totalNLBSurveySize int
Declare @TLAprDemoQualified int = 0


-- get size of dyson survey
--SELECT @AIG2Size = COUNT(*) from winktag_customer_earned_points where campaign_id = 125;
--     print('AIG2 size: ')
--	print(@AIG2Size);
--SELECT @dysonSize = COUNT(*) from winktag_customer_earned_points where campaign_id = 44;
select @customer_created_date =created_at, @gender=gender, @customer_id= customer_id ,@phone_no = phone_no,@age =floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) from customer where customer_id= @customer_id and status = 'enable'

--select @curNumOfParticipants = COUNT(*) from winktag_customer_earned_points where campaign_id = 45 and customer_id in (select customer_id from customer where gender = @gender);
--if (@gender = 'Male')
--	BEGIN
--		set @trichoLimit = 150
		
--	END
--else
--	BEGIN
--		set @trichoLimit = 250
--	END


--	print(@curNumOfParticipants);
--	print(@trichoLimit);

--Select @mitsubishiSize = COUNT(*) from winktag_customer_earned_points where campaign_id = 56;
--print('Mitsubishi size: ')
--print(@mitsubishiSize);

--SELECT @beautyoneSize = COUNT(*) FROM winktag_customer_earned_points WHERE campaign_id = 54;
--print('Beauty One size: ');
--print(@beautyoneSize);

--SELECT @beautyoneStart = from_date FROM winktag_campaign WHERE campaign_id = 54;
--print('Beauty One survey start: ');
--print(@beautyoneStart);


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

--SELECT @staffTrainingQuiz = redemption_status from qr_campaign where customer_id = @customer_id and campaign_id = 102;
--print('Refresher quiz');
--print(@staffTrainingQuiz);

--SELECT @staffTrainingQuizII = redemption_status from qr_campaign where customer_id = @customer_id and campaign_id = 142;
--print('Refresher quiz II');
--print(@staffTrainingQuizII);

--SELECT @totalQuizQue = COUNT(question_id) from winktag_survey_question where campaign_id = 102;
--print(@totalQuizQue);

--SELECT @totalAnsweredQue = COUNT(question_id) from winktag_customer_survey_answer_detail where campaign_id = 102 and customer_id = @customer_id;
--print(@totalAnsweredQue);

--SELECT @totalQuizQueII = COUNT(question_id) from winktag_survey_question where campaign_id = 142;
--print(@totalQuizQueII);

--SELECT @totalAnsweredQueII = COUNT(question_id) from winktag_customer_survey_answer_detail where campaign_id = 142 and customer_id = @customer_id;
--print(@totalAnsweredQueII);

--SELECT @viralLeaders = redemption_status from qr_campaign where customer_id = @customer_id and campaign_id = 103;
--print('Viral Leaders');
--print(@viralLeaders);

--declare @winkCityPoc int = 0;
--IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'POC_WINK_CITY_01_33989')  
--BEGIN
--	set @winkCityPoc = 1;
--END
--print('wink city: ');
--print(@winkCityPoc);

--declare @winkCityAnswered int;
--SELECT @winkCityAnswered = COUNT(1) from wink_game_customer_result where campaign_id = 134 and customer_id = @CUSTOMER_ID and cast(created_at as datetime) between '2019-11-20 16:00:00.000' and '2019-11-20 17:00:00.000';
--print(@winkCityAnswered);

SELECT @SatisfactionSize = COUNT(*) from winktag_customer_earned_points where campaign_id = 144;
print('Satisfaction size: ')
print(@SatisfactionSize);

IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'Internal_ClientSatisfaction_01_33991')
BEGIN
	set @SatisfactionQualified = 1;
END

--check GiveMEaName Campaign.
-- Get Campaign start and end date.
DECLARE @winkNameSurveyStartDate as datetime
DECLARE @winkNameSurveyEndDate as datetime
DECLARE @totalWinkNameSureySize int
DECLARE @winkNameContent varchar(50)
DECLARE @winkNamePinkSurveySize int
DECLARE @winkNameGreenSurveySize int
DECLARE @winkNameRedSurveySize int
DECLARE @winkNameBlueSurveySize int
set @winkNameSurveyStartDate = '2021-04-22 09:00:00'
set @winkNameSurveyEndDate = '2021-05-14 23:59:59'
set @winkNameContent =''



IF (@CURRENT_DATETIME >= @winkNameSurveyStartDate and @CURRENT_DATETIME<=@winkNameSurveyEndDate)
BEGIN
	SELECT @totalWinkNameSureySize = COUNT(*) from winktag_customer_earned_points where campaign_id = 163;

	IF (@totalWinkNameSureySize < 10032)
	BEGIN

		IF  EXISTS (select * FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'GWAN_NAMEPINK%' 
			and (created_at>=@winkNameSurveyStartDate and created_at<= @winkNameSurveyEndDate)
		) 
		and not EXISTS( select * from winktag_customer_earned_points where campaign_id=163 and question_id=490
			and customer_id = @customer_id
			and (created_at>=@winkNameSurveyStartDate and created_at<= @winkNameSurveyEndDate)
		)
			set @winkNameContent = @winkNameContent + 'pink ' 

		IF  EXISTS (select * FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'GWAN_NAMERED%' 
			and (created_at>=@winkNameSurveyStartDate and created_at<= @winkNameSurveyEndDate)
		) 
		and not EXISTS( select * from winktag_customer_earned_points where campaign_id=163 and question_id=491
			and customer_id = @customer_id
			and (created_at>=@winkNameSurveyStartDate and created_at<= @winkNameSurveyEndDate)
		)
			set @winkNameContent = @winkNameContent + 'red ' 

		IF  EXISTS (select * FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'GWAN_NAMEGREEN%' 
			and (created_at>=@winkNameSurveyStartDate and created_at<= @winkNameSurveyEndDate)
			) 
		and not EXISTS( select * from winktag_customer_earned_points where campaign_id=163 and question_id=492
			and (created_at>=@winkNameSurveyStartDate and created_at<= @winkNameSurveyEndDate)
			and customer_id = @customer_id
		)
			set @winkNameContent = @winkNameContent + 'green '
	 
		IF  EXISTS (select * FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'GWAN_NAMEBLUE%' 
			and (created_at>=@winkNameSurveyStartDate and created_at<= @winkNameSurveyEndDate)
			) 
			and not EXISTS( select * from winktag_customer_earned_points where campaign_id=163 and question_id=493
			and customer_id = @customer_id
			and (created_at>=@winkNameSurveyStartDate and created_at<= @winkNameSurveyEndDate)
		)
			set @winkNameContent = @winkNameContent + 'blue '
	END
	print @winkNameContent
END
 --select wink_

--SELECT @ClientSat2021Size = COUNT(*) from winktag_customer_earned_points where campaign_id = 158;
--print('Client Satisfaction 2021 size: ')
--print(@ClientSat2021Size);


--IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'Internal_ClientSatisfaction_02_34005')
--BEGIN
--	set @ClientSat2021Qualified = 1;
--END

--SELECT @WinkFromHomeSize = COUNT(*) from winktag_customer_earned_points where campaign_id = 146;
--print('Wink From Home size: ')
--print(@WinkFromHomeSize);

--declare @incompleteOrder int
--set @incompleteOrder = 0;

--IF EXISTS(SELECT 1 from wink_delights_online where campaign_id = 145 and completion = 0)
--BEGIN
--	set @incompleteOrder = 1;
--END

--print('incomplete orders: ');
--print(@incompleteOrder);

--check if user has open the push notification campaign from the notification
--IF EXISTS(SELECT 1 from push_ads_tracker where customer_id = @customer_id and campaign_id = 147)
--BEGIN
--	set @fromPush = 1;
--END

--Referral Programme
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


       	 --select * from (             

					SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					 AND  w.internal_testing_status = 0
					--AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					--AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)
					--AND w.campaign_id not in (Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points where customer_id =@customer_id)
				
					--and campaign_id != 22
					--and campaign_id != 26
					--and campaign_id != 34
					 --and campaign_id != 44
					 --and campaign_id != 45
					 and campaign_id !=48
					 --and campaign_id != 54
					--and campaign_id != 56
					--AND campaign_id != 59
					--AND campaign_id != 60
					AND campaign_id != 61
					--AND campaign_id != 62
					AND campaign_id != 65
					--AND campaign_id != 102
					--AND campaign_id != 101
					--AND campaign_id != 103
					AND campaign_id != 110
					AND campaign_id != 116
				    --AND campaign_id != 125
				    --AND campaign_id != 128
					AND campaign_id != 130
					--AND campaign_id != 134
					--AND campaign_id != 142
					AND campaign_id ! =144
					--AND campaign_id != 145
					AND winktag_type != 'template_survey'
					--AND campaign_id !=146
					--AND campaign_id !=147
					--AND campaign_id !=149
					AND campaign_id !=151
					AND campaign_id !=157
					--AND campaign_id ! =158
					AND campaign_id != 160
					AND campaign_id != 162
					AND campaign_id != 163
					--union  ---- Star war
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					--AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)  
					--And w.campaign_id = 20
					--AND cast (@customer_created_date as date) >= cast (w.from_date as date)
					--union 
			  --       ---- 1111 79 NETS Contactless Cashcard 2018
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					--AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)  
					--And w.campaign_id = 26
				 --   AND @customer_id in (select distinct customer_id from Authen_NETS_Contactless_Cashcard where SUBSTRING(nets_card,1,6) = '111179' and  MONTH(created_at) = MONTH(cast(@CURRENT_DATETIME as Date)))
					
				
				 --   union
			  --       ---- AIG Home Insurance
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					--AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)  
					--And w.campaign_id = 125
					--AND @age >=20
					--AND @AIG2Size < 5

					--union 
			  --       ---- Dyson Survey 2018
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					--AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)  
					--And w.campaign_id = 44
					--AND @age >=25
					--AND @dysonSize < w.size

					--union 
			  --       ---- Trichokare Survey 2018
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					--AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)  
					--And w.campaign_id = 45
					--AND @age >=25
					--and @age <=55
					--AND @curNumOfParticipants < @trichoLimit

					
					--union 
			  --       ---- Mitsubishi Survey 2019
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					--And w.campaign_id = 56
					--AND @age >=25
					--AND @mitsubishiSize < 300

					--union 
			  --       ---- Beauty One Survey 2019
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					--And w.campaign_id = 54
					--AND w.campaign_id not in (Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points where customer_id =@customer_id AND CONVERT(datetime,created_at) > CONVERT(datetime, @beautyoneStart))  
					--AND NOT EXISTS (
					--	SELECT '1' FROM winktag_customer_survey_answer_detail
					--	WHERE customer_id = @customer_id
					--	AND option_answer = @beautyoneCurCategory
					--	AND campaign_id = 54
					--)
					--AND @age >=21
					--AND @beautyoneSize < 200


					union --- CNY campaign
					select * from winktag_campaign WHERE WINKTAG_STATUS = 1 
					and campaign_id = 48
					AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)  
					AND cast(@CURRENT_DATETIME as time) between '08:00:00.000' and '23:59:59.000'
					AND @cnyAttempts <3
					AND @cnyHasWon = 0

					--union 
			  --       ---- Shaw Theatres Survey 2019
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					--AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)
					--AND w.campaign_id = 60
					--AND w.campaign_id not in (
					--	Select distinct(campaign_id)
					--	FROM [winkwink].[dbo].winktag_customer_earned_points
					--	WHERE customer_id =@customer_id
					--)

					--union 
			  --       ---- Valentines Survey 2019
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					--AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)
					--AND w.campaign_id = 59
					--AND w.campaign_id not in (
					--	Select distinct(campaign_id)
					--	FROM [winkwink].[dbo].winktag_customer_earned_points
					--	WHERE customer_id =@customer_id
					--)

					--union 
			  --       ---- Disney on Ice Campaign
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					--AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)
					--AND w.campaign_id = 62
					--AND w.campaign_id not in (
					--	Select distinct(campaign_id)
					--	FROM [winkwink].[dbo].winktag_customer_earned_points
					--	WHERE customer_id =@customer_id
					--)

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

					--union 
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					--AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					--AND campaign_id = 102
					--AND @staffTrainingQuiz = '0'
					--AND @totalAnsweredQue < @totalQuizQue

					--union 
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					--AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					--AND campaign_id = 142
					--AND @staffTrainingQuizII = '0'
					--AND @totalAnsweredQueII < @totalQuizQueII

					--union 
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					--AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					--AND campaign_id = 103
					--AND @viralLeaders = '0'
					--AND w.campaign_id not in (
					--	Select distinct(campaign_id)
					--	FROM [winkwink].[dbo].winktag_customer_survey_answer_detail
					--	WHERE customer_id =@customer_id
					--)

					--union 
			  --       ---- Summer Fun
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					--AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					--AND cast(@CURRENT_DATETIME as time) not between '00:00:00.000' and '08:29:59.000'
					--And w.campaign_id = 101
					--AND w.campaign_id not in (
					
					--	Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points as e
					--	where e.customer_id =@customer_id
					--	AND cast(e.created_at as DATE) = cast(@CURRENT_DATETIME as DATE)
					--)
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

					--union 
			  --       ---- Deepavali
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					--AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					--AND cast(@CURRENT_DATETIME as time) not between '00:00:00.000' and '08:59:59.000'
					--And w.campaign_id = 128
					--AND w.campaign_id not in (
					
					--	Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points as e
					--	where e.customer_id =@customer_id
					--	AND cast(e.created_at as DATE) = cast(@CURRENT_DATETIME as DATE)
					--)

					--union 
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					--AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					--AND campaign_id = 134
					--AND @winkCityPoc = 1
					--AND @winkCityAnswered < 4
					union 
					SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					And w.campaign_id = 144
					AND @SatisfactionQualified = 1
					AND w.campaign_id not in (Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points where customer_id =@customer_id)
					AND @SatisfactionSize < 150

					--union 
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					--AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					--And w.campaign_id = 146
					--AND @WinkFromHomeSize < 105000

					--union 
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					--AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					--And w.campaign_id = 147
					--AND @fromPush = 1

					--union 
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					--AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					--And w.campaign_id = 149

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

					--union 
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					--AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					--And w.campaign_id = 158
					--AND @ClientSat2021Qualified = 1
					----AND w.campaign_id not in (Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points where customer_id =@customer_id)
					--AND @ClientSat2021Size < 100

					union 
					SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					And (w.campaign_id = 160 or w.campaign_id = 162)
					AND @TLAprDemoQualified = 1
					AND w.campaign_id not in (Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points where customer_id =@customer_id)
				
					union ---  GiveWINKaName
					select w.[campaign_id],w.[campaign_name],w.[campaign_image_large],w.[campaign_image_small],w.[points],w.[interval_status]
					,w.[interval] ,0 as limit ,w.[winktag_type],w.[winktag_status],w.[created_at],w.[updated_at]
					,w.[from_date],w.[to_date],w.[interval_type],@winkNameContent as content,w.[survey_type],w.[position],w.[winktag_report]
					,w.[size],w.[min_count],w.[max_count],w.[sp_type],w.[internal_testing_status]
					from winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1 
					AND CONVERT(DATETIME,@CURRENT_DATETIME) >= CONVERT(DATETIME,from_date)
					AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					AND campaign_id = 163
					AND @winkNameContent!= ''
					
					
					UNION
					---- WINK PLAY TEMPLATE
					---- ALWAYS PUT BEFORE INTERNAL TESTING
					SELECT w.campaign_id
					, w.campaign_name
					, CASE WHEN wd.banner_type = 'full' THEN w.campaign_image_large ELSE w.campaign_image_small END AS campaign_image_large
					, w.campaign_image_small
					, w.points
					, w.interval_status
					, w.interval
					, w.limit
					, w.winktag_type
					, w.winktag_status
					, w.created_at
					, w.updated_at
					, w.from_date
					, w.to_date
					, w.interval_type
					, w.content
					, w.survey_type
					, w.position
					, w.winktag_report
					, w.size
					, w.min_count
					, w.max_count
					, w.sp_type
					, w.internal_testing_status
					FROM winktag_campaign AS w
					LEFT JOIN winkplay_campaign_details AS wd
					ON wd.campaign_id = w.campaign_id
					LEFT JOIN winktag_customer_earned_points wp
					ON wp.campaign_id = w.campaign_id
					WHERE w.survey_type != 'merchant'
					AND w.winktag_type = 'template_survey'
					AND w.winktag_status = 1
					---- Respondents size
					AND (SELECT COUNT(*) FROM winktag_customer_earned_points WHERE campaign_id = wp.campaign_id) < w.size
					---- Respondents Gender
					AND @gender =  CASE WHEN wd.gender = 'all' THEN @gender ELSE wd.gender END
					---- Respondents Age
					AND @age >= CASE WHEN wd.age_from = 0 THEN @age ELSE wd.age_from END
					AND @age <= CASE WHEN wd.age_to = 0 THEN @age ELSE wd.age_to END
					---- Campaign Duration
					AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)

					---- Internal Test
					UNION
					SELECT w.campaign_id
					, w.campaign_name
					, CASE WHEN wd.banner_type = 'full' THEN w.campaign_image_large ELSE w.campaign_image_small END AS campaign_image_large
					, w.campaign_image_small
					, w.points
					, w.interval_status
					, w.interval
					, w.limit
					, w.winktag_type
					, w.winktag_status
					, w.created_at
					, w.updated_at
					, w.from_date
					, w.to_date
					, w.interval_type
					, w.content
					, w.survey_type
					, w.position
					, w.winktag_report
					, w.size
					, w.min_count
					, w.max_count
					, w.sp_type
					, w.internal_testing_status 
					FROM winktag_campaign AS w
					LEFT JOIN winkplay_campaign_details AS wd
					ON wd.campaign_id = w.campaign_id
					WHERE w.internal_testing_status = 1 
					AND  w.winktag_status = 0 
					AND w.winktag_type = 'template_survey'
					AND w.campaign_id  in (
						SELECT campaign_id FROM winktag_approved_phone_list AS a
						JOIN customer AS c
						ON a.phone_no = c.phone_no
						WHERE c.customer_id = @customer_id
					)
					---- END WINK PLAY TEMPLATE

					union --- Internal testing
					select * from winktag_campaign WHERE internal_testing_status = 1 and  WINKTAG_STATUS = 0 AND winktag_type != 'template_survey' 
				
					
					AND campaign_id  in (select campaign_id from winktag_approved_phone_list as a
					join customer as c
					on a.phone_no = c.phone_no
					where c.customer_id =     @customer_id
					
					)
					--AND campaign_id != 145
					--AND campaign_id != 146
					AND campaign_id != 151
					AND campaign_id != 163
					
					--union --- Internal testing for WFH
					--select * from winktag_campaign WHERE internal_testing_status = 1 and  WINKTAG_STATUS = 0 AND winktag_type != 'template_survey' 
					--AND campaign_id = 146
					--AND cast(@CURRENT_DATETIME as time) not between '00:00:00.000' and '07:59:59.000'
					
					
					--AND NOT EXISTS (Select distinct(e.campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points as e
					--	where e.customer_id =@customer_id
					--	AND e.campaign_id = 146
					--	AND cast(e.created_at as DATE) = cast(@CURRENT_DATETIME as DATE))
				

					
					----AND  campaign_id not in (select DISTINCT(w.campaign_id) from winktag_customer_earned_points as w where w.campaign_id=146 and w.customer_id=@customer_id and (cast(w.created_at as date)=cast(@CURRENT_DATETIME as date)))
					--AND campaign_id  in (select campaign_id from winktag_approved_phone_list as a
					--join customer as c
					--on a.phone_no = c.phone_no
					--where c.customer_id =     @customer_id
					--)

					

					--union --- Internal testing for WDO
					--select * from winktag_campaign WHERE internal_testing_status = 1 and  WINKTAG_STATUS = 0 AND winktag_type != 'template_survey' 
					--AND CONVERT(DATETIME,@CURRENT_DATETIME) >= CONVERT(DATETIME,from_date)
					--AND campaign_id = 145
					--AND campaign_id  in (select campaign_id from winktag_approved_phone_list as a
					--join customer as c
					--on a.phone_no = c.phone_no
					--where c.customer_id =     @customer_id
					--)
					--AND (
					--		((DATEDIFF(minute, CONVERT(DATETIME,to_date), @CURRENT_DATETIME) < 4320) 
					--		AND 
					--		@incompleteOrder = 1)

					--		or

					--		(
					--			CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					--		)
					--	)
				
					union --- Internal testing for Referral Programme
					select w.[campaign_id],w.[campaign_name],w.[campaign_image_large],w.[campaign_image_small],w.[points],w.[interval_status]
					,w.[interval] ,@referralNewUser as limit ,w.[winktag_type],w.[winktag_status],w.[created_at],w.[updated_at]
					,w.[from_date],w.[to_date],w.[interval_type],w.[content],w.[survey_type],w.[position],w.[winktag_report]
					,w.[size],w.[min_count],w.[max_count],w.[sp_type],w.[internal_testing_status]
					from winktag_campaign as w WHERE internal_testing_status = 1 and  WINKTAG_STATUS = 0 AND winktag_type != 'template_survey' 
					AND CONVERT(DATETIME,@CURRENT_DATETIME) >= CONVERT(DATETIME,from_date)
					AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					AND campaign_id = 151
					AND campaign_id  in (select campaign_id from winktag_approved_phone_list as a
					join customer as c
					on a.phone_no = c.phone_no
					where c.customer_id =     @customer_id
					)

					union --- Internal testing for ECOM Programme
					select w.[campaign_id],w.[campaign_name],w.[campaign_image_large],w.[campaign_image_small],w.[points],w.[interval_status]
					,w.[interval] ,@referralNewUser as limit ,w.[winktag_type],w.[winktag_status],w.[created_at],w.[updated_at]
					,w.[from_date],w.[to_date],w.[interval_type],w.[content],w.[survey_type],w.[position],w.[winktag_report]
					,w.[size],w.[min_count],w.[max_count],w.[sp_type],w.[internal_testing_status]
					from winktag_campaign as w WHERE internal_testing_status = 1 and  WINKTAG_STATUS = 0 AND winktag_type != 'template_survey' 
					AND CONVERT(DATETIME,@CURRENT_DATETIME) >= CONVERT(DATETIME,from_date)
					AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					AND campaign_id = 159
					AND campaign_id  in (select campaign_id from winktag_approved_phone_list as a
					join customer as c
					on a.phone_no = c.phone_no
					where c.customer_id =     @customer_id
					)

					union --- Internal testing for GiveWINKaName
					select w.[campaign_id],w.[campaign_name],w.[campaign_image_large],w.[campaign_image_small],w.[points],w.[interval_status]
					,w.[interval] ,0 as limit ,w.[winktag_type],w.[winktag_status],w.[created_at],w.[updated_at]
					,w.[from_date],w.[to_date],w.[interval_type],@winkNameContent as content,w.[survey_type],w.[position],w.[winktag_report]
					,w.[size],w.[min_count],w.[max_count],w.[sp_type],w.[internal_testing_status]
					from winktag_campaign as w WHERE internal_testing_status = 1 and  WINKTAG_STATUS = 0 AND winktag_type != 'template_survey' 
					AND CONVERT(DATETIME,@CURRENT_DATETIME) >= CONVERT(DATETIME,from_date)
					AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					AND campaign_id = 163
					AND campaign_id  in (select campaign_id from winktag_approved_phone_list as a
					join customer as c
					on a.phone_no = c.phone_no
					where c.customer_id =     @customer_id
					)
					order by position asc

	 
END

