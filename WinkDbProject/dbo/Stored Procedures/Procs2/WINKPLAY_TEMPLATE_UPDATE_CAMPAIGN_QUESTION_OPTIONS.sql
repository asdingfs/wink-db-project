﻿


CREATE PROCEDURE [dbo].[WINKPLAY_TEMPLATE_UPDATE_CAMPAIGN_QUESTION_OPTIONS] 
	@campaign_id int,
	@option_id int,
	@question_no varchar(200),
	@option varchar(50),
	@option_type varchar(100),
	@answer_id varchar(100),
	@image varchar(100)
AS
BEGIN
	DECLARE @question_id int
	DECLARE @current_date datetime;
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

	IF @option_id = 0
		SET @option_id = NULL

	IF NOT EXISTS(SELECT '1' FROM winktag_campaign WHERE campaign_id = @campaign_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		RETURN;
	END

	IF NOT EXISTS(SELECT '1' FROM winktag_survey_question WHERE campaign_id = @campaign_id AND question_no = @question_no)
		BEGIN
			SELECT '0' AS response_code, 'Invalid Campaign question' as response_message
			RETURN
		END
	ELSE	
		SELECT @question_id = question_id FROM winktag_survey_question WHERE campaign_id = @campaign_id AND question_no = @question_no

	IF EXISTS (SELECT '1' FROM winktag_survey_option WHERE option_id = @option_id)
	BEGIN
		UPDATE winktag_survey_option
		SET option_answer = @option
		, option_type = @option_type
		, image_name = @image
		, answer_id = @answer_id
		, updated_at = @current_date
		, question_id = @question_id
		WHERE campaign_id = @campaign_id
		AND option_id = @option_id

		SELECT '1' AS response_code, 'Campaign question option successfully updated' AS response_message
		RETURN
	END

	ELSE
	BEGIN
		INSERT INTO winktag_survey_option (
			  campaign_id
			, question_id
			, option_answer
			, [status]
			, created_at
			, updated_at
			, option_type
			, image_name
			, answer_id
		)
		VALUES (
			  @campaign_id
			, @question_id
			, @option
			, 1
			, @current_date
			, @current_date
			, @option_type
			, @image
			, @answer_id
		)

		SELECT '1' AS response_code, 'Campaign question option successfully created' AS response_message
		RETURN
	END
	
END
