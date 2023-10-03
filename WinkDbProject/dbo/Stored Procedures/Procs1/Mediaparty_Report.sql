CREATE procedure [dbo].[Mediaparty_Report]
(
  @name varchar(150),
  @email varchar(150),
  @company_name varchar(150),
  @year varchar(10),
  @check_in_status varchar (10)
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
  select * from media_party where 
  (@email IS NULL OR email like '%' + @email + '%')
   AND  (@name IS NULL OR name like '%' + @name + '%')
    AND  (@company_name IS NULL OR company_name like '%' + @company_name + '%')
     AND  (@check_in_status IS NULL OR check_in_status like '%' + @check_in_status + '%')
     order by media_party.id desc
 
END

