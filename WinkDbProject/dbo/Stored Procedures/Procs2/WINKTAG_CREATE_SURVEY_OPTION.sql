CREATE Procedure [dbo].[WINKTAG_CREATE_SURVEY_OPTION]
(
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
Declare @current_date datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output
insert into winktag_survey_option (campaign_id, question_id,option_answer,status,created_at,updated_at,image_name ,answer_id)
values (@campaign_id, @question_id, @option_answer,@status ,@current_date,@current_date, @image_name,@answer_id )

 If(@@ROWCOUNT>0)
select '1' as response_code , 'Successfully created' as response_message
Else 
select '0' as response_code , 'Fail to create new record' as response_message
END



