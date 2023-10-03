
CREATE PROC [dbo].[WINK_Treats_Get_ShopBack]
@campaign_id int,
@product_id int
AS
BEGIN
	
	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
		IF (SELECT winktag_type FROM WINKTAG_CAMPAIGN where CAMPAIGN_ID = @campaign_id) = 'wink_fee'
	
		BEGIN
			declare @remainedQty int;

			select @remainedQty = (qty-redeemed_qty) from wink_products where id = @product_id;

			SELECT question_id,option_type, image_name, option_id, option_answer,@remainedQty as remainedCount
			FROM winktag_survey_option
			WHERE CAMPAIGN_ID = @campaign_id 
		
			ORDER BY question_id,option_id

			return
		END
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

END





