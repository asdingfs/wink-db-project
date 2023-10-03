CREATE PROC [dbo].[CreateWINKThirdpartyCode]
	@campaignId int,
	@length int,
	@quantity int
AS

BEGIN
	DECLARE @uniqueCode varchar(8)
	DECLARE @counter INT = 1;

	WHILE @counter <= @quantity
	BEGIN
		EXEC GetAlphanumericCode @length, @uniqueCode OUTPUT

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
			   ,@uniqueCode
			   ,0
			   ,@CURRENT_DATETIME
			   ,@CURRENT_DATETIME);
		SET @counter = @counter + 1;
	END
END
