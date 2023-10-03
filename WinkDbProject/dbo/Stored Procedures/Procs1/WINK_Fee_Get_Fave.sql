
CREATE PROC [dbo].[WINK_Fee_Get_Fave]
@campaign_id int
AS
BEGIN
	
	
	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
		IF (SELECT winktag_type FROM WINKTAG_CAMPAIGN where CAMPAIGN_ID = @campaign_id) = 'wink_fee'
	
		BEGIN
			declare @prodIdFive int;
			declare @prodIdTen int;
			declare @qtyFive int;
			declare @qtyTen int;

			IF(@campaign_id = 164)
			BEGIN
				--NETS Flashpay
				SET @prodIdFive = 20;
				SET @prodIdTen = 21;
			END
			ELSE IF(@campaign_id = 131)
			BEGIN
				--Fave
				SET @prodIdFive = 12;
				SET @prodIdTen = 13;
			END

			select @qtyFive = (qty-redeemed_qty) from wink_products where id = @prodIdFive;
			select @qtyTen = (qty-redeemed_qty) from wink_products where id = @prodIdTen;

			SELECT question_id,option_type, image_name, option_id, option_answer,@qtyFive as fiveCount, @qtyTen as tenCount
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





