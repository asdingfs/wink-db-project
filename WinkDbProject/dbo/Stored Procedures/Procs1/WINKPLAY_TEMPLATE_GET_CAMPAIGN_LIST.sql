CREATE PROCEDURE [dbo].[WINKPLAY_TEMPLATE_GET_CAMPAIGN_LIST]
	@campaign_id int,
	@campaign_name varchar(200)
AS
BEGIN

	IF @campaign_id = 0
		SET @campaign_id = NULL

	IF @campaign_id IS NOT NULL
	BEGIN
		IF NOT EXISTS(SELECT '1' FROM winktag_campaign WHERE campaign_id = @campaign_id)
		BEGIN
			SELECT '0' AS response_code, 'Invalid Campaign' as response_message
			RETURN;
		END
	END

	SELECT
		  campaign_id
		, campaign_name
		, from_date
		 
	FROM winktag_campaign
	WHERE winktag_type = 'template_survey'
	AND (@campaign_id is null OR  campaign_id = @campaign_id)
	AND (@campaign_name is null OR campaign_name LIKE '%'+@campaign_name+'%')

	SELECT '1' AS response_code, 'success' as response_message
	return

END
