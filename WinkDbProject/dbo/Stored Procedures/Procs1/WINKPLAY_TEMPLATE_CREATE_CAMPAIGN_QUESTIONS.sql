CREATE PROCEDURE [dbo].[WINKPLAY_TEMPLATE_CREATE_CAMPAIGN_QUESTIONS] 
	@campaign_id int,
	@question varchar(200),
	@question_no varchar(50)
AS
BEGIN
	
	DECLARE @current_date datetime;
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

	IF NOT EXISTS(SELECT '1' FROM winktag_campaign WHERE campaign_id = @campaign_id)
		BEGIN
			SELECT '0' AS response_code, 'Invalid Campaign' as response_message
			RETURN
		END

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
	return

END
