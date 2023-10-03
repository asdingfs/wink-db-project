



CREATE PROCEDURE [dbo].[WINKPLAY_TEMPLATE_DELETE_CAMPAIGN_QUESTION] 
	@campaign_id int,
	@question_id int
AS
BEGIN
	
	DECLARE @current_date datetime;
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

	IF NOT EXISTS(SELECT '1' FROM winktag_campaign WHERE campaign_id = @campaign_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		RETURN;
	END

	IF EXISTS (SELECT '1' FROM winktag_survey_question WHERE question_id = @question_id)
	BEGIN
		DELETE FROM winktag_survey_question
		WHERE campaign_id = @campaign_id
		AND question_id = @question_id

		SELECT '1' AS response_code, 'Campaign question option successfully removed' AS response_message

		EXEC WINKPLAY_TEMPLATE_DELETE_CAMPAIGN_QUESTION_OPTIONS @campaign_id = @campaign_id, @option_id = 0, @question_id = @question_id

		RETURN
	END
	SELECT '1' AS response_code, 'No records found' AS response_message
		RETURN	
END
