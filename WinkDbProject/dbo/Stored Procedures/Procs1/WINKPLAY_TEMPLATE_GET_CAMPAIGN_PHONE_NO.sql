

CREATE PROCEDURE [dbo].[WINKPLAY_TEMPLATE_GET_CAMPAIGN_PHONE_NO]
	@campaign_id int
AS
BEGIN

	IF NOT EXISTS(SELECT '1' FROM winktag_campaign WHERE campaign_id = @campaign_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		RETURN;
	END

	SELECT
		  phone_no
	FROM winktag_approved_phone_list
	WHERE campaign_id = @campaign_id

	SELECT '1' AS response_code, 'success' as response_message
	return

END
