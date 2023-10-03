CREATE PROC [dbo].[GET_WID]
@randomStr varchar(50) OUT

AS

BEGIN

	Declare @alphaNumeric varchar(255) = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
	Declare @str varchar(10)
	Declare  @i int = 0;

	SET @randomStr = SUBSTRING(@alphaNumeric, CONVERT(int, 1 + (LEN(@alphaNumeric) * RAND())), 1)+
	SUBSTRING(@alphaNumeric, CONVERT(int, 1 + (LEN(@alphaNumeric) * RAND())), 1)+
	SUBSTRING(@alphaNumeric, CONVERT(int, 1 + (LEN(@alphaNumeric) * RAND())), 1)+
	SUBSTRING(@alphaNumeric, CONVERT(int, 1 + (LEN(@alphaNumeric) * RAND())), 1)+
	SUBSTRING(@alphaNumeric, CONVERT(int, 1 + (LEN(@alphaNumeric) * RAND())), 1)+
	SUBSTRING(@alphaNumeric, CONVERT(int, 1 + (LEN(@alphaNumeric) * RAND())), 1)

	SET @str = @randomStr
	SELECT @str = REPLACE(@str,NUMBER,'') FROM MASTER.dbo.spt_values WHERE TYPE ='P' AND number between 0 and 9

	WHILE LEN(@str)!=2
	BEGIN
		
		SET @randomStr = SUBSTRING(@alphaNumeric, CONVERT(int, 1 + (LEN(@alphaNumeric) * RAND())), 1)+
		SUBSTRING(@alphaNumeric, CONVERT(int, 1 + (LEN(@alphaNumeric) * RAND())), 1)+
		SUBSTRING(@alphaNumeric, CONVERT(int, 1 + (LEN(@alphaNumeric) * RAND())), 1)+
		SUBSTRING(@alphaNumeric, CONVERT(int, 1 + (LEN(@alphaNumeric) * RAND())), 1)+
		SUBSTRING(@alphaNumeric, CONVERT(int, 1 + (LEN(@alphaNumeric) * RAND())), 1)+
		SUBSTRING(@alphaNumeric, CONVERT(int, 1 + (LEN(@alphaNumeric) * RAND())), 1)

		set @str = @randomStr
		SELECT @str = REPLACE(@str,NUMBER,'') FROM MASTER.dbo.spt_values WHERE TYPE ='P' AND number between 0 and 9
	END

	SELECT @randomStr

END



