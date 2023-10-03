CREATE PROC [dbo].[WINKTAG_RESET_CAMPAIGN_BY_CAMPAIGNID_CUSTOMERID]
(
	@customer_id int,
	@campaign_id int
)

AS

BEGIN

	--set @campaign_id = 18

	delete from winktag_customer_action_log where campaign_id = @campaign_id and customer_id = @customer_id

	delete from winktag_customer_earned_points where campaign_id = @campaign_id and customer_id = @customer_id

	delete from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id

	select '1' as response_code, 'Demo reset' as response_message

END