CREATE PROC [dbo].[GET_ALPHANUMERIC_RANDOM_6DIGIT]
@randomStr varchar(50) OUT

AS

BEGIN

	Declare @upperCaseChar varchar(255) = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	Declare @numberChar varchar(255) = '0123456789'


	SET @randomStr = 
	'imobexp'+
	SUBSTRING(@numberChar, CONVERT(int, 1 + (LEN(@numberChar) * RAND())), 1)+
	SUBSTRING(@numberChar, CONVERT(int, 1 + (LEN(@numberChar) * RAND())), 1)+
	SUBSTRING(@numberChar, CONVERT(int, 1 + (LEN(@numberChar) * RAND())), 1)+
	SUBSTRING(@upperCaseChar, CONVERT(int, 1 + (LEN(@upperCaseChar) * RAND())), 1)+
	SUBSTRING(@upperCaseChar, CONVERT(int, 1 + (LEN(@upperCaseChar) * RAND())), 1)+
	SUBSTRING(@upperCaseChar, CONVERT(int, 1 + (LEN(@upperCaseChar) * RAND())), 1)

	select @randomStr

END



