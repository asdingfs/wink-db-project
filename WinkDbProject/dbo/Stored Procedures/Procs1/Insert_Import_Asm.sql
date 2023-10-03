CREATE PROCEDURE [dbo].[Insert_Import_Asm]
	(@station_code varchar(100)
	)
AS
BEGIN
DECLARE @current_date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

Insert into asset_type_management_new
 (station_name,asset_code,asset_name,scan_value,scan_interval,created_at,updated_at,station_id,station_code)
select ast.Station,ast.asm_code,ast.asm_name,50,24,@current_date,@current_date,
ISNULL((select station_new.station_id from station_new where ast.Station LIKE station_new.station_name+'%' ),0),
ISNULL((select station_new.station_code from station_new where ast.Station LIKE station_new.station_name+'%'),0)
from ast

select * from asset_type_management_new where station_id =0

select * from station_new where station_name LIKE 'Buona Vista'+'%'

select * from station_new where station_name LIKE 'Choa Chu Kang'+'%'

select * from station_new where station_name LIKE 'Marina Bay'+'%'


update asset_type_management_new set station_id = 64 ,station_code = 'PYL'
where station_name LIKE 'Paya Lebar'+'%'

update asset_type_management_new set station_id = 16 ,station_code = 'BNV'
where station_name LIKE 'Buona Vista'+'%'
update asset_type_management_new set station_id = 19 ,station_code = 'CCK'
where station_name LIKE 'Choa Chu Kang'+'%'
 
 update asset_type_management_new set station_id = 48 ,station_code = 'MRB'
where station_name LIKE 'Marina Bay'+'%'

END
