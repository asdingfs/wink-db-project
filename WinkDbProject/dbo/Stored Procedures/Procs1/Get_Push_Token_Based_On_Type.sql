
CREATE PROCEDURE [dbo].[Get_Push_Token_Based_On_Type]
	(
	 @team_id varchar(100),
	 @group_id varchar(100),
	 @gender varchar(100),
	 @device_type varchar(100),
	 @page varchar(100),
	 @campaignId int,
	 @participationStatus int

 )
AS
BEGIN
	DECLARE @CURRENT_DATETIME Datetime;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT

	IF(@device_type is null or @device_type = '')
	BEGIN
		SET @device_type = NULL;
	END

	 IF (@gender is null or @gender = '')
	 BEGIN
		SET @gender = NULL;
	 END

	 IF (@team_id is null or @team_id = '')
	 BEGIN
		SET @team_id = NULL;
	 END

	 IF (@group_id is null or @group_id = '')
	 BEGIN
		SET @group_id = NULL;
	 END


	 IF(@page is null or @page = '')
	 BEGIN
		select device_token from ( 
  
		  select distinct push_device_token.id, push_device_token.customer_id, push_device_token.device_token  ,push_device_token.created_at, customer.gender, customer.team_id, customer.group_id
		  from push_device_token 
		  JOIN customer 
		  ON push_device_token.customer_id = customer.customer_id
		  where (@gender IS NULL OR customer.gender like '%' + @gender + '%') 
		  AND (@device_type IS NULL OR push_device_token.device_type like '%' + @device_type + '%') 
		  AND (@team_id IS NULL OR customer.team_id like '%' + @team_id + '%')
		  AND (@group_id IS NULL OR customer.group_id like '%' + @group_id + '%')
		  and (push_device_token.active_status = '1')

		) AS M
	 END
	 ELSE
	 BEGIN
		IF(@page like 'winkPlay')
		BEGIN
			IF(@campaignId != 0)
			BEGIN
				-- not participated
				IF(@participationStatus = 2)
				BEGIN
					select distinct push.device_token AS M 
					from push_device_token as push
					JOIN customer 
					ON push.customer_id = customer.customer_id
					where active_status = '1'
					AND (@device_type IS NULL OR push.device_type like '%' + @device_type + '%') 
					and NOT EXISTS
					(
						SELECT distinct customer_id 
						from winktag_customer_earned_points as winktag
						where winktag.campaign_id = @campaignId 
						and winktag.customer_id = push.customer_id
					)
				END
				ELSE IF(@participationStatus = 3)
				BEGIN
					-- participated
					select distinct push.device_token AS M 
					from push_device_token as push
					JOIN customer 
					ON push.customer_id = customer.customer_id
					where active_status = '1'
					AND (@device_type IS NULL OR push.device_type like '%' + @device_type + '%') 
					and EXISTS
					(
						SELECT distinct customer_id 
						from winktag_customer_earned_points as winktag
						where winktag.campaign_id = @campaignId 
						and winktag.customer_id = push.customer_id
					)
				END
				ELSE IF(@participationStatus = 1 or @participationStatus ='' or @participationStatus is null)
				BEGIN
					-- all
					select distinct push.device_token AS M 
					from push_device_token as push
					JOIN customer 
					ON push.customer_id = customer.customer_id
					where active_status = '1'
					AND (@device_type IS NULL OR push.device_type like '%' + @device_type + '%')
				END 
			END
			ELSE
			BEGIN
				-- all
				select distinct push.device_token AS M 
				from push_device_token as push
				JOIN customer 
				ON push.customer_id = customer.customer_id
				where active_status = '1'
				AND (@device_type IS NULL OR push.device_type like '%' + @device_type + '%')
			END
		
		END
		ELSE IF(@page like 'eVoucher')
		BEGIN
			select distinct push.device_token AS M 
			from push_device_token as push
			JOIN customer 
			ON push.customer_id = customer.customer_id
			where active_status = '1'
			AND (@device_type IS NULL OR push.device_type like '%' + @device_type + '%') 
			and EXISTS
			(
				SELECT distinct customer_id 
				from customer_earned_evouchers as evoucher
				where evoucher.customer_id = push.customer_id
				and evoucher.used_status = 0
				and evoucher.expired_date >= @CURRENT_DATETIME
				and (DATEDIFF(DAY, @CURRENT_DATETIME, evoucher.expired_date)<=7)	
			)
		END
		ELSE IF(@page like 'winkTreats' or @page like 'news')
		BEGIN
			-- all
			select distinct push.device_token AS M 
			from push_device_token as push
			JOIN customer 
			ON push.customer_id = customer.customer_id
			where active_status = '1'
			AND (@device_type IS NULL OR push.device_type like '%' + @device_type + '%')
		END
	 END
END