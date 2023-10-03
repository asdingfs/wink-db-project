CREATE PROC [dbo].[WINKPlay_Check_WINKPlay_Campaign_By_Campaign_ID]
@campaign_id int,
@customer_id int,
@location varchar(250),
@ip_address varchar(50)

AS 

BEGIN

	--1)CHECK CUSTOMER
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_CUSTOMER WHERE customer_id = @customer_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Customer' as response_message
		return
	END

	--2)CHECK CAMPAIGN
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

	IF @location is null or @location = '' or @location = '(null)'
		SET @location = 'User location cannot be detected'

	EXEC [WINKPlay_Customer_Action_Log_Detail] @campaign_id,@customer_id,@location,@ip_address


	SELECT '0' AS response_code, 'Contest starts at 9.00am on 16 February 2018. See you then!' as response_message
	return 

END
