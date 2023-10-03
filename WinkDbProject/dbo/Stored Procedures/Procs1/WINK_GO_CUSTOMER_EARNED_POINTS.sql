

CREATE PROC [dbo].[WINK_GO_CUSTOMER_EARNED_POINTS]
@customer_id int,
@campaign_id int,
@points int = 2

AS
BEGIN
/*
DECLARE @interval_status int
DECLARE @interval int
DECLARE @limit int
DECLARE @winktag_type varchar(50)
DECLARE	@survey_type varchar(50)
DECLARE @RETURN_NO VARCHAR(10) = '0'
DECLARE @POINTS int
DECLARE @CURRENT_DATETIME DATE
*/
DECLARE @MESSAGE VARCHAR(250)
/*
DECLARE @POINTS_DESC VARCHAR(10) = ' points.'
DECLARE @POINTS_DESC_EURO VARCHAR(15) = ' points are'
DECLARE @row_count int = 0
DECLARE @campaign_type varchar(20)
DECLARE @campaign_start DATE
*/

DECLARE @CURRENT_DATETIME Datetime ;     
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

DECLARE	@return_value int
DECLARE @counter int=1;

IF(@campaign_id = 146)
	BEGIN
		IF EXISTS
			(
				SELECT 1
				FROM nonstop_net_canid_earned_points
				WHERE card_type = '08'  and customer_id= @customer_id and  cast(created_at as date) = cast(@CURRENT_DATETIME as date) 
			)

			BEGIN
				set @return_value = 0
				SET @MESSAGE = 'You have already checked in today. <br> Check in again daily from 23 April to 7 May to earn 5 WINK+ points'
				SELECT '1' AS response_code, @MESSAGE as response_message
			END
		ELSE
		BEGIN
			set @points = 5
			set @return_value = 0
			WHILE @counter<=@points
				BEGIN
				INSERT INTO [dbo].[nonstop_net_canid_earned_points]
					(can_id,business_date,total_tabs,total_points,created_at,customer_id, card_type,points_credit_status,points_expired_status,campaign_id)
					VALUES ('',@CURRENT_DATETIME,1,1.00,@CURRENT_DATETIME,@customer_id,'08',0,'0',178)
				IF (@@ROWCOUNT > 0) 
					set @return_value = @return_value + 1
				set @counter = @counter + 1
				END
		-- For thematic campaigns
			UPDATE winktag_customer_action_log SET survey_complete_status = 1 
			WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id and cast(created_at as date) = cast(@CURRENT_DATETIME as date);
		END
			
	END
ELSE IF(@campaign_id = 165 or @campaign_id=134) -- For Wink City Game
	/*
		IF EXISTS
			(
				SELECT 1
				FROM nonstop_net_canid_earned_points
				WHERE card_type = '12'  and customer_id= @customer_id and  cast(created_at as date) = cast(@CURRENT_DATETIME as date) 
			)

			BEGIN
				SET @MESSAGE = 'You have already checked in today. <br> Check in again daily from 23 April to 7 May to earn 5 WINK+ points'
				SELECT '1' AS response_code, @MESSAGE as response_message
			END
		ELSE
		*/
		BEGIN
			
			set @return_value = 0
			WHILE @counter<=@points
				BEGIN
				INSERT INTO [dbo].[nonstop_net_canid_earned_points]
					(can_id,business_date,total_tabs,total_points,created_at,customer_id, card_type,points_credit_status,points_expired_status,campaign_id)
					VALUES ('',@CURRENT_DATETIME,1,1.00,@CURRENT_DATETIME,@customer_id,'12',0,'0',207)
				IF (@@ROWCOUNT > 0) 
					set @return_value = @return_value + 1
				set @counter = @counter + 1
				END
		-- For thematic campaigns
			--UPDATE winktag_customer_action_log SET survey_complete_status = 1 
			--WHERE customer_id = @customer_id AND CAMPAIGN_ID = @campaign_id and cast(created_at as date) = cast(@CURRENT_DATETIME as date);
		END
		
		RETURN @return_value

END
