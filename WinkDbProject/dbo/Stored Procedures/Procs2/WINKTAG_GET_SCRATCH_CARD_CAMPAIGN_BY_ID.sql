
CREATE PROC [dbo].[WINKTAG_GET_SCRATCH_CARD_CAMPAIGN_BY_ID]
@campaign_id int

AS
BEGIN
	
	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
			DECLARE @winnerCount int
			DECLARE @CURRENT_DATE date ;     
			EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT 

			SELECT @winnerCount = 
			COUNT(*) FROM winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id and cast (created_at as date) = @CURRENT_DATE and answer = 'Yes'
			and customer_id not in (
				select e.customer_id 
				FROM winktag_customer_earned_points as e
				where campaign_id = @campaign_id and cast (created_at as date) = @CURRENT_DATE
				and additional_point_status = 1
			);

			SELECT C.campaign_id,Q.question_id,A.option_id, @winnerCount as winner_count
			FROM winktag_campaign AS C 
			INNER JOIN winktag_survey_question AS Q ON C.CAMPAIGN_ID = Q.CAMPAIGN_ID
			INNER JOIN winktag_survey_option AS A ON Q.QUESTION_ID = A.QUESTION_ID AND C.CAMPAIGN_ID = A.CAMPAIGN_ID
			WHERE C.CAMPAIGN_ID = @campaign_id 
			ORDER BY question_id,option_id

			return

	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

END





