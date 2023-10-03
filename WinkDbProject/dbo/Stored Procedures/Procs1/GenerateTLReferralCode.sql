CREATE PROC [dbo].[GenerateTLReferralCode]
@childLen int,
@childCount int,
@campaignId int,
@parentCampaignId int
AS

BEGIN
	DECLARE @parentCode varchar(8), @parentId int
	
	DECLARE ParentCodeCursor CURSOR FOR 
	select code, id
	from wink_thirdparty_codes
	where campaignId = @parentCampaignId
	--and id>102097 and id < 102102;--comment it away. it is only for add-ons

	OPEN ParentCodeCursor 

	FETCH NEXT FROM ParentCodeCursor INTO @parentCode, @parentId
	print(@@FETCH_STATUS);
	WHILE @@FETCH_STATUS = 0
	BEGIN
		print('parent code');
		print(@parentCode);

		DECLARE @uniqueCode varchar(5)

		DECLARE @counter INT = 1;
		WHILE @counter <= @childCount
		BEGIN
			SET @uniqueCode= substring(replace(newID(),'-',''),cast(RAND()*(31-@childLen) as int),@childLen);

			WHILE( (LEN(@uniqueCode)<@childLen)  
					OR   
					((SELECT referralCode FROM wink_thirdparty_referral_codes WHERE campaignId = @campaignId AND referralCode like ('%_'+@uniqueCode)) is not null)
					OR
					((@uniqueCode NOT LIKE '%[0-9][A-Z]%') AND (@uniqueCode NOT LIKE '%[A-Z][0-9]%'))
			)
			BEGIN
				SET @uniqueCode=substring(replace(newID(),'-',''),cast(RAND()*(31-@childLen) as int),@childLen);
			END
	
			SET @uniqueCode = LTRIM(RTRIM(@uniqueCode));
			print('child code');
			print(@uniqueCode);

			DECLARE @CURRENT_DATETIME Datetime ;     
			EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

			INSERT INTO [dbo].[wink_thirdparty_referral_codes]
			   ([campaignId]
			   ,[parentId]
			   ,[referralCode]
			   ,[usedStatus]
			   ,[updatedAt]
			   ,[createdAt])
			 VALUES
				(@campaignId
				,@parentId
				,LTRIM(RTRIM(@parentCode)) + '_'+@uniqueCode
				,0
				,@CURRENT_DATETIME
				,@CURRENT_DATETIME)
			SET @counter = @counter + 1;
		END

		FETCH NEXT FROM ParentCodeCursor INTO
		@parentCode, @parentId
	END
	CLOSE ParentCodeCursor
	DEALLOCATE ParentCodeCursor
END
