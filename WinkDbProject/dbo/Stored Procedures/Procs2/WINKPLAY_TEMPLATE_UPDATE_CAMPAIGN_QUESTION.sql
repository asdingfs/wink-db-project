

CREATE PROCEDURE [dbo].[WINKPLAY_TEMPLATE_UPDATE_CAMPAIGN_QUESTION] 
	@campaign_id int,
	@question_id int,
	@question varchar(200),
	@question_no varchar(200)
AS
BEGIN
	
	DECLARE @current_date datetime;
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

	IF @question_id = 0
		SET @question_id = NULL

	IF NOT EXISTS(SELECT '1' FROM winktag_campaign WHERE campaign_id = @campaign_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		RETURN;
	END

	IF EXISTS (SELECT '1' FROM winktag_survey_question WHERE question_id = @question_id)
	BEGIN
		UPDATE winktag_survey_question
		SET question = @question
		, question_no = @question_no
		, updated_at = @current_date
		WHERE campaign_id = @campaign_id
		AND question_id = @question_id

		SELECT '1' AS response_code, 'Campaign question successfully updated' AS response_message
		RETURN
	END

	ELSE
	BEGIN
		INSERT INTO winktag_survey_question (
		  campaign_id
		, question
		, points
		, [status]
		, created_at
		, updated_at
		, question_no
		)
		VALUES (
			  @campaign_id
			, @question
			, 0
			, 1
			, @current_date
			, @current_date
			, @question_no
		)

		SELECT '1' AS response_code, 'Campaign question successfully created' AS response_message
		RETURN
	END
	
END
