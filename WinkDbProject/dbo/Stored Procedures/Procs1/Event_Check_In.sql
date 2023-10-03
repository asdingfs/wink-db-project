CREATE procedure [dbo].[Event_Check_In]
(
  @name varchar(150),
  @email varchar(150),
  @company_name varchar(150)
 )

AS
BEGIN
Declare @total_username int
Declare @year varchar(10) 
Set @year ='2017'
-- Check Only Name 
IF  Exists (select 1 from media_party where @email = email and party_year =@year)
 Begin
  update media_party set check_in_status = 1 where @email = email and party_year =@year
    IF (@@ROWCOUNT>0) 
    BEGIN
    select 1 as success , 'Successfully checked in' as response_message
    END
    Else 
    BEGIN
        select 0 as success , 'Fail to check in' as response_message

    
    END
 END
 ELSE
 BEGIN
	select 0 as success , 'Email address is not under registered list.' as response_message

 END

END