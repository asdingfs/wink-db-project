
CREATE PROCEDURE [dbo].[Check_CustomerID_Has_Answer_Cny]
	(@campaign_id int,
     @customer_id int,
	 @question_id int
	 )
AS
 
   BEGIN
		declare @isEligible int

		set @isEligible = 1;

		IF ((select COUNT(*) from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id= @question_id) = 3) 
			set @isEligible = 0;

		IF EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and question_id= @question_id and option_answer = '1') 
			set @isEligible = 0;
		
		IF(@isEligible = 0)
			Select 1 as success , 'You have already participated in the survey.' as response_message
			return
		
END
	




