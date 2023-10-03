CREATE PROCEDURE [dbo].[WINKPLAY_TEMPLATE_CREATE_CAMPAIGN_DETAILS] 
	@campaign_id int,
	@age_to int,
	@age_from int,
	@gender varchar(250),
	@redirection varchar(250),
	@banner_type varchar(250),
	@media_file varchar(250),
	@video_preload varchar(250),
	@header_text varchar(250),
	@header_logo varchar(250),
	@template varchar(250),
	@msg_incomplete varchar(250),
	@msg_confirmation varchar(250),
	@msg_final varchar(250),
	@msg_participated varchar(250),
	@background_image varchar(250)
AS
BEGIN
	DECLARE @current_date datetime;
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

	IF NOT EXISTS(SELECT '1' FROM winktag_campaign WHERE campaign_id = @campaign_id)
		BEGIN
			SELECT '0' AS response_code, 'Invalid Campaign' as response_message
			RETURN
		END

	INSERT INTO winkplay_campaign_details(
		    campaign_id
		  , age_to
		  , age_from
		  , gender
		  , redirection
		  , banner_type
		  , background_image
		  , media_file
		  , video_preload_image
		  , header_text
		  , header_logo
		  , template_theme
		  , msg_incomplete
		  , msg_confirmation
		  , msg_final
		  , msg_participated
		  , created_at
		  , updated_at
	)
	VALUES (
		  @campaign_id
		, @age_to
		, @age_from
		, @gender
		, @redirection
		, @banner_type
		, @background_image
		, @media_file
		, @video_preload
		, @header_text
		, @header_logo
		, @template
		, @msg_incomplete
		, @msg_confirmation
		, @msg_final
		, @msg_participated
		, @current_date
		, @current_date
	)

	SELECT '1' AS response_code, 'Campaign details successfully created' AS response_message
	return;

END
