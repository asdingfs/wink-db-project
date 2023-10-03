CREATE PROC [dbo].[REFRESHER_QUIZ_RESULT]
(
	@campaign_id int,
	@question_index varchar(5)
)
AS

BEGIN

	Declare @question_id int;
	Declare @question varchar(255);
	
	IF(@campaign_id = 142 or @campaign_id = 102)
	BEGIN
		SELECT @question = question, @question_id = question_id FROM winktag_survey_question WHERE campaign_id = @campaign_id and question_no = 'Q'+@question_index; 

		DECLARE @optionId int;

		DECLARE Option_Id_Cursor CURSOR FOR  
		SELECT option_id
		FROM winktag_survey_option where question_id = @question_id;

		OPEN Option_Id_Cursor;

		Declare @optionsList TABLE(question varchar(255), answer varchar(255), selectedOption int);
 
		FETCH NEXT FROM Option_Id_Cursor INTO @optionId;  
		WHILE @@FETCH_STATUS = 0  
		BEGIN  

			DECLARE @curNum int;
			Declare @curOption varchar(255);

			SELECT @curNum = COUNT(customer_id)
			FROM winktag_customer_survey_answer_detail where option_id = @optionId;

			SELECT @curOption = option_answer 
			FROM winktag_survey_option where option_id = @optionId;

			INSERT INTO @optionsList (question,answer, selectedOption) VALUES (@question,@curOption,@curNum);

			FETCH NEXT FROM Option_Id_Cursor into @optionId; 

		END
		
		CLOSE Option_Id_Cursor;  
		DEALLOCATE Option_Id_Cursor;

		SELECT * FROM @optionsList;
		
	END

END



