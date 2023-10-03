
CREATE PROC [dbo].[WINKTAG_GET_NLBxWInk_Quiz]
@campaign_id int,
@customer_id int

AS
BEGIN
	
	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
		
			SELECT C.campaign_id, Q.question_id,Q.question,A.option_id,A.option_answer,A.answer_id,A.image_name,A.option_type
			FROM winktag_campaign AS C 
			INNER JOIN winktag_survey_question AS Q ON C.CAMPAIGN_ID = Q.CAMPAIGN_ID
			INNER JOIN winktag_survey_option AS A ON Q.QUESTION_ID = A.QUESTION_ID AND C.CAMPAIGN_ID = A.CAMPAIGN_ID
			WHERE C.CAMPAIGN_ID = @campaign_id 
			AND Q.question_id not in 
			(SELECT question_id FROM winktag_customer_survey_answer_detail where campaign_id = @campaign_id AND customer_id = @customer_id)

			ORDER BY question_id,option_id

			return
	
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

END





