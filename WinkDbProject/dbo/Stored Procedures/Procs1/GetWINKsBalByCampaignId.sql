CREATE PROC [dbo].[GetWINKsBalByCampaignId]

@authToken VARCHAR(255),
@campaignId INT

AS

DECLARE @MERCHANT_TOTAL_WINKS INT
DECLARE @CUSTOMER_TOTAL_EARNED_WINKS_BY_MERCHANT INT
DECLARE @MERCHANT_BALANCE_WINKS INT

BEGIN
	DECLARE @CURRENT_DATETIME DATETIME
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUT

	--- Check Account Locked
	IF  EXISTS (Select 1 From customer where auth_token = @authToken and status ='disable')
    BEGIN
		SELECT '3' as response_code, 'Your account is locked. Please contact customer service.' as response_message 
		RETURN
    END

	-- Check Multiple Login
	IF NOT EXISTS (Select 1 From customer where auth_token = @authToken)
    BEGIN
		SELECT '2' as response_code, 'Multiple logins not allowed' as response_message 
		RETURN
    END

     ----CHECK DAILY LIMIT--------
	IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @authToken and customer.status ='enable')
	BEGIN 
		SELECT @MERCHANT_TOTAL_WINKS = SUM(TOTAL_WINKS)+ SUM (campaign.total_wink_confiscated) 
		FROM CAMPAIGN 
		WHERE campaign.campaign_id =@campaignId
		AND campaign.campaign_status ='enable'
		AND CONVERT(CHAR(10),@CURRENT_DATETIME,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111)
		GROUP BY campaign.merchant_id

		IF EXISTS (SELECT 1 FROM CUSTOMER_EARNED_WINKS WHERE campaign_id = @campaignId)
		BEGIN
			SELECT @CUSTOMER_TOTAL_EARNED_WINKS_BY_MERCHANT = SUM(TOTAL_WINKS) 
			FROM CUSTOMER_EARNED_WINKS 
			WHERE customer_earned_winks.campaign_id = @campaignId;

			SET @MERCHANT_BALANCE_WINKS = @MERCHANT_TOTAL_WINKS-@CUSTOMER_TOTAL_EARNED_WINKS_BY_MERCHANT;

		END
		ELSE
		BEGIN
			SET @MERCHANT_BALANCE_WINKS = @MERCHANT_TOTAL_WINKS-0
		END
		print(@MERCHANT_BALANCE_WINKS)
		IF (@MERCHANT_BALANCE_WINKS = 0)
		BEGIN
			SELECT '0' as response_code, 'All WINKs have been fully redeemed' as response_message 
			RETURN
		END
		ELSE 
		BEGIN
			SELECT '1' as response_code,  '' as response_message 
			RETURN
		END
	END
END