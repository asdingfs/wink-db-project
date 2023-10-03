

CREATE PROCEDURE [dbo].[WINKPLAY_TEMPLATE_GET_CAMPAIGN_DETAILS_MSGS]
	@campaign_id int
AS
BEGIN

	IF NOT EXISTS(SELECT '1' FROM winktag_campaign WHERE campaign_id = @campaign_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		RETURN;
	END

	SELECT
		  C.campaign_id
		, D.header_text
		, D.msg_incomplete
		, D.msg_confirmation
		, D.msg_final
		, D.msg_participated
	FROM winktag_campaign AS C
	LEFT JOIN winkplay_campaign_details AS D
	ON D.campaign_id = C.campaign_id
	WHERE winktag_type = 'template_survey'
	AND C.campaign_id = @campaign_id

	SELECT '1' AS response_code, 'success' as response_message
	return

END
