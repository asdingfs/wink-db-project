
CREATE PROC [dbo].[WINKTag_Get_Referral_Info]
@campaign_id int,
@customerId int
AS
BEGIN
	
	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
			DECLARE @isNew int = 0;
			
			IF NOT EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customerId)
			BEGIN
				DECLARE @referralRegTime datetime
				SELECT @referralRegTime = created_at FROM customer WHERE customer_id = @customerId;

				IF(@referralRegTime BETWEEN '2020-08-17 12:00:00.000' AND '2020-09-24 08:59:59.000')
				BEGIN
					SET @isNew = 1;
				END
			END

			SELECT C.campaign_id,Q.question_id,A.option_id, @isNew as isNew
			FROM winktag_campaign AS C 
			INNER JOIN winktag_survey_question AS Q ON C.CAMPAIGN_ID = Q.CAMPAIGN_ID
			INNER JOIN winktag_survey_option AS A ON Q.QUESTION_ID = A.QUESTION_ID AND C.CAMPAIGN_ID = A.CAMPAIGN_ID
			WHERE C.CAMPAIGN_ID = @campaign_id 
			ORDER BY question_id desc,option_id desc

			return

	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

END





