
CREATE PROC [dbo].[WEB_CUSTOMER_SURVEY_QUESTION_ANSWER_DETAIL]
@campaign_id int,
@question_id int,
@option_id int,
@option varchar(250),
@answer varchar(1000),
@ip_address varchar(50)
AS

BEGIN

	DECLARE @option_answer varchar(250)
	DECLARE @question_no varchar(10) = ''
	DECLARE @row_count int = 0
	DECLARE @location varchar(250)
	

	set @location = '';
	--2)CHECK CAMPAIGN
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
	BEGIN
	   SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END


	--3)CHECK ANSWER TYPE
	
	IF (SELECT option_type FROM winktag_survey_option WHERE option_id = @option_id AND question_id = @question_id AND campaign_id = @campaign_id) = 'textbox'
		SET @option_answer = @answer
	ELSE
		SET @option_answer = (SELECT option_answer FROM winktag_survey_option WHERE option_id = @option_id AND question_id = @question_id AND campaign_id = @campaign_id)	
	

	--4)GET QUESTION NO
	IF (SELECT winktag_report FROM winktag_campaign WHERE campaign_id = @campaign_id) = 'AvengersEndgameReport'--check for Avengers Endgame
	BEGIN
		SET @question_no = (SELECT answer_id FROM winktag_survey_option WHERE campaign_id = @campaign_id AND question_id = @question_id and option_id = @option_id)
		IF @question_no is null
			SET @question_no = ''
	END
	
	ELSE
	BEGIN
		SET @question_no = (SELECT question_no FROM winktag_survey_question WHERE campaign_id = @campaign_id AND question_id = @question_id)
		IF @question_no is null
			SET @question_no = ''
	END

	--6)CHECK ROW COUNT
	SET @row_count = 1
	
    BEGIN

    IF(@campaign_id = 63)
	BEGIN
		INSERT INTO [dbo].[winktag_customer_survey_answer_detail]
		([customer_id]
		,[campaign_id]
		,[question_id]
		,[option_id]
		,[option_answer]
		,[answer]
		,[created_at]
		,[question_no]
		,[row_count]
		,[ip_address])
		VALUES
		(0,@campaign_id,@question_id,@option_id,@option_answer,@option_answer,(SELECT TODAY FROM VW_CURRENT_SG_TIME),@question_no,@row_count,@ip_address)
	END

	END
	 
		 
	IF @@ROWCOUNT > 0
	BEGIN
		If(@campaign_id = 63)
		BEGIN

			SELECT '1' AS response_code, 'Thank you for participating! Winner will be notified via email.' as response_message
			return

		END

	END
	ELSE
		BEGIN
			SELECT '0' AS response_code, 'Insert Fail' as response_message
			return
		END
	
	
END

