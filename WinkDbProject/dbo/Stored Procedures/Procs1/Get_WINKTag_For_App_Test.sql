CREATE PROCEDURE [dbo].[Get_WINKTag_For_App_Test] 
	(@auth varchar(150)
	 )
AS
BEGIN
Declare @ismerchant int 
Declare @customer_id int 
Declare @phone_no varchar(10)
DECLARE @age int
Declare @gender varchar(15)
Declare @customer_created_date datetime
Declare @total_active_campaign int

Declare @curNumOfParticipants int
Declare @dysonSize int
Declare @trichoLimit int
Declare @mitsubishiSize int
--Declare @AIG2Size int 
Declare @beautyoneSize int
Declare @beautyoneStart datetime
DECLARE @beautyoneInternalDate Datetime;
SET @beautyoneInternalDate = '2019-01-22';
DECLARE @beautyoneCurCategory int
SET @beautyoneCurCategory = 3;
Declare @cnyAttempts int 
declare @cnyHasWon  int
Declare @SPGRoadshow int
Declare @gardenBBPrize int
Declare @WinkFromHomeSize int
Declare @ClientSat2021Size int
Declare @ClientSat2021Qualified int = 0
Declare @TLAprDemoQualified int = 0
set @cnyHasWon = 0;

set @ismerchant = 0;

Declare @CURRENT_DATETIME datetime

EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME output

SELECT @WinkFromHomeSize = COUNT(*) from winktag_customer_earned_points where campaign_id = 146;
print('Wink From Home size: ')
print(@WinkFromHomeSize);

--SELECT @gardenBBPrize = COUNT(*) FROM qr_campaign where customer_id = @customer_id and campaign_id = 130 and winning_status = '1' and redemption_status = '0';
-- get size of trichokare survey
select @curNumOfParticipants = COUNT(*) from winktag_customer_earned_points where campaign_id = 45 and customer_id in (select customer_id from customer where gender = @gender);

	IF EXISTS (select 1 from customer where customer.auth_token = @auth )
	BEGIN
--1)Check Account Lock
	IF EXISTS (SELECT * FROM customer WHERE auth_token = @auth AND status = 'disable')
	BEGIN
		select 2 as success , 'Your account is locked. Please contact customer service.' as response_message
		return;
	END
	END
	ELSE 
	BEGIN
	----Multiple login
	select 3 as success , 'Multiple logins not allowed' as response_message
	    return;

	END
    

	select @customer_created_date =created_at, @gender=gender, @customer_id= customer_id ,@phone_no = phone_no,@age =floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) from customer where auth_token= @auth and status = 'enable'
	
	print(@gender)
	print (@customer_id)
	print (@phone_no)
	print (@age)

	if (@gender = 'Male')
	BEGIN
		set @trichoLimit = 150
		
	END
	else
	BEGIN
		set @trichoLimit = 250
	END
	print(@curNumOfParticipants);
	print(@trichoLimit);

	--Dyson
	SELECT @dysonSize = COUNT(*) from winktag_customer_earned_points where campaign_id =  44;
	print('Dyson size: ')
	print(@dysonSize);

	----Mitsubishi
	Select @mitsubishiSize = COUNT(*) from winktag_customer_earned_points where campaign_id = 56;
	print('Mitsubishi size: ')
	print(@mitsubishiSize);

	----AIGHomeInsurance
    --Select @AIG2Size = COUNT(*) from winktag_customer_earned_points where campaign_id = 125;

	----BeautyOne
	SELECT @beautyoneSize = COUNT(*) FROM winktag_customer_earned_points WHERE campaign_id = 54;
	print('Beauty One size: ');
	print(@beautyoneSize);

	SELECT @cnyAttempts = COUNT(*) FROM winktag_customer_survey_answer_detail where campaign_id = 48 and cast(created_at as date) =cast(@CURRENT_DATETIME as date) and customer_id = @customer_id;

	IF EXISTS(SELECT 1 FROM winktag_customer_survey_answer_detail where campaign_id = 48 and cast(created_at as date) = cast(@CURRENT_DATETIME as date) and customer_id = @customer_id and option_answer = '1')
	BEGIN
		SET @cnyHasWon = 1;
	END

	SELECT @SPGRoadshow = COUNT(*) FROM qr_campaign where customer_id = @customer_id and campaign_id = 65 and redemption_status = '0';
print('SPG Roadshow');
print(@SPGRoadshow);
declare @fromPush int = 0
--check if user has open the push notification campaign from the notification
IF EXISTS(SELECT 1 from push_ads_tracker where customer_id = @customer_id and campaign_id = 147)
BEGIN
	set @fromPush = 1;
END

DECLARE @referralNewUser int = 0;
DECLARE @referralStart datetime;
DECLARE @referralEnd datetime;

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

SELECT @ClientSat2021Size = COUNT(*) from winktag_customer_earned_points where campaign_id = 158;
print('Client Satisfaction 2021 size: ')
print(@ClientSat2021Size);

IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'Internal_ClientSatisfaction_02_34005')
BEGIN
	set @ClientSat2021Qualified = 1;
END

IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'TL_Demo_01_%')
BEGIN
	set @TLAprDemoQualified = 1;
END
print('TL Demo')
print(@TLAprDemoQualified)

--5)Check Customer Profile complete or not
	IF Exists (select 1 from customer where customer.auth_token = @auth and 
	(customer.phone_no is not null and phone_no !=''
	and customer.date_of_birth is not null and customer.date_of_birth !='' 
	and customer.gender is not null and customer.gender != ''))
	Begin
			IF Exists (select 1 from (Select * from [winkwink].[dbo].winktag_campaign  as  d
				 where
				 d.winktag_status = 1    AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date) ) as WLIST 
					 where  campaign_id  not  in (  Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_survey_answer_detail where customer_id =@customer_id) )
			 
					  
			BEGIN

			-- Get Beautyone start date
			SELECT @beautyoneStart = from_date FROM winktag_campaign WHERE campaign_id = 54;
			
					   
            ;With active_campaign as (     
					 --- Normal Campaign
					 SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					 AND CONVERT(DATETIME,@CURRENT_DATETIME) >= CONVERT(DATETIME,from_date)
					 AND CONVERT(DATETIME,@CURRENT_DATETIME) <= CONVERT(DATETIME,to_date)  
					 --and  w.campaign_id != 11
					 and w.campaign_id != 44
					 and w.campaign_id != 45
					 and w.campaign_id != 48
					 and w.campaign_id != 54
					 and w.campaign_id != 56
					 and w.campaign_id != 65
					 and w.campaign_id != 101
					 and w.campaign_id != 116
					 --and w.campaign_id != 125
					 --and w.campaign_id != 128
					 --and w.campaign_id != 130
					 and w.campaign_id != 132
					 AND w.winktag_type != 'template_survey'
					 and w.campaign_id != 146
					 and w.campaign_id != 147
					 and w.campaign_id != 158
					 and w.campaign_id != 160
					 and w.campaign_id != 162
					union 
			         ---- HOF 2017
					SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)  
					And w.campaign_id = 22
				    AND @customer_id in (select customer_id from customer_earned_points
					where qr_code ='HOF_HOFEvent2017_01_49656')

						union 
			         ---- 1111 79 NETS Contactless Cashcard 2018
					SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)  
					And w.campaign_id = 26
				    AND @customer_id in (select distinct customer_id from Authen_NETS_Contactless_Cashcard where SUBSTRING(nets_card,1,6) = '111179' and  MONTH(created_at) = MONTH(cast(@CURRENT_DATETIME as Date)))
					AND @customer_id NOT IN (select distinct customer_id FROM NETS_Contactless_Cashcard where customer_id =@customer_id)

					union 
			         ---- Dyson Survey 2018
					SELECT * FROM winktag_campaign as w 
					WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)  
					And w.campaign_id = 44
					AND @age >=25
					AND @dysonSize < w.size

					union 
			         ---- Trichokare Survey 2018
					SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)  
					And w.campaign_id = 45
					AND @age >=25
					and @age <=55
					AND @curNumOfParticipants < @trichoLimit

					union 
					---- Mitsubishi Survey 2018
					SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					And w.campaign_id = 56
					AND @age >=25
					AND @mitsubishiSize < 300

					--union 
					------ AIG Survey 
					--SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					--AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					--And w.campaign_id = 125
					--AND @age >= 20
					--AND @AIG2Size < 600

					union 
					---- Beauty One Survey 2019
					SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					---- Check if customer has not particapated yet
					AND NOT EXISTS ( SELECT '1'
						FROM [winkwink].[dbo].winktag_customer_survey_answer_detail 
						WHERE customer_id =@customer_id
						AND campaign_id = 54
						AND CONVERT(datetime,created_at) >= CONVERT(datetime,@beautyoneStart)
					)
					---- Check if customer has not particapted in the current category
					AND NOT EXISTS (
						SELECT '1' FROM winktag_customer_survey_answer_detail
						WHERE customer_id = @customer_id
						AND option_answer = @beautyoneCurCategory
						AND campaign_id = 54
					)

					AND w.campaign_id = 54
					AND @age >=21
					AND @beautyoneSize < 200

					union --- CNY campaign
					select * from winktag_campaign WHERE WINKTAG_STATUS = 1 
					and campaign_id = 48
					AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
					AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)  
					AND cast(@CURRENT_DATETIME as time) between '08:00:00.000' and '23:59:59.000'
					AND @cnyAttempts <3
					AND @cnyHasWon = 0

					union
					select * from winktag_campaign WHERE WINKTAG_STATUS = 1 
					AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					AND campaign_id = 65
					AND @SPGRoadshow > 0

					union 
			         ---- Summer Fun
					SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					AND cast(@CURRENT_DATETIME as time) not between '00:00:00.000' and '08:29:59.000'
					And w.campaign_id = 101
					AND w.campaign_id not in (
					
						Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points as e
						where e.customer_id =@customer_id
						AND cast(e.created_at as DATE) = cast(@CURRENT_DATETIME as DATE)
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

					--- Wink From Home
					union 
					SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					And w.campaign_id = 146
					AND @WinkFromHomeSize < 105000
					AND cast(@CURRENT_DATETIME as time) not between '00:00:00.000' and '07:59:59.000'
					AND w.campaign_id not in (
					
						Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points as e
						where e.customer_id =@customer_id
						AND cast(e.created_at as DATE) = cast(@CURRENT_DATETIME as DATE)
					)

					union 
					SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					And w.campaign_id = 147
					AND @fromPush = 1
					--union 
			  --       -- Deepavali
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
					--AND campaign_id = 130
					--AND @gardenBBPrize > 0
					union 
					-- Media Client Satisfaction 2021 survey
					SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					And w.campaign_id = 158
					AND @ClientSat2021Qualified = 1
					--AND w.campaign_id not in (Select distinct(campaign_id) FROM [winkwink].[dbo].winktag_customer_earned_points where customer_id =@customer_id)
					AND @ClientSat2021Size < 100

					union 
					-- TL Referral Campaign Demo
					SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					And (w.campaign_id = 160 or w.campaign_id = 162)
					AND @TLAprDemoQualified = 1
					--AND w.campaign_id not in (Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points where customer_id =@customer_id)
				
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
					union --- Internal testing
					select * from winktag_campaign WHERE internal_testing_status = 1 and  WINKTAG_STATUS = 0 AND winktag_type != 'template_survey' 
				
					
					AND campaign_id  in (select campaign_id from winktag_approved_phone_list as a
					join customer as c
					on a.phone_no = c.phone_no
					where c.customer_id =     @customer_id
					
					)
					
					--AND campaign_id != 146
					
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

					
					)
									
		     select @total_active_campaign= count(*) from active_campaign

					SELECT @beautyoneStart = from_date FROM winktag_campaign WHERE campaign_id = 54;
			 print('Total campaign ')

			 print(@total_active_campaign)

             IF (@total_active_campaign>0)
			 BEGIN
			 select 1 as success , @total_active_campaign as response_message
						return;
			 END
			 ELSE
			 BEGIN

			 --- Check for internal test
				IF EXISTS (Select 1 from winktag_campaign as  w,
				 winktag_approved_phone_list as a 
				 where 
				 a.campaign_id = w.campaign_id
				 and 
				 cast (w.from_date as datetime) <= cast (@CURRENT_DATETIME as datetime)
				 and cast (w.to_date as datetime) >= cast (@CURRENT_DATETIME as datetime) 
				 and
				 a.phone_no = @phone_no
				 and w.internal_testing_status =1
				 )
				BEGIN
					select 1 as success , '2Valid User' as response_message
						return;

				END
				ELSE
				BEGIN
					select 0 as success , 'Stay tuned for upcoming promotions' as response_message
					return;

				END

			 select 0 as success , 'Stay tuned for upcoming promotions' as response_message
					return;
			 END

			END
			ELSE IF EXISTS (select 1 from (Select * from [winkwink].[dbo].winktag_campaign  as  d
				 where 
				 d.winktag_status = 1    AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					 ) as WLIST 
					 where  (campaign_id  = 99 or campaign_id = 101 or campaign_id = 116 or campaign_id = 128))
			BEGIN
				;With active_campaign as (     
						 
					---- Toy Story 4
					SELECT * FROM winktag_campaign AS w WHERE w.survey_type !='merchant' AND WINKTAG_STATUS = 1 
					and campaign_id = 99
					AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)

					union 
			         ---- Summer Fun
					SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
					AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
					AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
					AND cast(@CURRENT_DATETIME as time) not between '00:00:00.000' and '08:29:59.000'
					And w.campaign_id = 101
					AND w.campaign_id not in (
					
						Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points as e
						where e.customer_id =@customer_id
						AND cast(e.created_at as DATE) = cast(@CURRENT_DATETIME as DATE)
					)
					union 
			         ----Mid-Autumn 2019
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
				)
				


				select @total_active_campaign= count(*) from active_campaign
				
				print('available campaigns special');
				print(@total_active_campaign);
				IF (@total_active_campaign>0)
				BEGIN
				select 1 as success , '1Valid User' as response_message
						return;
				END
				ELSE
				BEGIN

					--- Check for internal test
					IF EXISTS (Select 1 from winktag_campaign as  w,
						winktag_approved_phone_list as a 
						where 
						a.campaign_id = w.campaign_id
						--and 
						--cast (w.from_date as datetime) <= cast (@CURRENT_DATETIME as datetime)
						--and cast (w.to_date as datetime) >= cast (@CURRENT_DATETIME as datetime) 
						and
						a.phone_no = @phone_no
						and w.internal_testing_status =1 
						and w.winktag_status = 0 
						and  w.campaign_id  not  in 
						(  Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_survey_answer_detail where customer_id =@customer_id)
						)
				
					BEGIN
						select 1 as success , '2Valid User' as response_message
							return;

					END
					ELSE
					BEGIN
						select 0 as success , 'Stay tuned for upcoming promotions' as response_message
						return;

					END

					select 0 as success , 'Stay tuned for upcoming promotions' as response_message
						return;
				END
			END
			--ELSE IF EXISTS (
			--	SELECT 1 FROM (
			--		SELECT * FROM [winkwink].[dbo].winktag_campaign  as  d
			--		WHERE d.winktag_status = 1
			--		AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
			--		AND campaign_id = 54
			--	) as WLIST 
			--	WHERE  campaign_id  NOT  IN (
			--		SELECT DISTINCT(campaign_id)
			--		FROM [winkwink].[dbo].winktag_customer_survey_answer_detail 
			--		WHERE customer_id =@customer_id
			--		AND CONVERT(datetime,created_at) >= CONVERT(datetime,@beautyoneStart)
			--	) 
			--)

			--BEGIN
			--	PRINT('Beauty One Survey Only')
			--	----BeautyOne
			--	SELECT @beautyoneSize = COUNT(*) FROM winktag_customer_earned_points WHERE campaign_id = 54;
			--	print('Beauty One size: ');
			--	print(@beautyoneSize);

			--	;With active_campaign as (     
			--			--- Normal Campaign
			--			SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1  
			--			AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
			--			AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
			--			AND  w.campaign_id NOT IN (44,45,48,54,56)
					
			--		union 
			--		---- Beauty One Survey 2019
			--		SELECT * FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
			--		AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
			--		---- Check if customer has not particapated yet
			--		AND NOT EXISTS ( SELECT '1'
			--			FROM [winkwink].[dbo].winktag_customer_survey_answer_detail 
			--			WHERE customer_id =@customer_id
			--			AND campaign_id = 54
			--			AND CONVERT(datetime,created_at) >= CONVERT(datetime,@beautyoneStart)
			--		)
			--		---- Check if customer has not particapted in the current category
			--		AND NOT EXISTS (
			--			SELECT '1' FROM winktag_customer_survey_answer_detail
			--			WHERE customer_id = @customer_id
			--			AND option_answer = @beautyoneCurCategory
			--			AND campaign_id = 54
			--		)
			--		AND w.campaign_id = 54
			--		AND @age >=21
			--		AND @beautyoneSize < 200
			--		)
									
			--	select @total_active_campaign= count(*) from active_campaign

			--		print('available campaigns ');
			--		print(@total_active_campaign);
			--		IF (@total_active_campaign>0)
			--		BEGIN
			--		select 1 as success , '1Valid User' as response_message
			--				return;
			--		END
			--		ELSE
			--		BEGIN

			--		--- Check for internal test
			--		IF EXISTS (Select 1 from winktag_campaign as  w,
			--		 winktag_approved_phone_list as a 
			--		 where 
			--		 a.campaign_id = w.campaign_id
			--		 and 
			--		 cast (w.from_date as datetime) <= cast (@CURRENT_DATETIME as datetime)
			--		 and cast (w.to_date as datetime) >= cast (@CURRENT_DATETIME as datetime) 
			--		 and
			--		 a.phone_no = @phone_no
			--		 and w.internal_testing_status =1
			--		 )
				
			--		BEGIN
			--			select 1 as success , '2Valid User' as response_message
			--				return;

			--		END
			--		ELSE
			--		BEGIN
			--			select 0 as success , 'Stay tuned for upcoming promotions' as response_message
			--			return;

			--		END

			--		select 0 as success , 'Stay tuned for upcoming promotions' as response_message
			--			return;
			--		END

			--END

			
			ELSE  
			BEGIN
			   print ('Check for internal test')
				--- Check for internal test
				IF EXISTS (Select 1 from winktag_campaign as  w,
				 winktag_approved_phone_list as a 
				 where 
				 a.campaign_id = w.campaign_id
				
				 and
				 a.phone_no = @phone_no
				 and w.internal_testing_status =1
				
				 )
				
				BEGIN
					select 1 as success , '2Valid User' as response_message
						return;

				END
				ELSE
				BEGIN
					select 0 as success , 'Stay tuned for upcoming promotions' as response_message
					return;

				END
			END
    END
	ELSE
	BEGIN
		select 0 as success , 'Please complete your profile to participate in WINK+ Play.' as response_message
		return;

	END

	 
			 
END

