
CREATE PROCEDURE [dbo].[WinkTag_Check_HasAnswer_Refresher_Quiz]
	(@campaign_id int,
     @customer_id int,
	 @question_id int
	 )
AS
 
BEGIN
	IF(@campaign_id != 169)
	BEGIN
		IF EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id = @question_id)
		BEGIN
			SELECT 1 AS success , 'You have already participated in the quiz.' AS response_message
			RETURN
		END
	END
	ELSE IF(@campaign_id = 169)
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

		IF EXISTS (
			SELECT 1 FROM winktag_customer_survey_answer_detail 
			WHERE campaign_id = @campaign_id 
			AND customer_id = @customer_id 
			AND question_id = @question_id
			AND created_at > @latestLinkDate)
		BEGIN
			SELECT 1 AS success , 'You have already answered this question.' AS response_message
			RETURN
		END
	END
END
	




