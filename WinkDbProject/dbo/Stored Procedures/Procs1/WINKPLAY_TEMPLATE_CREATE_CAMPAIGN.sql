CREATE PROCEDURE [dbo].[WINKPLAY_TEMPLATE_CREATE_CAMPAIGN] 
	@campaign_name varchar(200),
	@banner_full varchar(200),
	@banner_half varchar(200),
	@points int,
	@winktag_status int,
	@start_date varchar(50),
	@end_date varchar(50),
	@size int,
	@position int,
	@report varchar(200),
	@internal_test int
AS
BEGIN
	DECLARE @CAMPAIGN_ID int;
	
	DECLARE @current_date datetime;
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

	IF @position = 0
		SELECT @position = MAX(position + 1) FROM winktag_campaign

	IF @size = 0
		SET @size = 8000;

	INSERT INTO winktag_campaign (
		  campaign_name
		, campaign_image_large
		, campaign_image_small
		, points
		, interval_status
		, winktag_type
		, winktag_status
		, created_at
		, updated_at
		, from_date
		, to_date
		, interval_type
		, content
		, survey_type
		, position
		, winktag_report
		, size
		, internal_testing_status
	)
	VALUES (
		  @campaign_name
		, @banner_full
		, @banner_half
		, @points
		, 0
		, 'template_survey'
		, @winktag_status
		, @current_date
		, @current_date
		, @start_date
		, @end_date
		, ''
		, @campaign_name
		, 'all'
		, @position
		, @report
		, @size
		, @internal_test
	)

	SELECT '1' AS response_code, 'Campaign successfully created' AS response_message, campaign_id AS response_id FROM winktag_campaign WHERE created_at = @current_date
	return

END
