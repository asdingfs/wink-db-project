CREATE procedure [dbo].[Earned_Points_By_Motoring_winkgate_backup]
(
 @cust_auth varchar(150),
 @qr_code varchar(150),
 @id int,
 @gps_location varchar(150),
 @ip_address varchar(10),
 @winkgo_image_id int
 )
AS
BEGIN

Declare @customer_id int,
		@current_date datetime,
		@response_code int,
		@earned_points int,
		@small_image varchar(256),
		@url varchar(250),
		@timer_interval_second int,
		--@campaign_id int,
		@wink_gate_booking_id int,
		@card_type varchar(20)
		
--Declare @transaction_date datetime
Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

set @small_image ='Wink_banner_Thank_you_01.jpg'
set @url = 'https://www.winkwink.sg'
set @timer_interval_second = 3


set @wink_gate_booking_id = 0

Declare @global_campaign int
Declare @wink_gate_points_earned_id int

set @global_campaign =1 --testing

	select @card_type = card_type, @wink_gate_booking_id = wink_gate_asset_id, 
	@wink_gate_points_earned_id = wink_gate_points_earned_id from
	nonstop_net_canid_earned_points where id=@id
	
	

    --set @global_campaign =5 --production
	IF @card_type = '11'
	BEGIN
		--DECLARE @isLuckyDraw BIT
		--DECLARE @winSapphire int = 0;
		--DECLARE @winDiamond int = 0;
	
		--Set @isLuckyDraw = 0
		set @customer_id =(select customer_id from customer where auth_token = @cust_auth and [status]='enable')
		
		--IF EXISTS (select * from winners_points where entry_id = 23 and customer_id=@customer_id 
		--and [Location]=@wink_gate_points_earned_id
		--and CAST(created_at as DATE) = CAST(@current_date as DATE) 
		--)
			--set @isLuckyDraw = 1
		
		--DECLARE @TLMCSapphireWinnerEntry int = 28;
		--DECLARE @TLMCDiamondWinnerEntry int = 29;
		--IF EXISTS (
		--	select * from winners_points 
		--	where entry_id = @TLMCSapphireWinnerEntry and customer_id=@customer_id 
		--	AND [location]=@wink_gate_points_earned_id
		--)
		--BEGIN
		--	SET @winSapphire = 1;
		--END
		--ELSE IF EXISTS (
		--	select * from winners_points 
		--	where entry_id = @TLMCDiamondWinnerEntry and customer_id=@customer_id 
		--	AND [location]=@wink_gate_points_earned_id
		--)
		--BEGIN
		--	SET @winDiamond = 1;
		--END
		
		--IF @isLuckyDraw = 1
		--  select @small_image = 'https://elasticbeanstalk-ap-southeast-1-548656070925.s3-ap-southeast-1.amazonaws.com/WINKTesting/winkwinkAdmin/Images/WINKGATE/external_launch_winner.jpg' , @url = hyperlink  from wink_gate_banner where wink_gate_booking_id = @wink_gate_booking_id
		--IF(@winSapphire = 0 AND @winDiamond = 0)
		--BEGIN
			select @small_image = image_url , @url = hyperlink  from wink_gate_banner where wink_gate_booking_id = @wink_gate_booking_id
		--END
		--ELSE IF(@winSapphire = 1)
		--BEGIN
		--	select @small_image = 'https://elasticbeanstalk-ap-southeast-1-548656070925.s3.ap-southeast-1.amazonaws.com/WINKTesting/winkwinkAdmin/Images/WINKGate/TLMCNov_sappire_winner_banner.jpg' , @url = hyperlink  from wink_gate_banner where wink_gate_booking_id = @wink_gate_booking_id
		--END
		--ELSE IF(@winDiamond = 1)
		--BEGIN
		--	select @small_image = 'https://elasticbeanstalk-ap-southeast-1-548656070925.s3.ap-southeast-1.amazonaws.com/WINKTesting/winkwinkAdmin/Images/WINKGate/TLMCNov_diamond_winner_banner.jpg' , @url = hyperlink  from wink_gate_banner where wink_gate_booking_id = @wink_gate_booking_id
		--END  
	END

	ELSE IF @card_type = '12'
	BEGIN
	  -- get campaign_id
	    select @small_image = 'wfh2021_winkgo_banner.jpg' , @url = 'https://www.facebook.com/winkwinksg'  
		
	END
	--check whether the campaign_id in the asset_winkgo table.
	ELSE IF EXISTS (Select 1 from ASSET_WINKGO  where cast( (select dateadd(HOUR,interval,to_date)) as date) >=  cast(@current_date as date) and cast(from_date as date) <=  cast(@current_date as date) 
				and campaign_id>0 and campaign_id = @winkgo_image_id and [status]='1')
	BEGIN
		set @global_campaign = @winkgo_image_id
	    select TOP 1 @small_image = a.[image] , @url = [url] from ASSET_WINKGO as a  where cast( (select dateadd(HOUR,interval,to_date)) as date) >=  cast(@current_date as date) 
		and cast(from_date as date) <=  cast(@current_date as date)
		and campaign_id>0 and campaign_id = @winkgo_image_id and [status]='1' order by id desc
	END
	
	ELSE IF EXISTS (Select 1 from campaign where cast(campaign_end_date as date) >=  cast(@current_date as date) and campaign_id !=@global_campaign and campaign.campaign_status='enable')
	BEGIN
		set @global_campaign = (Select top 1 campaign_id from campaign where cast(campaign_end_date as date) >=  cast(@current_date as date) and campaign_id !=@global_campaign and campaign.campaign_status='enable')
	    select @small_image = small_image_name , @url = small_image_url from campaign_small_image where campaign_id = @global_campaign and small_image_status = 1
		
	END
	ELSE
	BEGIN

	select @small_image = small_image_name , @url = small_image_url  from campaign_small_image where campaign_id = @global_campaign and small_image_status = 1

	END




--- Check Account Locked--------
   IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @cust_auth and customer.[status]='disable') --CUSTOMER EXISTS                           
    BEGIN
    select 6 as response_code ,'Your account is locked. Please contact customer service.'  as response_message,@timer_interval_second as timer_interval_second
	
		RETURN 
   END-- END

set @customer_id =(select customer_id from customer where auth_token = @cust_auth and [status]='enable')
-- Customer -----
IF (@customer_id is null OR @customer_id ='')
BEGIN
select 0 as response_code , 'Invalid Customer' as response_message
RETURN

END

IF EXISTS (select 1 from nonstop_net_canid_earned_points as a where a.points_credit_status =0 and id=@id)
BEGIN

	SET @earned_points = (select a.total_points from nonstop_net_canid_earned_points as a where a.points_credit_status =0 and id=@id) ;

	update nonstop_net_canid_earned_points set points_credit_status = 1 ,
	point_redemption_date =@current_date,
	updated_at = @current_date,
	gps_location = @gps_location
	where id =@id and points_credit_status =0;

	IF(@@ROWCOUNT>0)
	BEGIN
		INSERT INTO [dbo].[wink_net_canid_earned_points]
					([can_id]
					,[business_date]
					,[total_tabs]
					,[total_points]
					,[created_at]
					,[customer_id]
					,[card_type]
					,promotion_name
					)
		select a.can_id,a.business_date,a.total_tabs,@earned_points,@current_date,@customer_id,a.card_type,
		'NonStop'
		from nonstop_net_canid_earned_points as a
		where a.customer_id =@customer_id and a.id =@id;
		IF(@@ROWCOUNT>0)
		BEGIN
			IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
			BEGIN
				Update customer_balance set total_points = total_points+@earned_points where customer_id = @customer_id;

				IF(@@ROWCOUNT>0)
				BEGIN
					set @response_code =1;
					GOTO Result;
				END

			END
			ELSE
			BEGIN
				INSERT INTO customer_balance (customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans,total_redeemed_amt)VALUES
							(@customer_id,@earned_points,0,0,0,0,0,0,0.00);

				IF(@@ROWCOUNT>0)
				BEGIN
					set @response_code =1;
					GOTO Result;
				END
			END
			BEGIN
				set @response_code =5 
				GOTO Result;
			END
		END
		Else 
		BEGIN
			set @response_code =4;
		    GOTO Result;
		END
	END
	ELSE
	BEGIN
		set @response_code =3;
		GOTO Result;
	END

END
ELSE
BEGIN
	set @response_code =2;
	GOTO Result;
END

Result:
if(@response_code =1)
BEGIN
	select 1 as response_code ,1 as response_message, @earned_points as points ,@url as small_website_url,
	@small_image as small_banner_url,@timer_interval_second as timer_interval_second;

END
ELSE IF (@response_code =2)
BEGIN
select 0 as response_code ,'No points to redeem'  as response_message, @earned_points as points,@timer_interval_second as timer_interval_second

END
ELSE IF (@response_code =3)
BEGIN
select 0 as response_code ,'Please try again later'  as response_message, @earned_points as points,@timer_interval_second as timer_interval_second

END

ELSE IF (@response_code =4)
BEGIN
select 0 as response_code ,'Please try again later'  as response_message, @earned_points as points,@timer_interval_second as timer_interval_second

END

ELSE IF (@response_code =5)
BEGIN
select 0 as response_code ,'Please try again later'  as response_message, @earned_points as points,@timer_interval_second as timer_interval_second

END


END
