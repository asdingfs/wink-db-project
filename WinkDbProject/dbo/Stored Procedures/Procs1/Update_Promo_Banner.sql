
CREATE PROCEDURE [dbo].[Update_Promo_Banner]
(
	@id int,
	@default_banner_image varchar(250),
	@default_banner_url varchar(250),
	@banner_name varchar(250),
	@banner_image varchar(250),
	@banner_url varchar(250),
	@banner_from_date varchar(10),
	@banner_to_date varchar(10),
	@banner_image_status varchar(10),
	@promo_banner_type varchar(20)
)
AS
BEGIN

DECLARE @current_date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

IF(@banner_from_date = '')
BEGIN
	SET @banner_from_date = NULL;
END
IF(@banner_to_date = '')
BEGIN
	SET @banner_to_date = NULL;
END

IF(@promo_banner_type = 'default')
BEGIN
	IF(@default_banner_image = '')
	BEGIN
		-- no default banner
		SELECT '0' as response_code , 'Invalid Entry' as response_message
		return
	END
	ELSE
	BEGIN
		Update promo_banner_ads_app
		set banner_name = 'Default Promo Banner',
		banner_image = @default_banner_image,
		banner_url = @default_banner_url,
		updated_at = @current_date
		where id = @id
		
		IF(@@ROWCOUNT>0)
		BEGIN
			SELECT '1' as response_code , 'Successfully updated' as response_message
			return
		END
		ELSE
		BEGIN 
			SELECT '0' as response_code , 'Failed to update' as response_message
			return
		END
	END
END
ELSE
BEGIN
	IF(@banner_image = '')
	BEGIN
		-- no promo banner
		SELECT '0' as response_code , 'Invalid Entry' as response_message
		return
	END
	ELSE IF(@banner_from_date IS NULL OR @banner_to_date IS NULL)
	BEGIN
		-- date can't be empty 
		SELECT '0' as response_code , 'Invalid Entry' as response_message
		return
	END
	ELSE IF(cast(@banner_from_date as date) > cast(@banner_to_date as date))
		BEGIN
			-- from date should be earlier than end date
			SELECT '0' as response_code , 'Invalid Entry' as response_message
			return
		END
	ELSE
	BEGIN

		IF(@banner_image_status = 1)
		BEGIN
			DECLARE @prev_banner_image_status varchar(10);
        	DECLARE @prev_banner_from_date datetime;
        	DECLARE @prev_banner_to_date datetime;

       		SELECT @prev_banner_image_status = banner_image_status, 
         	@prev_banner_from_date = banner_from_date, 
         	@prev_banner_to_date = banner_to_date 
         	FROM promo_banner_ads_app WHERE id = @id;
			
			IF(@prev_banner_image_status != @banner_image_status
			OR cast(@prev_banner_from_date as date) != cast(@banner_from_date as date) 
			OR cast(@prev_banner_to_date as date) != cast(@banner_to_date as date)  
			)
			BEGIN
				DECLARE @maxOverLapCount int;
				SELECT @maxOverLapCount = count(*) FROM [winkwink].[dbo].[promo_banner_ads_app]  
				WHERE banner_from_date <= @banner_to_date 
				AND banner_to_date >= @banner_from_date
				AND banner_image_status = 1
				AND promo_banner_type = 'promo_banner'
				-- exclude the current record from checking
				AND id != @id

				if(@maxOverLapCount >= 3)
				BEGIN
					 SELECT '0' as response_code , 'Promo Banner max limit reached' as response_message
					 return
				END
			END
		END

		Update promo_banner_ads_app
		set banner_name = @banner_name,
		banner_image = @banner_image,
		banner_url = @banner_url,
		banner_from_date = @banner_from_date,
		banner_to_date = @banner_to_date,
		banner_image_status = @banner_image_status,
		updated_at = @current_date
		where id = @id

		IF(@@ROWCOUNT>0)
		BEGIN
			SELECT '1' as response_code , 'Successfully updated' as response_message
			return
		END
		ELSE
		BEGIN 
			SELECT '0' as response_code , 'Failed to update' as response_message
			return
		END
	END
END

END
