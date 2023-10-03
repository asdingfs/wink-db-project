

CREATE PROC [dbo].[Get_WINK_Treats_List]
(@customer_id int)
AS
BEGIN

	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

    -- EngineeringTownHall2023 --
    DECLARE @EngineeringTownHall2023CampaignId int = 213;
    DECLARE @EngineeringTownHall2023Qualified int = 0;
    DECLARE @EngineeringTownHall2023Size int;
    DECLARE @EngineeringTownHall2023MaxSize int = (SELECT size from winktag_campaign where campaign_id = @EngineeringTownHall2023CampaignId);

    SELECT @EngineeringTownHall2023Size = COUNT(*) from winktag_customer_earned_points Where campaign_id = @EngineeringTownHall2023CampaignId;
    IF EXISTS(SELECT 1 FROM CUSTOMER_EARNED_POINTS 
            WHERE CUSTOMER_ID = @CUSTOMER_ID 
            AND QR_CODE = 'TownHallEngineering2023_EngTownHall_01_34063')
    BEGIN
        set @EngineeringTownHall2023Qualified = 1;
    END

    SELECT * FROM winktag_campaign as w WHERE w.winktag_type like 'wink_fee' and w.WINKTAG_STATUS like '1'
	AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
	AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date)
    AND w.campaign_id != @EngineeringTownHall2023CampaignId

    union
    --EngineeringTownHall2023--
    SELECT * FROM winktag_campaign as w 
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

	union --- Internal testing generic
	select * from winktag_campaign WHERE winktag_type like 'wink_fee' and internal_testing_status = 1 and  WINKTAG_STATUS like '0'
	--uncomment below
	AND campaign_id in (select campaign_id from winktag_approved_phone_list as a
	join customer as c
	on a.phone_no = c.phone_no
	where c.customer_id =@customer_id)
					
	order by position asc
END

