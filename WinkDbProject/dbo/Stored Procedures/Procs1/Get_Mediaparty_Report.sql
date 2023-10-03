CREATE procedure [dbo].[Get_Mediaparty_Report]
(
  @name varchar(150),
  @email varchar(150),
  @company_name varchar(150),
  @year varchar(10),
  @check_in_status varchar (10),
  @group varchar(50),
  @rsvp_status varchar(10)
  )

AS
BEGIN

IF (@check_in_status is null or @check_in_status = '')
 BEGIN
 SET @check_in_status = NULL;
 END
 

IF (@email is null or @email = '')
 BEGIN
 SET @email = NULL;
 END
 
IF (@name is null or @name = '')
 BEGIN
 SET @name = NULL;
 END
 
 IF (@company_name is null or @company_name = '')
 BEGIN
 SET @company_name = NULL;
 END
 
 IF (@rsvp_status is null or @rsvp_status = '')
 BEGIN
 SET @rsvp_status = NULL;
 END
 
 IF (@group is null or @group = '')
 BEGIN
 SET @group = NULL;
 END
  select * from media_party where 
  (@email IS NULL OR email like '%' + @email + '%')
   AND  (@name IS NULL OR name like '%' + @name + '%')
    AND  (@company_name IS NULL OR company_name like '%' + @company_name + '%')
     AND  (@check_in_status IS NULL OR check_in_status like '%' + @check_in_status + '%')
     and (@group IS NULL OR group_name =@group)
     and (@rsvp_status IS NULL OR media_party.rsvp_status = @rsvp_status)
     
     order by media_party.id desc
 
END

