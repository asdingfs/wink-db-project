CREATE PROCEDURE  [dbo].[Create_AvatarImage] 
(
 @avatarimage varchar(255),
 @status varchar(10),
 @avatar_name varchar(150)
)
AS
BEGIN 
DECLARE @current_date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
If EXISTS (select 1 from avatar where avatar.avatarimage =@avatarimage)
BEGIN
select '0' as response_code , 'Image Name already exists' as response_message

END
Insert into avatar (avatarimage,status,created_at,updated_at,avatar_name)
values (@avatarimage,@status,@current_date,@current_date,@avatar_name)

If(@@ROWCOUNT>0)
select '1' as response_code , 'Successfully created' as response_message, (select top 1 id from avatar order by id desc) as id
Else 
select '0' as response_code , 'Fail to create new record' as response_message

 
END
