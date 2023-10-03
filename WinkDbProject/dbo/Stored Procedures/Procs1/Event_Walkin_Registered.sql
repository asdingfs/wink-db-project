CREATE procedure [dbo].[Event_Walkin_Registered]
(
  @name varchar(150),
  @email varchar(150),
  @company_name varchar(150)
 )

AS
BEGIN
Declare @total_username int
Declare @year varchar(10) 
Declare @current_date datetime 

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output
Set @year ='2017'
-- Check Only Name
IF (@email is not null and @email !='')
BEGIN
IF Exists (select 1 from  media_party where @email = email and party_year =@year and check_in_status=1)
BEGIN
select 0 as success , 'Email is already checked in' as response_message
Return
END

IF EXISTS (select 1 from media_party where @email = email and party_year =@year)
BEGIN
	select 0 as success , 'Email is already registered. Please check in' as response_message
Return
END

IF NOT Exists (select 1 from media_party where @email = email and party_year =@year)
 Begin
   insert into media_party (email,name,company_name,party_year,check_in_status,created_at,group_name)
    values (@email,@name,@company_name,@year,1,@current_date,'Walk-in')
    IF (@@ROWCOUNT>0)
    BEGIN
    select 1 as success , 'Successfully registered and checked in' as response_message
    END
    Else 
    BEGIN
        select 0 as success , 'Fail to register and check in' as response_message

    
    END
 END
 ELSE
 BEGIN
	select 0 as success , 'Email is already registered. Please check in' as response_message

 END
END

ELSE
BEGIN

	select 0 as success , 'Invalid data' as response_message

END
END