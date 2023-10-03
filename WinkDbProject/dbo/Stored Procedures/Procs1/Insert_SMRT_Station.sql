CREATE PROCEDURE [dbo].[Insert_SMRT_Station]
	
AS
BEGIN
DECLARE @current_date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
INSERT INTO station_new (station_code,station_name,created_at,updated_at)
Select distinct import_station.station_code ,
(Select Top 1 st.station_desc from import_station as st where 
 st.station_code = import_station.station_code)As station_name,
 @current_date,@current_date
from import_station 
where import_station.station_company ='MRT' OR import_station.station_company ='CCL'

	
END
