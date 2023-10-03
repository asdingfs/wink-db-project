
CREATE PROC [dbo].[WINKTAG_GET_SCRATCH_CARD_EXISTING_RECORD]
@campaign_id int,
@customer_id int
AS
BEGIN
	
	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
			
			DECLARE @CURRENT_DATE date ;     
			EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT 

			SELECT answer FROM winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id 
			and cast (created_at as date) = @CURRENT_DATE 
			and customer_id = @customer_id;

			return

	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

END





