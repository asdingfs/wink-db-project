CREATE PROCEDURE [dbo].[Training_MFA_Verification] 
(
	@email varchar(100),
	@ip_address varchar(150),
	@session_code int,
	@campaignId int
)
AS
BEGIN
	Declare @current_date datetime
	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	-- Check Block IP
	IF NOT EXISTS (SELECT wink_customer_block_ip.ip_address FROM wink_customer_block_ip
	WHERE wink_customer_block_ip.ip_address = @ip_address)
	BEGIN
		IF(@campaignId IS NULL OR @campaignId = 0)
		BEGIN
			SELECT 0 AS response_code, 'Please try again later.' as response_message;
			RETURN
		END

		DECLARE @sessionId int;
		SELECT TOP(1) @sessionId = id 
		FROM training_mfa_session 
		WHERE [status] = 0 
		AND email like @email
		AND campaign_id = @campaignId
		AND @current_date <= expired_at
		AND session_code = @session_code
		ORDER BY created_at DESC;

		IF(@sessionId is null or @sessionId = 0)
		BEGIN
			SELECT 3 AS response_code , 'Please enter a valid verification code.' AS response_message;
			RETURN
		END
		ELSE
		BEGIN
			UPDATE training_mfa_session
			SET [status] = 1
			WHERE id = @sessionId;
			IF @@ROWCOUNT > 0
			BEGIN
				SELECT 1 AS response_code , 'Success' AS response_message;
				RETURN
			END
		END
	END
END
