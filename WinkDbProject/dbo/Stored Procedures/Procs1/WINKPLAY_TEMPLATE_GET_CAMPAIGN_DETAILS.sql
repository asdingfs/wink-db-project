
CREATE PROCEDURE [dbo].[WINKPLAY_TEMPLATE_GET_CAMPAIGN_DETAILS]
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
		, C.campaign_name
		, C.points
		, C.size
		, C.position
		, C.winktag_status
		, C.internal_testing_status
		, C.campaign_image_large
		, C.campaign_image_small
		, C.from_date
		, C.to_date
		, Q.question_id
		, Q.question
		, Q.question_no
		, O.option_id
		, O.question_id AS option_question_id
		, O.option_answer
		, O.option_type
		, O.image_name
		, O.answer_id
		, D.age_to
		, D.age_from
		, D.gender
		, D.redirection
		, D.banner_type
		, D.background_image
		, D.media_file
		, D.video_preload_image
		, D.header_text
		, D.template_theme
		, D.msg_incomplete
		, D.msg_confirmation
		, D.msg_final
		, D.msg_participated
	FROM winktag_campaign AS C
	INNER JOIN winktag_survey_question AS Q
	ON Q.campaign_id = C.campaign_id
	INNER JOIN winktag_survey_option AS O
	ON O.campaign_id = C.campaign_id
	AND O.question_id = Q.question_id
	LEFT JOIN winkplay_campaign_details AS D
	ON D.campaign_id = C.campaign_id
	WHERE winktag_type = 'template_survey'
	AND C.campaign_id = @campaign_id
	ORDER BY question_id,option_id

	SELECT '1' AS response_code, 'success' as response_message
	return

END
