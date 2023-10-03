CREATE PROC [dbo].[GET_RANDOM_NO]
@CharacterData varchar(10)OUT
AS

BEGIN
	declare @BinaryData varbinary(max)
    ,@Length int = 10

	set @BinaryData=crypt_gen_random (@Length) 

	set @CharacterData=cast('' as xml).value('xs:base64Binary(sql:variable("@BinaryData"))', 'varchar(max)')

	print @CharacterData
END
