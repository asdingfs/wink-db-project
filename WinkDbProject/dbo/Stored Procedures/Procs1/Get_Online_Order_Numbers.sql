
CREATE PROC [dbo].[Get_Online_Order_Numbers]
@campaign_id int
AS
BEGIN
	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
		IF (SELECT winktag_type FROM WINKTAG_CAMPAIGN where CAMPAIGN_ID = @campaign_id) = 'WDO'
		BEGIN
			Declare @current_date datetime
			Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output
			
			IF EXISTS (SELECT 1 from wink_delights_online where campaign_id = @campaign_id and completion = 0)
			BEGIN
				SELECT TOP(5) order_number, id from wink_delights_online where completion = 0 order by cus_date asc;
			END
			ELSE
			BEGIN
				SELECT '' AS order_number;
			END
			
		END
	END
	ELSE
	BEGIN
		SELECT '' AS order_number;
	END

END





