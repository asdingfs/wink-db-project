
CREATE PROC [dbo].[WINKTAG_GET_Refresher_Quiz]
@campaign_id int,
@customer_id int

AS
BEGIN
	
	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
		DECLARE @wid varchar(50);
		DECLARE @latestLinkDate datetime

		SELECT @wid=WID 
		FROM customer
		WHERE customer_id = @customer_id;

		SELECT TOP(1) @latestLinkDate = created_at
		FROM training_email_wid_link
		WHERE wid like @wid
		AND campaign_id = @campaign_id
		ORDER BY created_at DESC;


		SELECT C.campaign_id, Q.question_id,Q.question,A.option_id,A.option_answer,A.answer_id
		FROM winktag_campaign AS C 
		INNER JOIN winktag_survey_question AS Q ON C.CAMPAIGN_ID = Q.CAMPAIGN_ID
		INNER JOIN winktag_survey_option AS A ON Q.QUESTION_ID = A.QUESTION_ID AND C.CAMPAIGN_ID = A.CAMPAIGN_ID
		WHERE C.CAMPAIGN_ID = @campaign_id 
		AND Q.question_id not in 
		(SELECT question_id 
		FROM winktag_customer_survey_answer_detail 
		where campaign_id = @campaign_id 
		AND customer_id = @customer_id
		AND created_at > @latestLinkDate)
		ORDER BY question_id,option_id

		RETURN
	
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

END





