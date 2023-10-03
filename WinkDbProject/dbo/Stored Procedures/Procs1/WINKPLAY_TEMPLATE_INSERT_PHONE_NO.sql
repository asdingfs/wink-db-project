CREATE PROCEDURE [dbo].[WINKPLAY_TEMPLATE_INSERT_PHONE_NO] 
	@campaign_id int,
	@phone_no int
AS
BEGIN
	DECLARE @current_date datetime;
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

	IF NOT EXISTS(SELECT '1' FROM winktag_campaign WHERE campaign_id = @campaign_id)
		RETURN;

	INSERT INTO winktag_approved_phone_list(
		    campaign_id
		  , phone_no
		  , created_at
	)
	VALUES (
		  @campaign_id
		, @phone_no
		, @current_date
	)

	SELECT '1' AS response_code, 'Phone No successfully inserted' AS response_message
	return

END
