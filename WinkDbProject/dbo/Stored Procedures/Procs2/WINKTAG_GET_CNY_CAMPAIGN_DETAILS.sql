
CREATE PROC [dbo].[WINKTAG_GET_CNY_CAMPAIGN_DETAILS]
@campaign_id int,
@customer_id int
AS
BEGIN
	DECLARE @CURRENT_DATE Date ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT 

	declare @count int
	declare @hasWon  int

	set @hasWon = 0;

	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
		IF (SELECT winktag_type FROM WINKTAG_CAMPAIGN where CAMPAIGN_ID = @campaign_id) = 'survey'

		BEGIN
			--actual condition
			--SELECT @count = COUNT(*) FROM winktag_customer_survey_answer_detail where campaign_id = @campaign_id and cast(created_at as date) = @CURRENT_DATE and customer_id = @customer_id;
			-- demo/test condition
			SELECT @count = COUNT(*) FROM winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id;
			IF EXISTS(SELECT 1 FROM winktag_customer_survey_answer_detail where campaign_id = @campaign_id and cast(created_at as date) = @CURRENT_DATE and customer_id = @customer_id and option_answer = '1')
			BEGIN
				SET @hasWon = 1;
			END

			SELECT C.campaign_id,C.campaign_name,Q.question_id,Q.question,A.option_id,A.option_answer,A.image_name,A.option_type, @count as attempt, @hasWon as winningStatus
			FROM winktag_campaign AS C 
			INNER JOIN winktag_survey_question AS Q ON C.CAMPAIGN_ID = Q.CAMPAIGN_ID
			INNER JOIN winktag_survey_option AS A ON Q.QUESTION_ID = A.QUESTION_ID AND C.CAMPAIGN_ID = A.CAMPAIGN_ID
			WHERE C.CAMPAIGN_ID = @campaign_id 
			--actual condition
			--AND @CURRENT_DATE = cast(Q.question as date)
			-- demo/test condition
			AND cast(Q.question as date) = '2019-01-24'
			ORDER BY question_id,option_id

			return
		END
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

END





