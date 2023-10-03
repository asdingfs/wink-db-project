CREATE PROC [dbo].[WINKTAG_RESET_CAMPAIGN_BY_CAMPAIGNID]
(
	@campaign_id int
)

AS

BEGIN

	delete from winktag_customer_action_log where campaign_id = @campaign_id

	delete from winktag_customer_earned_points where campaign_id = @campaign_id

	delete from winktag_customer_survey_answer_detail where campaign_id = @campaign_id

	select '1' as response_code, 'Demo reset' as response_message

END