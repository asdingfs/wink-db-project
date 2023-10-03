CREATE PROC [dbo].[SEND_REFERRAL_EMAIL]
(
	@sender_email AS VARCHAR(50),
	@referral_email1 AS VARCHAR(50),
	@referral_email2 AS VARCHAR(50),
	@referral_email3 AS VARCHAR(50)
)

AS
BEGIN

	DECLARE @ERR AS VARCHAR(255)
	DECLARE @ERR_REFERRAL AS VARCHAR(255)
	DECLARE @id INT
	--DECLARE @CURRENT_DATETIME datetimeoffset = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');
	DECLARE @CURRENT_DATETIME datetime
	Declare @event_name varchar(50)
	
    Exec GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME output
	
	Set @event_name = 'Beauty and the Beast'
	
	IF EXISTS(SELECT * FROM CUSTOMER WHERE EMAIL = @sender_email)
	BEGIN
		IF EXISTS (SELECT * FROM CUSTOMER WHERE EMAIL = @referral_email1)
		BEGIN
			SET @ERR = CONCAT(@ERR,'   ',@referral_email1); 
		END	

		IF EXISTS (SELECT * FROM CUSTOMER WHERE EMAIL = @referral_email2)
		BEGIN
			SET @ERR = CONCAT(@ERR,'   ',@referral_email2); 
		END

		IF EXISTS (SELECT * FROM CUSTOMER WHERE EMAIL = @referral_email3)
		BEGIN
			SET @ERR = CONCAT(@ERR,'   ',@referral_email3); 
		END

		IF @ERR IS NULL OR @ERR = ''
		BEGIN
			IF EXISTS(SELECT * FROM referral_receiver WHERE referral_email = @referral_email1 and event_name = @event_name)
			BEGIN
				SET @ERR_REFERRAL = CONCAT(@ERR_REFERRAL,'   ',@referral_email1);
			END

			IF EXISTS(SELECT * FROM referral_receiver WHERE referral_email = @referral_email2 and event_name = @event_name)
			BEGIN
				SET @ERR_REFERRAL = CONCAT(@ERR_REFERRAL,'   ',@referral_email2);
			END

			IF EXISTS(SELECT * FROM referral_receiver WHERE referral_email = @referral_email3 and event_name = @event_name)
			BEGIN
				SET @ERR_REFERRAL = CONCAT(@ERR_REFERRAL,'   ',@referral_email3);
			END

			IF @ERR_REFERRAL IS NULL OR @ERR_REFERRAL = ''
			BEGIN
				INSERT INTO referral_sender (customer_id, email, created_at,updated_at,event_name) 
				VALUES ((SELECT customer_id FROM customer WHERE email = @sender_email),@sender_email,@CURRENT_DATETIME,@CURRENT_DATETIME,@event_name)

				IF @@ROWCOUNT > 0
				BEGIN
					SET @id = SCOPE_IDENTITY()

					INSERT INTO referral_receiver (referral_email,sender_id,customer_id,created_at,updated_at,event_name) 
					VALUES (@referral_email1,@id,(SELECT customer_id FROM customer WHERE email = @sender_email),@CURRENT_DATETIME,@CURRENT_DATETIME,@event_name)

					INSERT INTO referral_receiver (referral_email,sender_id,customer_id,created_at,updated_at,event_name) 
					VALUES (@referral_email2,@id,(SELECT customer_id FROM customer WHERE email = @sender_email),@CURRENT_DATETIME,@CURRENT_DATETIME,@event_name)

					INSERT INTO referral_receiver (referral_email,sender_id,customer_id,created_at,updated_at,event_name) 
					VALUES (@referral_email3,@id,(SELECT customer_id FROM customer WHERE email = @sender_email),@CURRENT_DATETIME,@CURRENT_DATETIME,@event_name)

					IF @@ROWCOUNT > 0
					BEGIN
						SELECT '1' AS response_code, 'Success' AS response_message
						return;
					END
					ELSE
					BEGIN
						SELECT '0' AS response_code, 'Fail to register' AS response_message
						return;
					END
				END
				ELSE
				BEGIN
					SELECT '0' AS response_code, 'Fail to register' AS response_message
					return;
				END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code, @ERR_REFERRAL + ' already registered as referral' AS response_message
				return;
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, @ERR + ' already existed as WINK+ customer' AS response_message
			return;
		END
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Sender email is not registered in WINK+' AS response_message
		return;
	END
END

