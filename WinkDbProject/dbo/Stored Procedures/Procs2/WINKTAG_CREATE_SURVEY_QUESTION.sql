CREATE Procedure [dbo].[WINKTAG_CREATE_SURVEY_QUESTION]
(
 @campaign_id int,
 @question varchar(8000),
 @points int,
 @status int,
 @question_no varchar(200)


)

AS
BEGIN
Declare @current_date datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output
insert into winktag_survey_question (campaign_id, question,points,status,created_at,updated_at,question_no)
values (@campaign_id, @question, @points,@status ,@current_date,@current_date, @question_no )

  If(@@ROWCOUNT>0)
select '1' as response_code , 'Successfully created' as response_message
Else 
select '0' as response_code , 'Fail to create new record' as response_message
END



