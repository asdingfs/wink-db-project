
CREATE PROC [dbo].[Get_Online_Ordering]
@campaign_id int
AS
BEGIN
	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
		IF (SELECT winktag_type FROM WINKTAG_CAMPAIGN where CAMPAIGN_ID = @campaign_id) = 'WDO'
		BEGIN
			Declare @current_date datetime
			Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output
			
			IF(@current_date <= (select to_date from winktag_campaign where campaign_id = @campaign_id))
			BEGIN
				SELECT '1' AS response_code, 'Valid Campaign' as response_message, @campaign_id as id
				return
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT 1 from wink_delights_online where campaign_id = @campaign_id and completion = 0)
				BEGIN
					Select '2' as response_code, 'For merchant only' as response_message, @campaign_id as id
					Return
				END
				ELSE
				BEGIN
					SELECT '0' AS response_code, 'Campaign has ended' as response_message, @campaign_id as id
					return
				END
			END

		END
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message, @campaign_id as id
		return
	END

END





