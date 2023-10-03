CREATE PROCEDURE [dbo].[Link_WID_To_Training] 
(
	@email varchar(100),
	@wid varchar(50),
	@campaignId int
)
AS
BEGIN
	Declare @current_datetime datetime
	Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

	IF(@campaignId IS NULL OR @campaignId = 0)
	BEGIN
		SELECT '0' AS success, 'Please try again later.' as msg;
		RETURN
	END

	IF(@wid IS NULL or @wid = '')
	BEGIN
		SELECT '0' AS success, 'Please enter a valid WID.' as msg;
		RETURN
	END

	IF(@email NOT LIKE '%@smrt.com.sg' AND @email NOT LIKE '%@stellarlifestyle.com.sg')
	BEGIN
		SELECT '0' AS success, 'Please enter a valid work email address.' as msg;
		RETURN
	END

	IF EXISTS (SELECT 1 FROM training_email_wid_link WHERE wid like @wid and email not like @email AND campaign_id = @campaignId)
	BEGIN
		SELECT '0' AS success, 'Sorry. The WID you entered is already associated with a different work email account.' as msg;
		RETURN
	END

	IF EXISTS (SELECT 1 FROM training_email_wid_link WHERE wid like @wid and email like @email AND campaign_id = @campaignId)
	BEGIN
		DECLARE @customerId int;
		DECLARE @totalQueCount int = 0
		DECLARE @latestLinkDate datetime

		SELECT TOP(1) @latestLinkDate = created_at
		FROM training_email_wid_link
		WHERE email like @email
		AND campaign_id = @campaignId
		ORDER BY created_at DESC;

		SELECT @customerId = customer_id 
		FROM customer
		WHERE WID like @wid;

		SELECT @totalQueCount = COUNT(question_id) from winktag_survey_question where campaign_id = @campaignId;
		
		IF EXISTS(
			SELECT 1
			FROM winktag_customer_survey_answer_detail
			WHERE campaign_id = @campaignId
			AND customer_id = @customerId
			AND created_at > @latestLinkDate
		)
		BEGIN
			IF(
				(
					SELECT COUNT(*) 
					FROM winktag_customer_survey_answer_detail
					WHERE campaign_id = @campaignId
					AND customer_id = @customerId
					AND created_at > @latestLinkDate
				)<@totalQueCount
			)
			BEGIN
				SELECT '0' AS success, 'The WID associated with this email account is already activated. You may proceed to WINK+ PLAY to complete the WINK+ Refresher quiz.' as msg, '' as code;
				RETURN
			END
		END
	END

	IF NOT EXISTS(SELECT 1 FROM customer WHERE WID like @wid AND [status] like 'enable')
	BEGIN
		SELECT '0' AS success, 'Please enter a valid WID.' as msg;
		RETURN
	END

	INSERT INTO [dbo].[training_email_wid_link]
           ([email]
           ,[wid]
		   ,[campaign_id]
           ,[created_at])
     VALUES
           (@email
           ,@wid
		   ,@campaignId
           ,@current_datetime);
	IF(@@ROWCOUNT > 0)
	BEGIN		
		SELECT '1' AS success, 'Congratulations! You have activated your WID and are now eligible to participate in Staff Engagement and Training!' as msg;
		RETURN
	END
	ELSE
	BEGIN
		SELECT '0' AS success, 'Please try again later' as msg;
		RETURN
	END
END
