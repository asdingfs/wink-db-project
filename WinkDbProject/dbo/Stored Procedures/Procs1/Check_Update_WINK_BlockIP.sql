
CREATE Procedure [dbo].[Check_Update_WINK_BlockIP] 
(
@ip_address varchar(50)
)
As
Begin
    
Declare @current_datetime datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

select * from wink_customer_block_ip where ip_address = @ip_address

if(@@ROWCOUNT <= 0)
BEGIN


INSERT INTO wink_customer_block_ip
           ([ip_address]
           ,[created_at]
           ,[updated_at])
     VALUES
           (@ip_address
           ,@current_datetime
           ,@current_datetime)




declare @IDList table (ID int)

insert into @IDList
SELECT mousetrap_id
FROM [winkwink].[dbo].[mousetrap]
WHERE ip_traped = @ip_address

declare @i int
select @i = min(ID) from @IDList
while @i is not null
begin

  update [winkwink].[dbo].[mousetrap]
  set status = 'locked' 
  where mousetrap_id = @i

  select @i = min(ID) from @IDList where ID > @i


end


END



End
