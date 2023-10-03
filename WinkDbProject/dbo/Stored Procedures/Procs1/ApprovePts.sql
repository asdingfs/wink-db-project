
CREATE Procedure [dbo].[ApprovePts] 
(
	@wid varchar(50),
	@index int,
	@campaignId int,
	@adminEmail varchar(100)
)
As
Begin
   IF(@adminEmail is null)
	BEGIN
		SELECT '0' as response_code;
		RETURN
	END

	IF(@wid is null or @wid = '')
	BEGIN
		SELECT '0' as response_code
		return
	END

	IF(@campaignId = 0)
	BEGIN
		SELECT '0' as response_code
		return
	END

	DECLARE @remark varchar(150);
	DECLARE @points int;
	DECLARE @campaignName varchar(250);

	SELECT @points = points, @campaignName = campaign_name
	FROM points_issuance_campaign
	where id = @campaignId;
	print('points');
	print(@points);
	IF EXISTS(SELECT 1 FROM customer WHERE WID like @wid)
	BEGIN
		IF EXISTS(SELECT 1 FROM customer WHERE WID like @wid AND [status] like 'disable')
		BEGIN
			SET @remark = 'Account is locked. Points are not issued.';
			SET @points = 0;
		END
	END
	ELSE
	BEGIN
		SET @remark = 'Invalid WID';
		SET @points = 0;
	END
	print(@remark);
	Declare @current_datetime datetime
	Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

	IF(
		(SELECT TOP(1) approver
		FROM points_issuance
		WHERE campaign_id = @campaignId
		AND wid like @wid)
		IS NULL
	)
	BEGIN
		print('here1');
		UPDATE points_issuance
		SET approver = (SELECT first_name + ' ' + last_name FROM admin_user WHERE email like @adminEmail),
		remark_approver = @remark,
		approved_at = @current_datetime
		WHERE campaign_id = @campaignId
		AND wid like @wid

		DECLARE @customerId int;
		SELECT @customerId = customer_id 
		FROM customer
		where WID like @wid;

		IF(@points > 0)
		BEGIN
			print('here2');
			IF EXISTS (SELECT 1 FROM customer_balance WHERE customer_id = @customerId)
			BEGIN
				UPDATE customer_balance
				SET total_points = (SELECT total_points FROM customer_balance WHERE customer_id = @customerId)+@points 
				WHERE customer_id = @customerId;

				IF(@@ROWCOUNT > 0)
				BEGIN
					print('here1 index: '+@index);
					IF(@index > 1)
					BEGIN
						SELECT '1' as response_code
						return
					END
				END
				ELSE
				BEGIN
					UPDATE points_issuance
					SET approver = NULL,
					remark_approver = NULL,
					approved_at = NULL
					WHERE campaign_id = @campaignId
					AND wid like @wid

					SELECT '0' as response_code
					return
				END
			END
			ELSE
			BEGIN
				INSERT INTO customer_balance 
				(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans,total_redeemed_amt)
				VALUES
				(@customerId,@points,0,0,0,0,0,0,0.00);

				IF(@@ROWCOUNT > 0)
				BEGIN
					IF(@index > 1)
					BEGIN
						SELECT '1' as response_code
						return
					END
				END
				ELSE
				BEGIN
					UPDATE points_issuance
					SET approver = NULL,
					remark_approver = NULL,
					approved_at = NULL
					WHERE campaign_id = @campaignId
					AND wid like @wid

					SELECT '0' as response_code
					return
				END
			END
		END
		print('here4');
	END
	ELSE
	BEGIN
		SET @points = 0;
	END
	IF(@index = 1)
	BEGIN

		Declare @result int
		EXEC CreateIssuePtsLog
		@campaignId, @campaignName,
		@adminEmail,'Campaign Points Issuance','Approve', @result output ;
		print (@result)
		if(@result=2)
		BEGIN
			print('here3');
			SELECT '0' as response_code
			return
		END
		ELSE
		BEGIN
			print('here5 points: ');
			IF(@points > 0)
			BEGIN
				SELECT '1' as response_code
				return
			END
			ELSE
			BEGIN
				print('here 0 points');
				SELECT '0' as response_code
				return
			END
		END
	END
	ELSE
	BEGIN
		IF(@points = 0)
		BEGIN
			print('here final');
			SELECT '0' as response_code
			return
		END
	END
End

