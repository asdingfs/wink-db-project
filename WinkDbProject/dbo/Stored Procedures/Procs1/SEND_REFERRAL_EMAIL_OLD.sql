
CREATE PROC SEND_REFERRAL_EMAIL_OLD
(
	@TableVar as datatable_email_referral readonly
)

AS
BEGIN

	DECLARE @ERR AS VARCHAR(255)
	DECLARE @ERR_REFERRAL AS VARCHAR(255)

	DECLARE @sender_email AS VARCHAR(255)
	DECLARE @referral_email AS VARCHAR(255)

	DECLARE curr cursor local for select sender_email,referral_email from @TableVar
			
	OPEN curr
	FETCH NEXT FROM curr INTO @sender_email,@referral_email

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		
		IF EXISTS(SELECT * FROM CUSTOMER WHERE EMAIL = @sender_email)
		BEGIN
			IF EXISTS (SELECT * FROM CUSTOMER WHERE EMAIL = @referral_email)
			BEGIN
				SET @ERR = CONCAT(@ERR,'   ',@referral_email); 
			END	
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Invalid sender email' AS response_message
			close curr
			deallocate curr
			return;
		END

		FETCH NEXT FROM curr INTO @sender_email,@referral_email
	END
	close curr
	deallocate curr

	IF @ERR IS NULL
	BEGIN
		DECLARE curr cursor local for select referral_email from @TableVar
			
		OPEN curr
		FETCH NEXT FROM curr INTO @referral_email

		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			IF EXISTS(SELECT * FROM referral_receiver WHERE referral_email = @referral_email)
			BEGIN
				SET @ERR_REFERRAL = CONCAT(@ERR_REFERRAL,'   ',@referral_email);
			END
				
			FETCH NEXT FROM curr INTO @referral_email
		END
		close curr
		deallocate curr

		IF @ERR_REFERRAL IS NULL OR @ERR_REFERRAL = ''
		BEGIN
			
			DECLARE curr cursor local for select sender_email,referral_email from @TableVar
			DECLARE @id INT
			
			OPEN curr
			FETCH NEXT FROM curr INTO @sender_email,@referral_email

			INSERT INTO referral_sender (customer_id, email, created_at,updated_at) 
			VALUES ((SELECT customer_id FROM customer WHERE email = @sender_email),@sender_email,GETDATE(),GETDATE())

			SET @id = SCOPE_IDENTITY()

			WHILE (@@FETCH_STATUS = 0)
			BEGIN

				INSERT INTO referral_receiver (referral_email,sender_id,customer_id,created_at,updated_at) VALUES (@referral_email,@id,(SELECT customer_id FROM customer WHERE email = @sender_email),GETDATE(),GETDATE())

				FETCH NEXT FROM curr INTO @sender_email,@referral_email
			END
			close curr
			deallocate curr

			SELECT '1' AS response_code, 'Success' AS response_message
			return;

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



