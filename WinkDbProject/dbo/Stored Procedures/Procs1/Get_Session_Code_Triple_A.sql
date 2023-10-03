CREATE PROC [dbo].[Get_Session_Code_Triple_A]
@CharacterData varchar(5)OUT
AS

BEGIN
	declare @BinaryData varbinary(max)
    ,@Length int = 5

	set @BinaryData=crypt_gen_random (@Length) 

	set @CharacterData=cast('' as xml).value('xs:base64Binary(sql:variable("@BinaryData"))', 'varchar(max)')

	print @CharacterData
END
