CREATE PROC [dbo].[GenerateTLCode]
@length int,
@quantity int,
@codePrefix varchar(5),
@campaignId int
AS

BEGIN
	-- length without the prefix
	DECLARE @uniqueCode varchar(10)

	DECLARE @counter INT = 1;
	WHILE @counter <= @quantity
	BEGIN
		SET @uniqueCode= substring(replace(newID(),'-',''),cast(RAND()*(31-@length) as int),@length);

		WHILE( (LEN(@uniqueCode)<@length)  
				OR   
				((SELECT code FROM wink_thirdparty_codes WHERE campaignId = @campaignId AND code = (LTRIM(RTRIM(@codePrefix)) + @uniqueCode)) is not null)
				OR
				((@uniqueCode NOT LIKE '%[0-9][A-Z]%') AND (@uniqueCode NOT LIKE '%[A-Z][0-9]%'))
		)
		BEGIN
			SET @uniqueCode=substring(replace(newID(),'-',''),cast(RAND()*(31-@length) as int),@length);
		END
	
		SET @uniqueCode = LTRIM(RTRIM(@uniqueCode));
		print(@uniqueCode);

	

		DECLARE @CURRENT_DATETIME Datetime ;     
		EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

		INSERT INTO [dbo].[wink_thirdparty_codes]
			   ([campaignId]
			   ,[code]
			   ,[usedStatus]
			   ,[updatedAt]
			   ,[createdAt])
		 VALUES
			   (@campaignId
			   ,(LTRIM(RTRIM(@codePrefix)) + @uniqueCode)
			   ,0
			   ,@CURRENT_DATETIME
			   ,@CURRENT_DATETIME);
		SET @counter = @counter + 1;
	END
END
