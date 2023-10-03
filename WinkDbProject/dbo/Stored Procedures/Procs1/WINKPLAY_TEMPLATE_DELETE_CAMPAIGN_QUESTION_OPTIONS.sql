


CREATE PROCEDURE [dbo].[WINKPLAY_TEMPLATE_DELETE_CAMPAIGN_QUESTION_OPTIONS] 
	@campaign_id int,
	@option_id int,
	@question_id int
AS
BEGIN
	
	DECLARE @current_date datetime;
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

	IF @option_id = 0
		SET @option_id = NULL

	IF @question_id = 0
		SET @question_id = NULL

	IF NOT EXISTS(SELECT '1' FROM winktag_campaign WHERE campaign_id = @campaign_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		RETURN;
	END

	IF EXISTS (SELECT '1' FROM winktag_survey_option WHERE option_id = @option_id) OR @option_id IS NULL
	BEGIN
		DELETE FROM winktag_survey_option
		WHERE campaign_id = @campaign_id
		AND (@option_id IS NULL OR option_id = @option_id)
		AND (@question_id IS NULL OR question_id = @question_id)

		SELECT '1' AS response_code, 'Campaign question option successfully removed' AS response_message
		RETURN
	END
	SELECT '1' AS response_code, 'No records found' AS response_message
		RETURN	
END
