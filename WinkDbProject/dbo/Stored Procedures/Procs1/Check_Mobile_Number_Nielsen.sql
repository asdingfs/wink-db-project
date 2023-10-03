CREATE PROC [dbo].[Check_Mobile_Number_Nielsen]
@mobile_number varchar(50) 

AS

SELECT '1' AS response_code, 'Successs' AS response_message

/*
BEGIN

	DECLARE @customer_id int;

	IF EXISTS (SELECT * FROM wink_tag_approved_phone_list WHERE phone_no = @mobile_number)
	BEGIN
		SELECT '1' AS response_code, 'Successs' AS response_message
		RETURN;
	END

	ELSE
	BEGIN
		IF EXISTS (SELECT * FROM CUSTOMER WHERE phone_no = @mobile_number)
		BEGIN
			SET @customer_id = (SELECT customer_id FROM customer WHERE phone_no = @mobile_number)

			IF EXISTS(SELECT * FROM customer_earned_points WHERE qr_code = 'nielsen_001_33881' AND customer_id = @customer_id)
			BEGIN
				INSERT INTO wink_tag_approved_phone_list
				(phone_no,event_name,event_id,created)
				VALUES
				(@mobile_number,'Nielsen',1,DATEADD(HOUR,8,GETDATE()))

				IF @@ROWCOUNT > 0
				BEGIN
					SELECT '1' AS response_code, 'Success' AS response_message
					RETURN;
				END
				ELSE
				BEGIN
					SELECT '0' AS response_code, 'Error' AS response_message
					RETURN;
				END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, 'Oops! You are not in the invite list' AS response_message
				RETURN;
			END
		END

		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Oops! You are not in the invite list' AS response_message
			RETURN;
		END
	END

END
*/