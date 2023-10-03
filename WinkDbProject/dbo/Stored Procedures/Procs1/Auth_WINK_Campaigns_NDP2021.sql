CREATE PROCEDURE [dbo].[Auth_WINK_Campaigns_NDP2021] 
(@auth varchar(150))
AS
BEGIN
	Declare @customer_id int 
	Declare @phone_no varchar(10)
	Declare @CURRENT_DATETIME datetime;
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME output

	set @CURRENT_DATETIME = '2021-08-20 09:00:01' -- testing

	select @customer_id= customer_id, @phone_no = phone_no from customer where auth_token= @auth and [status] like 'enable'
	print (@customer_id)
	
	IF EXISTS (select 1 from customer where customer.auth_token = @auth )
	BEGIN
		--1)Check Account Lock
		IF EXISTS (SELECT * FROM customer WHERE auth_token = @auth AND [status] = 'disable')
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

	Declare @cnyAttempts int 
	declare @cnyHasWon  int = 0;
	Declare @SPGRoadshow int
	SELECT @cnyAttempts = COUNT(*) FROM winktag_customer_survey_answer_detail where campaign_id = 48 and cast(created_at as date) =cast(@CURRENT_DATETIME as date) and customer_id = @customer_id;

	IF EXISTS(SELECT 1 FROM winktag_customer_survey_answer_detail where campaign_id = 48 and cast(created_at as date) = cast(@CURRENT_DATETIME as date) and customer_id = @customer_id and option_answer = '1')
	BEGIN
		SET @cnyHasWon = 1;
	END

	SELECT @SPGRoadshow = COUNT(*) FROM qr_campaign where customer_id = @customer_id and campaign_id = 65 and redemption_status = '0';
	print('SPG Roadshow');
	print(@SPGRoadshow);

	Declare @TLAprDemoQualified int = 0
	IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS WHERE CUSTOMER_ID = @CUSTOMER_ID AND QR_CODE like 'TL_Demo_01_%')
	BEGIN
		set @TLAprDemoQualified = 1;
	END
	print('TL Demo')
	print(@TLAprDemoQualified)

	DECLARE @totalNDP2021Size int = 0
	SELECT @totalNDP2021Size = COUNT(*) FROM winktag_customer_survey_answer_detail where campaign_id=167 and option_answer like '%The Road Ahead%'

	DECLARE @winkPlayCount int = 0
	DECLARE @winkTreatsCount int = 0;

	IF Exists(
			select 1 from [winkwink].[dbo].winktag_campaign  as  d
			where d.survey_type !='merchant'
			AND d.winktag_status like '1'
			AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
			AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date) 
			AND d.campaign_id not  in (
				Select distinct(campaign_id)   
				FROM [winkwink].[dbo].winktag_customer_survey_answer_detail 
				where customer_id =@customer_id
			)
		)	  
	BEGIN
		
		select @winkPlayCount = count(*) from
		(
			--Generic Campaigns
			SELECT w.campaign_id FROM winktag_campaign as w 
			WHERE w.survey_type !='merchant' 
			AND w.winktag_type not like 'template_survey'
			AND w.winktag_type not like 'wink_fee'
			AND w.winktag_status like '1'
			AND CONVERT(DATETIME,@CURRENT_DATETIME) >= CONVERT(DATETIME,from_date)
			AND CONVERT(DATETIME,@CURRENT_DATETIME) <= CONVERT(DATETIME,to_date)
			and w.campaign_id != 48
			and w.campaign_id != 65
			and w.campaign_id != 116
			and w.campaign_id != 160
			and w.campaign_id != 162
			and w.campaign_id != 163
			and w.campaign_id != 167

			UNION 
			---- HOF 2017
			SELECT w.campaign_id FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
			AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
			AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)  
			And w.campaign_id = 22
			AND @customer_id in (select customer_id from customer_earned_points
			where qr_code ='HOF_HOFEvent2017_01_49656')

			UNION 
			---- 1111 79 NETS Contactless Cashcard 2018
			SELECT w.campaign_id FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
			AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
			AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)  
			And w.campaign_id = 26
			AND @customer_id in (select distinct customer_id from Authen_NETS_Contactless_Cashcard where SUBSTRING(nets_card,1,6) = '111179' and  MONTH(created_at) = MONTH(cast(@CURRENT_DATETIME as Date)))
			AND @customer_id NOT IN (select distinct customer_id FROM NETS_Contactless_Cashcard where customer_id =@customer_id)

			union --- CNY campaign
			select campaign_id from winktag_campaign WHERE WINKTAG_STATUS = 1 
			and campaign_id = 48
			AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
			AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)  
			AND cast(@CURRENT_DATETIME as time) between '08:00:00.000' and '23:59:59.000'
			AND @cnyAttempts <3
			AND @cnyHasWon = 0

			union
			select campaign_id from winktag_campaign WHERE WINKTAG_STATUS like '1'
			AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
			AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
			AND campaign_id = 65
			AND @SPGRoadshow > 0

			union 
			---- Mid-Autumn 2019
			SELECT w.campaign_id FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS like '1'
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
			-- TL Referral Campaign Demo
			SELECT w.campaign_id FROM winktag_campaign as w 
			WHERE w.survey_type !='merchant' 
			AND  w.WINKTAG_STATUS like '1'
			AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
			AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
			AND (w.campaign_id = 160 or w.campaign_id = 162)
			AND @TLAprDemoQualified = 1
			AND w.campaign_id not in (Select distinct(campaign_id)   FROM [winkwink].[dbo].winktag_customer_earned_points where customer_id =@customer_id)

			union  -- NDP2021
			SELECT  w.campaign_id FROM winktag_campaign as w WHERE w.survey_type !='merchant' and  w.WINKTAG_STATUS = 1
			AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
			AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
			And w.campaign_id = 167
			AND @totalNDP2021Size < 80
			AND NOT EXISTS (
						SELECT '1' FROM winktag_customer_survey_answer_detail
						WHERE customer_id = @customer_id
					--	AND option_answer = @beautyoneCurCategory
						AND campaign_id = 167
			)
			union
			(
			-- WINK Play Campaigns (internal testing)
			Select w.campaign_id 
			from winktag_campaign as w, winktag_approved_phone_list as a 
			where a.campaign_id = w.campaign_id
			AND w.survey_type !='merchant' 
			AND w.winktag_type not like 'template_survey'
			AND w.winktag_type not like 'wink_fee'
			AND a.phone_no = @phone_no
			AND w.internal_testing_status =1  
			AND w.winktag_status like '0'
			AND w.campaign_id!=167

			union --- Internal testing for NDP2021
					select w.campaign_id 
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
			) 
		) as T;
		print('wink play campaigns: ');
		print(@winkPlayCount);

		select @winkTreatsCount = count(*) from
		(
			select d.campaign_id 
			from [winkwink].[dbo].winktag_campaign  as  d
			where d.winktag_type like 'wink_fee'
			AND d.winktag_status like '1'
			AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
			AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date) 

			union

			Select w.campaign_id 
			from winktag_campaign as w, winktag_approved_phone_list as a 
			where a.campaign_id = w.campaign_id
			and w.winktag_type like 'wink_fee'
			and a.phone_no = @phone_no
			and w.internal_testing_status =1  
			and w.winktag_status like '0' 
		) as T;
		print('wink treats campaigns: ');
		print(@winkTreatsCount);

		select 1 as success, CONCAT(@winkPlayCount, ',', @winkTreatsCount) as response_message
		return; 
	END
	ELSE 
	BEGIN
		print ('Check for internal test')
		--- Check for internal test
		IF EXISTS(
			Select 1 from winktag_campaign as  w, winktag_approved_phone_list as a 
			where a.campaign_id = w.campaign_id
			and w.survey_type !='merchant'
			and a.phone_no = @phone_no
			and w.internal_testing_status =1  
			and w.winktag_status like '0' 
		)
		BEGIN
			select @winkPlayCount = count(w.campaign_id)
			from winktag_campaign as w, winktag_approved_phone_list as a 
			where a.campaign_id = w.campaign_id
			and w.survey_type !='merchant'
			AND w.winktag_type not like 'template_survey'
			AND w.winktag_type not like 'wink_fee'
			and a.phone_no = @phone_no
			and w.internal_testing_status =1  
			and w.winktag_status like '0' 
			print('internal testing wink play campaigns: ');
			print(@winkPlayCount);

			select @winkTreatsCount = count(w.campaign_id)
			from winktag_campaign as w, winktag_approved_phone_list as a 
			where a.campaign_id = w.campaign_id
			and w.winktag_type like 'wink_fee'
			and a.phone_no = @phone_no
			and w.internal_testing_status =1  
			and w.winktag_status like '0' 
			print('internal testing wink treats campaigns: ');
			print(@winkTreatsCount);

			select 1 as success, CONCAT(@winkPlayCount, ',', @winkTreatsCount) as response_message
			return; 
		END
		ELSE
		BEGIN
			select 0 as success, 'Stay tuned for upcoming campaigns' as response_message;
		END
	END
END