
CREATE PROC [dbo].[Insert_AgencyGame_LuckDraw_Timing]

AS

BEGIN
Declare @qr_code varchar(80)
Declare @From_winningDateTime varchar(20) 
Declare @To_winningDateTime varchar(20) 
Declare @From_winningTiming varchar(10)
Declare @current_date datetime

DECLARE @To_winningTiming varchar(10)
set @To_winningTiming = '17:00:00'


Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output 



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

set @qr_code = (select top 1 qr_code from agency_qr_code where agency_id =@agency_id order by newid() )

print (@qr_code)
IF (@qr_code is not null and @qr_code !='')
BEGIN
Exec [GET_RANDOM_DATE_TIME] @From_winningTiming output

--print (@From_winningTiming)

--Print ( concat ( Cast (@current_date as date),' ',@From_winningTiming))

set @From_winningDateTime = concat ( Cast (@current_date as date),' ',@From_winningTiming)

set @to_winningDateTime = concat ( Cast (@current_date as date),' ',@To_winningTiming)

set @From_winningDateTime = LEFT(@From_winningDateTime, LEN(@From_winningDateTime) - 2)


IF Not Exists (select 1 from agency_game_winner_timing where  qr_code in
 (select qr_code from agency_qr_code where agency_id =@agency_id) and cast (created_at as date ) = cast (@current_date as date ))
BEGIN

insert into agency_game_winner_timing (selected_date,time_from,time_to,created_at,updated_at,date_status,qr_code)
values(Cast(@current_date as date),CAST(@From_winningDateTime as datetime), CAST(@to_winningDateTime as datetime),@current_date,@current_date,1,@qr_code)

END

END



      FETCH NEXT FROM @MyCursor 
      INTO @agency_id 
    END; 

    CLOSE @MyCursor ;
    DEALLOCATE @MyCursor;
END;


END



--select * from agency_game_winner_timing