CREATE PROCEDURE [dbo].[Auth_WINK_Treats] 
	(@auth varchar(150))
AS
BEGIN
	Declare @customer_id int 
	Declare @phone_no varchar(10)
	Declare @CURRENT_DATETIME datetime;
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME output

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
		select 3 as success , 'Multiple login not allowed' as response_message
	    return;

	END
    
	select @customer_id= customer_id, @phone_no = phone_no from customer where auth_token= @auth and [status] like 'enable'
	print (@customer_id)
	
	--5)Check Customer Profile complete or not
	IF Exists (select 1 from customer where customer.auth_token = @auth and 
	(customer.phone_no is not null and phone_no !=''
	and customer.date_of_birth is not null and customer.date_of_birth !='' 
	and customer.gender is not null and customer.gender != ''))
	BEGIN

        -- EngineeringTownHall2023 --
        DECLARE @EngineeringTownHall2023CampaignId int = 213;
        DECLARE @EngineeringTownHall2023Qualified int = 0;
        DECLARE @EngineeringTownHall2023Size int;
        DECLARE @EngineeringTownHall2023MaxSize int = (SELECT size from winktag_campaign where campaign_id = @EngineeringTownHall2023CampaignId);

        SELECT @EngineeringTownHall2023Size = COUNT(*) from winktag_customer_earned_points 
        where campaign_id = @EngineeringTownHall2023CampaignId;
        IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS 
                WHERE CUSTOMER_ID = @CUSTOMER_ID 
                AND QR_CODE = 'TownHallEngineering2023_EngTownHall_01_34063')
        BEGIN
            set @EngineeringTownHall2023Qualified = 1;
        END


		IF Exists(
			select 1 from [winkwink].[dbo].winktag_campaign  as  d
			where d.winktag_type like 'wink_fee'
			AND d.winktag_status like '1'
			AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
			AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date) 
            AND d.campaign_id != @EngineeringTownHall2023CampaignId

            union
			--TownHall2023MarsilingStaytion--
            SELECT w.campaign_id FROM winktag_campaign as w 
            WHERE w.winktag_type like 'wink_fee' and  w.winktag_status like '1'
			AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
			AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)  
			And w.campaign_id = @EngineeringTownHall2023CampaignId
			AND @EngineeringTownHall2023Qualified = 1
			AND NOT EXISTS (
				SELECT '1' FROM wink_products_redemption
				WHERE customer_id = @customer_id
				AND product_id = 31
			)
			AND @EngineeringTownHall2023Size < @EngineeringTownHall2023MaxSize			
		)	  
		BEGIN
			select 1 as success, '' as response_message
			return;
		END
		ELSE 
		BEGIN
			print ('Check for internal test')
			--- Check for internal test
			IF EXISTS(
				Select 1 from winktag_campaign as  w, winktag_approved_phone_list as a 
				where a.campaign_id = w.campaign_id
				and w.winktag_type like 'wink_fee'
				and a.phone_no = @phone_no
				and w.internal_testing_status = 1
				and w.winktag_status like '0' 
			)
			BEGIN
				select 1 as success, '' as response_message
				return;
			END
			ELSE
			BEGIN
				select 0 as success , 'Stay tuned for upcoming campaigns' as response_message
				return;
			END
		END
	END
	ELSE
	BEGIN
		select 0 as success , 'Please complete your profile to avail of WINK+ TREATS.' as response_message
		return;
	END
END
