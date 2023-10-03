
CREATE PROCEDURE [dbo].[Create_Promo_Banner]
	@default_banner_image varchar(250),
	@default_banner_url varchar(250),
	@banner_name varchar(250),
	@banner_image varchar(250),
	@banner_url varchar(250),
	@banner_from_date varchar(10),
	@banner_to_date varchar(10),
	@banner_image_status varchar(10)
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

	IF(@default_banner_image = '' AND @banner_image = '')
	BEGIN
		-- no default banner and promo banner
		SELECT '0' as response_code , 'Invalid Entry' as response_message
		return
	END
	ELSE
	BEGIN
		IF(@default_banner_image != '')
		BEGIN

		IF EXISTS(SELECT 1 FROM promo_banner_ads_app WHERE promo_banner_type = 'default')
		BEGIN
			-- update default promo banner
			UPDATE promo_banner_ads_app
			SET banner_image = @default_banner_image, 
			banner_url = @default_banner_url,
			updated_at = @current_date
			WHERE promo_banner_type = 'default';  
		END
		ELSE
		BEGIN
			-- insert default banner
			Insert into promo_banner_ads_app 
			(
				banner_name, 
				banner_image, 
				banner_url,
				banner_image_status,
				promo_banner_type,
				created_at,
				updated_at
			)
			values
			(
				'Default Promo Banner' ,
				@default_banner_image, 
				@default_banner_url,
				'1',
				'default',
				@current_date,
				@current_date
			)
			IF(@@ROWCOUNT<=0)
			BEGIN
				SELECT '0' as response_code , 'Failed to create a default promo banner' as response_message
			END
		END
		END

		IF(@banner_image != '')
		BEGIN
			-- update promo banner
			IF(@banner_from_date IS NULL OR @banner_to_date IS NULL)
			BEGIN
				SELECT '0' as response_code , 'Invalid Entry' as response_message
				return
			END

			IF(cast(@banner_from_date as date) > cast(@banner_to_date as date))
			BEGIN
				-- from date should be earlier than end date
				SELECT '0' as response_code , 'Invalid Entry' as response_message
				return
			END

			/*
			IF(cast(@current_date as date) >= cast(@banner_from_date as date))
			AND (cast(@current_date as date) <= cast(@banner_to_date as date))
			AND @banner_image_status = 1
			BEGIN
				DECLARE @promoBannerCount Int
				SELECT @promoBannerCount = COUNT(*) FROM promo_banner_ads_app WHERE promo_banner_type = 'promo_banner'
				and banner_image_status = 1
				and cast(@current_date as date) >= cast(banner_from_date as date) 
				and cast(@current_date as date) <= cast(banner_to_date as date)

				IF(@promoBannerCount >= 3)
				BEGIN
					SELECT '0' as response_code , 'Promo Banner max limit reached' as response_message
					return
				END
			END

			*/

			IF(@banner_image_status = 1)
			BEGIN
				DECLARE @maxOverLapCount int;
				SELECT @maxOverLapCount = count(*) FROM [winkwink].[dbo].[promo_banner_ads_app]  
				WHERE banner_from_date <= @banner_to_date 
				AND banner_to_date >= @banner_from_date
				AND banner_image_status = 1
				AND promo_banner_type = 'promo_banner'

				if(@maxOverLapCount >= 3)
				BEGIN
					 SELECT '0' as response_code , 'Promo Banner max limit reached' as response_message
					 return
				END
			END

			-- insert promo banner
			Insert into promo_banner_ads_app 
			(
				banner_name,
				banner_image,
				banner_url,
				banner_from_date,
				banner_to_date,
				banner_image_status,
				promo_banner_type,
				created_at,
				updated_at
			)
			values
			(
				@banner_name,
				@banner_image,
				@banner_url,
				@banner_from_date,
				@banner_to_date,
				@banner_image_status,
				'promo_banner',
				@current_date,
				@current_date
			)
			IF(@@ROWCOUNT<=0)
			BEGIN
				SELECT '0' as response_code , 'Failed to create a promo banner' as response_message
				return
			END
		END

	SELECT '1' as response_code , 'Successfully created' as response_message
	END

END
