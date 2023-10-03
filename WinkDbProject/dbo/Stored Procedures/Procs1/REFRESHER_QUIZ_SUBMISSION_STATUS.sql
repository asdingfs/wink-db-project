CREATE PROC [dbo].[REFRESHER_QUIZ_SUBMISSION_STATUS]
(
	
	@winktag_report varchar(50)
)
AS

BEGIN

	DECLARE @CAMPAIGN_ID int
	
	
	
	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
		RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)

	IF(@CAMPAIGN_ID = 142)
	BEGIN
	
		
			(SELECT COUNT(customer_id) AS ansStatus FROM winktag_customer_survey_answer_detail
			WHERE question_id = 385) 

			 UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 386) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 387) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 388) 
	
			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 389) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 390) 
			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 391) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 392) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 393) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 394) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 395) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 396) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 397) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 398) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 399) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 400) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 401) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 402) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 403) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 404) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 405) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 406) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 407) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 408) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 409) 
	END
	ELSE IF(@CAMPAIGN_ID = 102)
	BEGIN
	
		
			(SELECT COUNT(customer_id) AS ansStatus FROM winktag_customer_survey_answer_detail
			WHERE question_id = 288) 

			 UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 289) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 290) 

			UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE question_id = 291) 
	
	
	
	END

END



