CREATE PROC [dbo].[GetAlphanumericCode]
@length int,
@uniqueCode varchar(8)OUT
AS

BEGIN

	SET @uniqueCode=substring(replace(newID(),'-',''),cast(RAND()*(31-@length) as int),@length);

	WHILE( (LEN(@uniqueCode)<@length)  
			OR   
			((SELECT code FROM wink_thirdparty_codes WHERE code = @uniqueCode) is not null)
			OR
			((@uniqueCode NOT LIKE '%[0-9][A-Z]%') AND (@uniqueCode NOT LIKE '%[A-Z][0-9]%'))
	)
	BEGIN
		SET @uniqueCode=substring(replace(newID(),'-',''),cast(RAND()*(31-@length) as int),@length);
	END
	
	SET @uniqueCode = LTRIM(RTRIM(@uniqueCode));

	print @uniqueCode;
END
