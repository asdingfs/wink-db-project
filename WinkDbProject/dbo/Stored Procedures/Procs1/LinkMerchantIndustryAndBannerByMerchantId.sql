-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LinkMerchantIndustryAndBannerByMerchantId]
	(@merchant_id int,
	 @small_banner varchar(1000),
	 @large_banner varchar(1000),
	 @large_url varchar(255),
	 @small_url varchar(255),
	 @status bit,
	 @industry_id int,
	 @created_at DateTime,
	 @updated_at DateTime,
	 @wink_fee int	)
	
AS
BEGIN
	IF EXISTS (SELECT * FROM merchant where merchant_id = @merchant_id)
	BEGIN
		UPDATE merchant 
		set wink_fee_percent = @wink_fee
		where merchant_id = @merchant_id;
		IF(@@ROWCOUNT>0)
		BEGIN 
			IF (@small_banner is null and @small_banner ='')
			BEGIN
				IF EXISTS(SELECT * FROM merchant_industry WHERE merchant_industry.merchant_id = @merchant_id)
				BEGIN
					Update merchant_industry SET industry_id = @industry_id
					Where merchant_id = @merchant_id;
				END	
				ELSE
				BEGIN
					INSERT INTO merchant_industry (merchant_id,industry_id)
					VALUES (@merchant_id,@industry_id);
				END
				IF(@@ROWCOUNT>0)
				BEGIN 
					SELECT '1' as response_code, 'Success' as response_message; 
					RETURN
				END
				ELSE
				BEGIN
					SELECT '0' as response_code, 'Error in industry' as response_message 
					RETURN
				END
		
			END
			ELSE 
			BEGIN
				IF EXISTS (SELECT campaign_ads_banner.banner_id FROM campaign_ads_banner WHERE campaign_ads_banner.merchant_id =@merchant_id)
				BEGIN 
					UPDATE campaign_ads_banner 
					SET large_banner =@large_banner,
					small_banner =@small_banner,
					large_url=@large_url,
					small_url=@small_url,
					status =@status,
					updated_at=@updated_at
					WHERE merchant_id= @merchant_id;
		
				END
				ELSE 
				BEGIN 
					INSERT INTO campaign_ads_banner (small_banner,large_banner,large_url,small_url,status,created_at,updated_at,merchant_id)
					VALUES (@small_banner,@large_banner,@large_url,@small_url,@status,@created_at,@updated_at,@merchant_id);
				END
				IF (@@ROWCOUNT>0)
				BEGIN
					IF EXISTS(SELECT * FROM merchant_industry WHERE merchant_industry.merchant_id = @merchant_id)
					BEGIN
						Update merchant_industry SET industry_id = @industry_id
						Where merchant_id = @merchant_id;
					END
					ELSE
					BEGIN
						INSERT INTO merchant_industry (merchant_id,industry_id)
						VALUES (@merchant_id,@industry_id);
					END
					IF(@@ROWCOUNT>0)
					BEGIN 
						SELECT '1' as response_code, 'Success' as response_message;
						RETURN
					END
					ELSE
					BEGIN
						SELECT '0' as response_code, 'Error in industry' as response_message;
						RETURN
					END
				END
				ELSE
				BEGIN
					SELECT '0' as response_code, 'Error in banner' as response_message;
					RETURN
				END
	
			END
		END
		ELSE
		BEGIN
			SELECT '0' as response_code, 'Failed to update the WINK+ Fee (%). Please try again later.' as response_message 
			RETURN
		END
	END
	ELSE
	BEGIN
		SELECT '0' as response_code, 'This merchant does not exist.' as response_message 
		RETURN
	END
	
END
