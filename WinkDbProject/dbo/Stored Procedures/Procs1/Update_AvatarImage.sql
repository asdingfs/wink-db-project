CREATE PROCEDURE  [dbo].[Update_AvatarImage] 
(
@id int,
 @avatarimage varchar(255),
 @status varchar(10),
 @avatar_name varchar(150)
)
AS
BEGIN 
DECLARE @current_date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
if(@avatarimage = '')
BEGIN
update avatar set   status =@status,updated_at =@current_date,
avatar_name= @avatar_name
where avatar.id = @id

END
else
BEGIN
	
If EXISTS (select 1 from avatar where avatar.avatarimage =@avatarimage and avatar.id != @id)
BEGIN
select '0' as response_code , 'Image Name already exists' as response_message
Return
END
update avatar set avatarimage =@avatarimage , status =@status,updated_at =@current_date,
avatar_name= @avatar_name
where avatar.id = @id

END

If(@@ROWCOUNT>0)
select '1' as response_code , 'Successfully updated' as response_message
Else 
select '0' as response_code , 'Fail to update' as response_message

 
END
