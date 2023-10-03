CREATE PROCEDURE  [dbo].[WINKTAG_UPDATE_SURVEY_OPTION] 
(
    @option_id int,
 @campaign_id int,
 @question_id int,
 @option_answer varchar(8000),
 @option_type  varchar(100),
 @status int,
 @answer_id varchar(200),
  @image_name varchar(200)
   
	 
)
AS
BEGIN 
DECLARE @current_date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
 

Update winktag_survey_option set  
campaign_id=@campaign_id, question_id=@question_id, option_answer=@option_answer, option_type=@option_type, status=@status,updated_at =@current_date, answer_id=@answer_id ,image_name=@image_name
where option_id = @option_id

If(@@ROWCOUNT>0)
select '1' as response_code , 'Successfully updated' as response_message
Else 
select '0' as response_code , 'Fail to update' as response_message

 
END
