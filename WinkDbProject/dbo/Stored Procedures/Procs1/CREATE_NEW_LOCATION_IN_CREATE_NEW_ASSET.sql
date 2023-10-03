CREATE PROCEDURE [dbo].[CREATE_NEW_LOCATION_IN_CREATE_NEW_ASSET]
	(@STATION_NAME varchar(150),
	@created_at datetime,
	@STATION_CODE varchar(100)
	)
AS
BEGIN
--DECLARE @STATION_CODE VARCHAR(50)

	IF NOT EXISTS(SELECT * FROM station WHERE LOWER(STATION.station_name) = @STATION_NAME)
		BEGIN
		IF NOT EXISTS (Select 1 from station Where LOWER(STATION.station_code) = @station_code)
	     BEGIN
	     	--SET	@STATION_CODE = (SELECT TOP 1 STATION.station_id FROM station ORDER BY STATION.station_id DESC)
	         INSERT INTO station (station_name,station_code,created_at,updated_at)
	         VALUES (@STATION_NAME,@STATION_CODE,@created_at,@created_at)
	         
	         IF(@@ROWCOUNT>0)
		  BEGIN
		   SELECT STATION.station_id,STATION.station_name,STATION.station_code ,'1' AS response_code
		
		
		   FROM station WHERE station_code =@STATION_CODE
		
		   RETURN
		
		END	
	         ELSE
	         BEGIN
		        SELECT '0' AS response_code,'Error to save' as response_message 
	
	          END
	     
	     END
		
        END
    ELSE
    BEGIN
		SELECT '0' AS response_code , 'Station name already in used' as response_message
		Return
		
		END
		
		
	
		
	
	
END
