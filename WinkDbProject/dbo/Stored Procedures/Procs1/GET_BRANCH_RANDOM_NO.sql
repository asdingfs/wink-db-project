CREATE PROC [dbo].[GET_BRANCH_RANDOM_NO]
--@INCREMENT_Value numeric(4,0) OUT
@INCREMENT_Value int out
AS

BEGIN
	/*SET @INCREMENT_Value= CONVERT(numeric(4,0),rand() * 9999)
	print @INCREMENT_Value*/
	
	SET @INCREMENT_Value= ABS(Checksum(NewID()) % 98999) + 1000
	print @INCREMENT_Value
END
