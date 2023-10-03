CREATE PROCEDURE  [dbo].[IssuePoints] 
(
	@wid varchar(50),
	@campaignId int,
	@admin_email varchar(100),
	@index int
)
AS
BEGIN 

	IF(@admin_email is null or @admin_email = '')
	BEGIN
		SELECT 0 as success,'You are not authorised to create the campaign' as response_message
		return
	END

	IF(@wid is null or @wid = '')
	BEGIN
		SELECT 0 as success,'Please enter a WID' as response_message
		return
	END

	IF(@campaignId = 0)
	BEGIN
		SELECT 0 as success,'Invalid campaign. Please try again later.' as response_message
		return
	END

	DECLARE @remark varchar(150);
	DECLARE @points int;
	DECLARE @campaignName varchar(250);

	SELECT @points = points, @campaignName = campaign_name
	FROM points_issuance_campaign
	WHERE id = @campaignId;

	IF EXISTS(SELECT 1 FROM customer WHERE WID like @wid)
	BEGIN
		IF EXISTS(SELECT 1 FROM customer WHERE WID like @wid AND [status] like 'disable')
		BEGIN
			SET @remark = 'Account is locked';
			SET @points = 0;
		END
	END
	ELSE
	BEGIN
		SET @remark = 'Invalid WID';
		SET @points = 0;
	END
	
	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT
	
	DECLARE @maxID int
	DECLARE @recordId int;
	INSERT INTO [dbo].[points_issuance]
           ([wid]
		   ,[campaign_id]
           ,[points]
           ,[issuer]
           ,[remark_issuer]
           ,[created_at])
     VALUES
           (@wid
		   ,@campaignId
           ,@points
           ,(SELECT first_name+' '+last_name FROM admin_user WHERE email like @admin_email)
           ,@remark
           ,@CURRENT_DATETIME);
	
	SET @maxID = (SELECT @@IDENTITY);

	IF (@maxID > 0)
	BEGIN
		SET @recordId  =  (SELECT SCOPE_IDENTITY());

		--DECLARE @customerId int;
		--SELECT @customerId = customer_id 
		--FROM customer
		--where WID like @wid;

		--IF(@points > 0)
		--BEGIN
		--	IF EXISTS (SELECT 1 FROM customer_balance WHERE customer_id = @customerId)
		--	BEGIN
		--		UPDATE customer_balance
		--		SET total_points = (SELECT total_points FROM customer_balance WHERE customer_id = @customerId)+@points 
		--		WHERE customer_id = @customerId;

		--		IF(@@ROWCOUNT > 0)
		--		BEGIN
		--			IF(@index > 0)
		--			BEGIN
		--				SELECT 1 as success,'Campaign points have been issued to the selected user(s)' as response_message;
		--				return
		--			END
		--		END
		--		ELSE
		--		BEGIN
		--			DELETE FROM points_issuance
		--			WHERE id = @recordId;

		--			SELECT 0 as success,'Failed to update user''s balance. Please try again later.' as response_message
		--			return
		--		END
		--	END
		--	ELSE
		--	BEGIN
		--		INSERT INTO customer_balance 
		--		(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans,total_redeemed_amt)
		--		VALUES
		--		(@customerId,@points,0,0,0,0,0,0,0.00);

		--		IF(@@ROWCOUNT > 0)
		--		BEGIN
		--			IF(@index > 0)
		--			BEGIN
		--				SELECT 1 as success,'Campaign points have been issued to the selected user(s)' as response_message;
		--				return
		--			END
		--		END
		--		ELSE
		--		BEGIN
		--			DELETE FROM points_issuance
		--			WHERE id = @recordId;

		--			SELECT 0 as success,'Failed to update user''s balance. Please try again later.' as response_message
		--			return
		--		END
		--	END
		--END

		IF(@index = 0)
		BEGIN
			Declare @result int
			EXEC CreateIssuePtsLog
			@campaignId, @campaignName,
			@admin_email,'Campaign Points Issuance','Add Users', @result output ;
			--print (@result)
			if(@result=2)
			BEGIN
				DELETE FROM points_issuance
				WHERE id = @recordId;

				--IF(@points > 0)
				--BEGIN
				--	UPDATE customer_balance
				--	SET total_points = (SELECT total_points FROM customer_balance WHERE customer_id = @customerId)-@points 
				--	WHERE customer_id = @customerId;
				--END
				

				SELECT 0 as success,'Please try again later' as response_message
				return
			END
			ELSE
			BEGIN
				IF(@points > 0)
				BEGIN
					SELECT 1 as success,'Campaign points have been recorded for the selected user(s)' as response_message;
					return
				END
				ELSE
				BEGIN
					SELECT 0 as success,@remark as response_message
					return
				END
			END
		END
		ELSE
		BEGIN
			IF(@points = 0)
			BEGIN
				SELECT 0 as success,@remark as response_message
				return
			END
		END
	END
	ELSE
	BEGIN
		SELECT 0 as success,'Please try again later.' as response_message
		return
	END
	
END

