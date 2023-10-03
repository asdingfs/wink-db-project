
CREATE PROC [dbo].[WINKTAG_GET_CHAMPS_BY_ID]
@campaign_id int

AS
BEGIN
	
	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
			
			DECLARE @CURRENT_DATE date ;     
			EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT 

			
			SELECT C.campaign_id,Q.question_id,A.option_id
			FROM winktag_campaign AS C 
			INNER JOIN winktag_survey_question AS Q ON C.CAMPAIGN_ID = Q.CAMPAIGN_ID
			INNER JOIN winktag_survey_option AS A ON Q.QUESTION_ID = A.QUESTION_ID AND C.CAMPAIGN_ID = A.CAMPAIGN_ID
			WHERE C.CAMPAIGN_ID = @campaign_id 
			ORDER BY question_id desc,option_id desc

			return

	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

END





