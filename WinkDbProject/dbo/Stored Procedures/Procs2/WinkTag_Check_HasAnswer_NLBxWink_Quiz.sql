
CREATE PROCEDURE [dbo].[WinkTag_Check_HasAnswer_NLBxWink_Quiz]
	(@campaign_id int,
     @customer_id int,
	 @question_id int
	 )
AS
 
   BEGIN

		IF EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id = @question_id)
			Select 1 as success , 'Oops! You have already participated in this survey.' as response_message
			return
		
END
	




