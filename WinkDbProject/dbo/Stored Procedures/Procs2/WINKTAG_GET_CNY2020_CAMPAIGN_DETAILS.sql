
CREATE PROC [dbo].[WINKTAG_GET_CNY2020_CAMPAIGN_DETAILS]
@campaign_id int
AS
BEGIN
	DECLARE @CURRENT_DATE Date ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT 
	

	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
		IF (SELECT winktag_type FROM WINKTAG_CAMPAIGN where CAMPAIGN_ID = @campaign_id) = 'survey'

		BEGIN
		
		
			SELECT C.campaign_id,Q.question_id,A.option_id, A.option_answer, A.option_type as inventory_count, A.image_name as winner_count
			FROM winktag_campaign AS C 
			INNER JOIN winktag_survey_question AS Q ON C.CAMPAIGN_ID = Q.CAMPAIGN_ID
			INNER JOIN winktag_survey_option AS A ON Q.QUESTION_ID = A.QUESTION_ID AND C.CAMPAIGN_ID = A.CAMPAIGN_ID
			WHERE C.CAMPAIGN_ID = @campaign_id 
			AND Q.question = @CURRENT_DATE
			ORDER BY question_id,option_id;

			return
		END
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

END





