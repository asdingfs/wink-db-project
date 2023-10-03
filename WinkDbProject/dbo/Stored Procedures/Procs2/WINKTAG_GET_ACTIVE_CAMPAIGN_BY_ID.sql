
CREATE PROC [dbo].[WINKTAG_GET_ACTIVE_CAMPAIGN_BY_ID]
@campaign_id int

AS
BEGIN
	
	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
		declare @winktagType varchar(50)
		set @winktagType =(SELECT winktag_type FROM WINKTAG_CAMPAIGN where CAMPAIGN_ID = @campaign_id);

		IF (@winktagType = 'survey' or @winktagType = 'TripleA' or @winktagType = 'video_survey' or @winktagType = 'template_survey')
		BEGIN
			--SELECT '1' AS response_code, 'success' as response_message

			SELECT C.campaign_id,C.campaign_name,C.campaign_image_small,C.campaign_image_large,C.winktag_type,Q.question_id,Q.question,A.option_id,A.option_answer,A.image_name,A.option_type,A.answer_id,CD.redirection,CD.background_image,CD.video_preload_image,CD.media_file,CD.template_theme,CD.header_text,CD.header_logo,CD.msg_incomplete,CD.msg_confirmation,CD.msg_participated 
			FROM winktag_campaign AS C 
			INNER JOIN winktag_survey_question AS Q ON C.CAMPAIGN_ID = Q.CAMPAIGN_ID
			INNER JOIN winktag_survey_option AS A ON Q.QUESTION_ID = A.QUESTION_ID AND C.CAMPAIGN_ID = A.CAMPAIGN_ID
			LEFT JOIN winkplay_campaign_details AS CD ON C.CAMPAIGN_ID = CD.CAMPAIGN_ID
			WHERE C.CAMPAIGN_ID = @campaign_id 
			ORDER BY question_id,option_id
			return
		END
        ELSE IF(@winktagType = 'winkhunt')
        BEGIN
            SELECT campaign_id, campaign_name, campaign_image_small, campaign_image_large, winktag_type, '' AS question_id, '' AS question, '' AS option_id, '' as option_answer, '' AS image_name, '' AS option_type, '' AS answer_id, '' AS redirection, '' AS background_image, '' AS video_preload_image, '' AS media_file, '' AS template_theme, '' AS header_text, '' AS header_logo, '' AS msg_incomplete, '' AS msg_confirmation, '' AS msg_participated
            FROM winktag_campaign
            WHERE campaign_id = @campaign_id
        RETURN
        END
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

END





