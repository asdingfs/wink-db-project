
CREATE PROCEDURE [dbo].[Check_CustomerID_Has_Answer_Word_Play]
	(@campaign_id int,
     @customer_id int,
	 @question_id int
	 )
AS
 
   BEGIN

		IF EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id= @question_id)
			Select 1 as success , 'You have already participated in the survey.' as response_message
			return
		
END
	




