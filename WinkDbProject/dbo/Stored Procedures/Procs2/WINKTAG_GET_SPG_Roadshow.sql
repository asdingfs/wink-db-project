
CREATE PROC [dbo].[WINKTAG_GET_SPG_Roadshow]
@campaign_id int,
@customer_id int
AS
BEGIN
	

	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
		IF (SELECT winktag_type FROM WINKTAG_CAMPAIGN where CAMPAIGN_ID = @campaign_id) = 'survey'

		BEGIN
		
			SELECT id, campaign_id
			FROM qr_campaign
			WHERE customer_id = @customer_id
			AND redemption_status = '0'
			AND campaign_id = @campaign_id
			order by created_at asc

			return
		END
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

END





