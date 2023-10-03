CREATE PROC [dbo].[GET_RANDOM_DATE_TIME]
(
  @randonTime varchar(15) output
)
AS
BEGIN

  
     
	-- I want to get a randome time of day between 12 am and 1:30 am
	DECLARE @startTime Time = '09:00:00'
	DECLARE @endTime TIME = '23:00:00'
	-- Get the number of seconds between these two times
	-- (eg. there are 3600 seconds between 12 AM and 1 AM)
	DECLARE @maxSeconds int = DATEDIFF(ss, @startTime, @endTime)
	-- Get a random number of seconds between 0 and the number of 
	-- seconds between @startTime and @endTime (@maxSeconds)
	DECLARE @randomSeconds int = (@maxSeconds + 1) * RAND(convert(varbinary, newId() )) 
	-- Add the random number of seconds to @startTime and return that random time of day
	--SELECT (convert(Time, DateAdd(second, @randomSeconds, @startTime))) AS RandomTime

	set @randonTime = (convert(Time, DateAdd(second, @randomSeconds, @startTime)))

END
