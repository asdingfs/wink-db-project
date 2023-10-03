CREATE procedure [dbo].[Event_User_Authentication]
(
  @name varchar(150),
  @email varchar(150)
  )

AS
BEGIN
Declare @total_username int
Declare @year varchar(10) 

Set @year ='2017'
-- Check Only Name 

IF(@email is null OR @email ='')
set @email =''
 IF (@name is not null and @name !='' and ( @email = '' Or @email is null))
 Begin
  IF EXISTS (Select 1 from media_party where name like '%'+@name+'%')
  BEGIN
  set @total_username =(select COUNT(*) from media_party where name like '%'+@name+'%' 
  --and check_in_status =0 
  and party_year =@year)
   IF ( @total_username >1)
      Begin 
      select '0' as success , 'Duplicate name. Please key in email' as response_message, 1 as duplicate_name
      Return
      END
   ELSE If (@total_username =1)
       BEGIN
         IF EXISTS (Select 1 from media_party where name like '%'+@name+'%' and check_in_status='1' )
		   BEGIN
			select '0' as success , 'Already checked in under this name.' as response_message, 0 as duplicate_name
				Return
		   
		   END
       select id ,name ,email, company_name, '1' as success , 'valid' as response_message from media_party where name like '%'+@name+'%' and check_in_status =0 and party_year =@year
       Return
       END
   Else 
   BEGIN
         select '0' as success , 'Name is not registered. Please select Walk-in registration. ' as response_message,0 as duplicate_name
            Return
   
   END
   
   
  
  END
  
  ELse 
  
  BEGIN
  
        select '0' as success , 'Name is not registered. Please select Walk-in registration.' as response_message , 0 as duplicate_name
        Return
  END
 END
 ELSE
 BEGIN
 IF EXISTS (Select 1 from media_party where name like '%'+@name+'%' and email = @email)
  BEGIN
   print('djfkdfjksdf')
   IF EXISTS (Select 1 from media_party where name like '%'+@name+'%' and email = @email and check_in_status='1' )
   BEGIN
    select '0' as success , 'Already checked in under this email.' as response_message,0 as duplicate_name
        Return
   
   END
   select id ,name ,email, company_name, '1' as success , 'valid' as response_message from media_party  where name like '%'+@name+'%' and email = @email and check_in_status =0 and party_year =@year
   Return
   
  
  END
  
  ELse 
  
  BEGIN
  
        select '0' as success , 'Email is not registered. Please select Walk-in registration. ' as response_message,0 as duplicate_name
        Return
  END
 END

END