
CREATE proc WINKTAG_SET_EURO_POINTS
@customer_id varchar(10)

AS

BEGIN
	IF EXISTS (SELECT * FROM WINKTAG_CUSTOMER_EARNED_POINTS WHERE campaign_id = 8 and customer_id = @customer_id)
	BEGIN
		INSERT INTO [winktag_customer_earned_points]
           ([campaign_id]
           ,[question_id]
           ,[customer_id]
           ,[points]
           ,[GPS_location]
           ,[ip_address]
           ,[created_at]
		   ,[row_count])
		VALUES
           (8,0,@customer_id,15,'','',(SELECT TODAY FROM VW_CURRENT_SG_TIME),2)

		IF @@ROWCOUNT > 0
		BEGIN
			UPDATE CUSTOMER_BALANCE 
			SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+15 
			WHERE CUSTOMER_ID =@CUSTOMER_ID

			SELECT 'SUCCESS' AS response_message
			RETURN;
		END	
		ELSE
		BEGIN
			SELECT 'FAIL' AS response_message
			RETURN;
		END		
	END
	ELSE
		BEGIN
			SELECT 'FAIL' AS response_message
			RETURN;
		END	
END


