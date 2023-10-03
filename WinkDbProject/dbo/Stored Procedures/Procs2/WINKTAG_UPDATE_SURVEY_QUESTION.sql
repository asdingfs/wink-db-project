CREATE PROCEDURE  [dbo].[WINKTAG_UPDATE_SURVEY_QUESTION] 
(
    @question_id int,
 @campaign_id int,
 @question varchar(8000),
 @points int,
 @status int,
 @question_no varchar(200)

   
	 
)
AS
BEGIN 
DECLARE @current_date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
 

Update winktag_survey_question set  
campaign_id=@campaign_id, question=@question, points=@points,  status=@status,updated_at =@current_date, question_no=@question_no 
where question_id = @question_id

If(@@ROWCOUNT>0)
select '1' as response_code , 'Successfully updated' as response_message
Else 
select '0' as response_code , 'Fail to update' as response_message

 
END
