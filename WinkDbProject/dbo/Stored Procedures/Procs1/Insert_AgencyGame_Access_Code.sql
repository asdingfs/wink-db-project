
CREATE PROC [dbo].[Insert_AgencyGame_Access_Code]

AS

BEGIN
Declare @access_code varchar(80)

DECLARE @MyCursor CURSOR;
DECLARE @agency_id int;
BEGIN
    SET @MyCursor = CURSOR FOR
    select id from dbo.agency_game
      
    OPEN @MyCursor 
    FETCH NEXT FROM @MyCursor 
    INTO @agency_id

    WHILE @@FETCH_STATUS = 0
    BEGIN
      /*
         YOUR ALGORITHM GOES HERE   
      */
	  print (@agency_id)
	  set @access_code = (SELECT SUBSTRING(CONVERT(VARCHAR(255), NEWID()),0,6))
      WHILE EXISTS(select 1 from agency_game where agency_code = @access_code)
	  BEGIN
	  print ('get access')
	  set @access_code = (SELECT SUBSTRING(CONVERT(VARCHAR(255), NEWID()),0,6))

	  print (@access_code)
	  END
	  
       IF EXISTS (select 1 from agency_game where id = @agency_id and 
	   (agency_code is null or agency_code =''))

	   BEGIN
	   print ('update')
	   update agency_game set agency_code = @access_code where id = @agency_id
	   END

      FETCH NEXT FROM @MyCursor 
      INTO @agency_id 
    END; 

    CLOSE @MyCursor ;
    DEALLOCATE @MyCursor;
END;


END
