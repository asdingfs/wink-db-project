CREATE PROC [dbo].[GET_WINKTAG_ACTIVE_CAMPAIGN_BY_ID]
@campaign_id int

AS
BEGIN
	
	IF EXISTS (SELECT * FROM WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id AND winktag_status = 1 AND CAST(dateadd(hour,8,getdate()) as datetime) >= CAST(from_date as datetime)
	AND CAST(dateadd(hour,8,getdate()) as datetime) <= CAST(to_date as datetime))
	BEGIN
		IF (SELECT winktag_type FROM WINKTAG_CAMPAIGN where CAMPAIGN_ID = @campaign_id) = 'survey' OR  (SELECT winktag_type FROM WINKTAG_CAMPAIGN where CAMPAIGN_ID = @campaign_id) = 'template_survey'
		BEGIN
			SELECT '1' AS response_code, 'success' as response_message

			SELECT C.campaign_id,C.campaign_name,C.campaign_image_small,C.campaign_image_large,C.winktag_type,Q.question_id,Q.question,A.option_id,A.option_answer
			FROM winktag_campaign AS C 
			INNER JOIN winktag_survey_question AS Q ON C.CAMPAIGN_ID = Q.CAMPAIGN_ID
			INNER JOIN winktag_survey_option AS A ON Q.QUESTION_ID = A.QUESTION_ID AND C.CAMPAIGN_ID = A.CAMPAIGN_ID
			WHERE C.CAMPAIGN_ID = @campaign_id 

			return
		END
	END
	ELSE IF EXISTS (SELECT * FROM winktag_campaign where CAMPAIGN_ID = @campaign_id AND internal_testing_status = 1 AND winktag_status = 0)
	BEGIN
		IF (SELECT winktag_type FROM WINKTAG_CAMPAIGN where CAMPAIGN_ID = @campaign_id) = 'survey' OR (SELECT winktag_type FROM WINKTAG_CAMPAIGN where CAMPAIGN_ID = @campaign_id) = 'template_survey'
		BEGIN
			SELECT '1' AS response_code, 'success' as response_message

			SELECT C.campaign_id,C.campaign_name,C.campaign_image_small,C.campaign_image_large,C.winktag_type,Q.question_id,Q.question,A.option_id,A.option_answer
			FROM winktag_campaign AS C 
			INNER JOIN winktag_survey_question AS Q ON C.CAMPAIGN_ID = Q.CAMPAIGN_ID
			INNER JOIN winktag_survey_option AS A ON Q.QUESTION_ID = A.QUESTION_ID AND C.CAMPAIGN_ID = A.CAMPAIGN_ID
			WHERE C.CAMPAIGN_ID = @campaign_id 

			return
		END
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

END




