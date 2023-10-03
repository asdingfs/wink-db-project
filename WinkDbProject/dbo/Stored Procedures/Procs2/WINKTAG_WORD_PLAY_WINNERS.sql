CREATE PROC [dbo].[WINKTAG_WORD_PLAY_WINNERS]
(
	@campaign_id int
)
AS

BEGIN

	IF(@campaign_id = 46)
		BEGIN
			SELECT c.first_name +' '+c.last_name as customer_name, a.created_at FROM customer as c, winktag_customer_survey_answer_detail as a
				where c.customer_id = a.customer_id 
				and a.campaign_id = @campaign_id
				and a.option_answer = 1
			
		END
	ELSE IF(@campaign_id = 48)
		BEGIN
			SELECT c.first_name +' '+c.last_name as customer_name, a.created_at FROM customer as c, winktag_customer_survey_answer_detail as a
				where c.customer_id = a.customer_id 
				and a.campaign_id = @campaign_id
				and a.option_answer = '1'
			
		END

END



