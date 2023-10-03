

CREATE PROC [dbo].[Get_WINK_Play_List_NDP2021]
(@customer_id int)
AS
BEGIN
 
	DECLARE @CURRENT_DATETIME Datetime;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

	print(@CURRENT_DATETIME)

	Declare @age int
	Declare @phone_no varchar(10)
	Declare @gender varchar(10)
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

	SELECT @totalNDP2021Size = COUNT(*) FROM winktag_customer_survey_answer_detail where campaign_id=167 and option_answer like '%The Road Ahead%'

	select @customer_created_date =created_at, @gender=gender, @customer_id= customer_id ,@phone_no = phone_no,@age =floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) 
	from customer 
	where customer_id= @customer_id 
	and [status] like 'enable'


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
	union --- Internal testing
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
		where c.customer_id =     @customer_id
	)
	AND campaign_id!=167

	
	union --- Internal testing for NDP2021
					select *
					from winktag_campaign as w WHERE internal_testing_status = 1 and  WINKTAG_STATUS = 0 AND winktag_type != 'template_survey' 
					AND CONVERT(DATETIME,@CURRENT_DATETIME) >= CONVERT(DATETIME,from_date)
					AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					AND @totalNDP2021Size < 80
					AND campaign_id = 167
					AND NOT EXISTS (
						SELECT '1' FROM winktag_customer_survey_answer_detail
						WHERE customer_id = @customer_id
					--	AND option_answer = @beautyoneCurCategory
						AND campaign_id = 167
					)
					AND campaign_id  in (select campaign_id from winktag_approved_phone_list as a
					join customer as c
					on a.phone_no = c.phone_no
					where c.customer_id =     @customer_id
					)
			
	order by position asc
END

