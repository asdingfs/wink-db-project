
CREATE PROC [dbo].[WINKTAG_CHAMPS_BOARD]
@campaign_id int

AS
BEGIN
	
	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
			IF(@campaign_id = 112)
			BEGIN
			SET @campaign_id = 111;

			SELECT * from (
				SELECT COUNT(answer) as referral, 'champs_kb.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like 'SN34'

				UNION

				SELECT COUNT(answer) as referral, 'champs_kr.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like 'X5N4'

				UNION

				SELECT COUNT(answer) as referral, 'champs_kp.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like '3L8Y'

				UNION

				SELECT COUNT(answer) as referral, 'champs_kg.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like '873F'

				UNION

				SELECT COUNT(answer) as referral, 'champs_knb.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like '5KB7'

				UNION

				SELECT COUNT(answer) as referral, 'champs_knr.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like '2KR3'

				UNION

				SELECT COUNT(answer) as referral, 'champs_knp.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like '4KP5'

				UNION

				SELECT COUNT(answer) as referral, 'champs_kng.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like '3KG4'

				UNION

				SELECT COUNT(answer) as referral, 'champs_wb.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like 'W3B5'

				UNION

				SELECT COUNT(answer) as referral, 'champs_wr.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like 'W4R2'

				UNION

				SELECT COUNT(answer) as referral, 'champs_wp.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like 'W5P4'

				UNION

				SELECT COUNT(answer) as referral, 'champs_wg.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like 'W7G3'

				UNION

				SELECT COUNT(answer) as referral, 'champs_qb.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like '7QP3'

				UNION

				SELECT COUNT(answer) as referral, 'champs_qr.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like '5QG4'

				UNION

				SELECT COUNT(answer) as referral, 'champs_qp.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like '4QR2'

				UNION

				SELECT COUNT(answer) as referral, 'champs_qg.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like '3QB5'

				UNION

				SELECT COUNT(answer) as referral, 'champs_sb.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like '8XP9'

				UNION

				SELECT COUNT(answer) as referral, 'champs_sr.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like '7YR2'

				UNION

				SELECT COUNT(answer) as referral, 'champs_sp.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like '6QS3'

				UNION

				SELECT COUNT(answer) as referral, 'champs_sg.png' as code from winktag_customer_survey_answer_detail 
				where campaign_id = @campaign_id and answer like '4FT5'
			) as T
			order by T.referral desc
			

			END
			

			return

	END
	

END





