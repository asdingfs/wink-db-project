
CREATE PROCEDURE [dbo].[WINKPLAY_TEMPLATE_UPDATE_CAMPAIGN] 
	@campaign_id int,
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
	
	DECLARE @current_date datetime;
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

	IF @position = 0
		SELECT @position = MAX(position + 1) FROM winktag_campaign

	IF @size = 0
		SET @size = 8000;

	IF NOT EXISTS(SELECT '1' FROM winktag_campaign WHERE campaign_id = @campaign_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		RETURN;
	END

	UPDATE winktag_campaign
	SET campaign_name = @campaign_name
	, campaign_image_large = @banner_full
	, campaign_image_small = @banner_half
	, points = @points
	, winktag_status = @winktag_status
	, updated_at = @current_date
	, from_date = @start_date
	, to_date = @end_date
	, content = @campaign_name
	, position = @position
	, size = @size
	, internal_testing_status = @internal_test
	WHERE campaign_id = @campaign_id
	AND winktag_type = 'template_survey'

	SELECT '1' AS response_code, 'Campaign successfully updated' AS response_message, campaign_id AS response_id FROM winktag_campaign WHERE campaign_id = @campaign_id
	return

END
