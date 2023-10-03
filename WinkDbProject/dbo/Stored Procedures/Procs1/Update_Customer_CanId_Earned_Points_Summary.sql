-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Update_Customer_CanId_Earned_Points_Summary]
(@can_id varchar(50),
@total_points int,
@total_tabs int,
@created_at DateTime)
AS
BEGIN
DECLARE @CURRENT_TOTAL_POINTS INT
DECLARE @CURRENT_TOTAL_TABS INT
	IF EXISTS (SELECT * FROM customer_canid_earned_points_summary WHERE can_id =@can_id)
		BEGIN
		SELECT @CURRENT_TOTAL_POINTS = total_points FROM customer_canid_earned_points_summary WHERE can_id =@can_id
		SELECT @CURRENT_TOTAL_TABS = total_tabs FROM customer_canid_earned_points_summary WHERE can_id =@can_id
        UPDATE customer_canid_earned_points_summary SET 
        total_points =@CURRENT_TOTAL_POINTS+@total_points,
        total_tabs = @CURRENT_TOTAL_TABS +@total_tabs,
        created_at = @created_at
        WHERE can_id =@can_id
        IF(@@ROWCOUNT>0)
			BEGIN
			SELECT '1' AS response_code 
			RETURN
			END
		ELSE 
			BEGIN
			SELECT '0' AS response_code , 'Update Fail' As response_message
			RETURN
			END
        
		END
		
	ELSE 
		BEGIN
		INSERT INTO customer_canid_earned_points_summary (CAN_ID, TOTAL_POINTS,TOTAL_TABS,CREATED_AT)
		VALUES (@can_id,@total_points,@total_tabs,@created_at)
		IF(@@ROWCOUNT>0)
			BEGIN
			SELECT '1' AS response_code 
		
			END
		ELSE 
			BEGIN
			SELECT '0' AS response_code , 'Insert Fail' As response_message
			END
		END
		
			
			
		
	
END
