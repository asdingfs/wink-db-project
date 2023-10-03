CREATE PROCEDURE [dbo].GetRandomTimeOfDay
( 
    @timeOfDay int = 0 OUTPUT
    , @maxHour int = 24 -- Upper bound for the hour.
)
AS
BEGIN
    IF @maxHour > 24 OR @maxHour < 1
        RAISERROR ('Choose value between 1 and 12', 16, 1)   
    
    DECLARE @randomHours int
    SELECT @randomHours = 
        (@maxHour - 1) * 
RAND(CAST(CAST(newid() as binary(8)) as INT))
    
    DECLARE @randomMinutes int
    SELECT @randomMinutes = 
        60 * RAND(CAST(CAST(newid() as binary(8)) as INT))
    
    DECLARE @timeOfDayDate DateTime
    SET @timeOfDayDate = '00:00:00'
    
    SET @timeOfDayDate = 
DATEADD(hh, @randomHours, @timeOfDayDate)
    SET @timeOfDayDate = 
DATEADD(mi, @randomMinutes, @timeOfDayDate)
    
    DECLARE @timeAsString varchar(8)
    DECLARE @timeWithoutColons varchar(6)
    
    SET @timeAsString = CONVERT(varchar(8), @timeOfDayDate, 8)
    SET @timeWithoutColons = REPLACE(@timeAsString, ':', '')
    
    SET @timeOfDay = ( CAST(@timeWithoutColons as int) )
END
