CREATE PROCEDURE [dbo].[Get_ALL_SMRT_Station]
	
AS
BEGIN
	select * from import_station where import_station.station_company ='MRT' OR 
		import_station.station_company ='CCL'
END
