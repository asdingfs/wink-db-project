
create PROCEDURE [dbo].[Get_WinkHunt_Access_Code]
    @campaignId int,
    @customerId int,
    @ip_address VARCHAR(50),
    @location VARCHAR(250)
AS
BEGIN
    DECLARE @current_datetime datetime
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime output
 
	IF (@customerId is null or @customerId = '')
	BEGIN
		SELECT '0' AS success, 'Poor network connection. Please try again later.' as msg;
		return
	END

	--1)CHECK CUSTOMER
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_CUSTOMER WHERE customer_id = @customerId)
	BEGIN
		SELECT '0' AS success,  'Your account is locked. Please contact customer service.' as msg;
		return
	END

	--2)CHECK CAMPAIGN
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaignId)
	BEGIN
		SELECT '0' AS success,  'This campaign has ended.' as msg;
		return
	END
	--3)Check if user has already participated in the campaign
	IF EXISTS(SELECT 1 from TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS L
    JOIN TBL_WINKPLAY_WINKHUNT_CODES AS C
    ON L.WP_WH_CODES_ID = C.WP_WH_CODES_ID
    WHERE L.customer_id = @customerId AND C.campaign_id = @campaignId)
	BEGIN
		SELECT '0' AS success,  'You have already participated in this campaign.' as msg;
		return
	END

    --4)CHECK IF HITS THE INVENTORY COUNT
    DECLARE @winktag_campaign_size INT;
    SELECT @winktag_campaign_size = size
    FROM winktag_campaign
    WHERE campaign_id = @campaignId;

    IF(
        SELECT COUNT(*)
        FROM TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS L
        JOIN TBL_WINKPLAY_WINKHUNT_CODES AS C 
        ON L.WP_WH_CODES_ID = C.WP_WH_CODES_ID
        WHERE C.campaign_id = @campaignId AND C.used_status = 1
    ) >= @winktag_campaign_size
    BEGIN
        SELECT '0' AS success, 'The access code has been fully redeemed.' as msg;
        RETURN
    END

    --5)CHECK LOCATION	
    IF @location is null or @location = '' or @location = '(null)'
    BEGIN
		SET @location = 'User location cannot be detected';
    END



    DECLARE @wp_wh_codes_id INT;
    DECLARE @promo_code VARCHAR(110);
    DECLARE @wink_point_value INT;
    
    IF EXISTS (
        SELECT 1 FROM TBL_WINKPLAY_WINKHUNT_CODES 
        WHERE campaign_id = @campaignId AND used_status = 0
    )
    BEGIN
        SELECT TOP 1 @wp_wh_codes_id = WP_WH_CODES_ID, @promo_code = promo_code, @wink_point_value = wink_point_value
        FROM TBL_WINKPLAY_WINKHUNT_CODES 
        WHERE campaign_id = @campaignId AND used_status = 0

        UPDATE TBL_WINKPLAY_WINKHUNT_CODES
        SET used_status = 1, updated_on = @current_datetime
        WHERE campaign_id = @campaignId AND WP_WH_CODES_ID = @wp_wh_codes_id AND used_status = 0

        IF @@ROWCOUNT > 0
        BEGIN
            INSERT INTO TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG
            (ip_address,location,created_on,updated_on,customer_id,WP_WH_CODES_ID)
            VALUES
            (@ip_address, @location, @current_datetime, @current_datetime, @customerId, @wp_wh_codes_id)

            UPDATE winktag_customer_action_log
            SET survey_complete_status = 1
            WHERE campaign_id = @campaignId AND customer_id = @customerId

            --REMOVE DUPLICATE ENTRIES RECORD--
            DELETE w1 FROM winktag_customer_action_log AS w1
            INNER JOIN (
                SELECT * FROM winktag_customer_action_log
                WHERE campaign_id = @campaignId AND customer_id = @customerId
            ) AS subquery
                ON w1.customer_id = subquery.customer_id
                AND w1.campaign_id = subquery.campaign_id
                AND w1.created_at < subquery.created_at
            
            DECLARE @cusEmail VARCHAR(200);
            DECLARE @cusName VARCHAR(100);
            SELECT @cusEmail = email, @cusName = first_name
            FROM customer where customer_id = @customerId;

            SELECT '1' AS success, 'A verification code has been sent to your registered email.' AS msg, @promo_code AS accessCode, @cusEmail AS cusEmail, @cusName AS cusName;
        END
        ELSE
        BEGIN
            SELECT '2' AS success, 'Please try again later.'AS msg;
        END

    END
    ELSE
    BEGIN
        SELECT '0' AS success, 'The access codes have been fully redeemed.' as msg;
    END
END
