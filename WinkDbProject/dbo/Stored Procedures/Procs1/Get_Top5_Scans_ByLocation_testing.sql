CREATE  PROCEDURE [dbo].[Get_Top5_Scans_ByLocation_testing]
AS
BEGIN
DECLARE @CurrentDate Datetime

EXEC GET_CURRENT_SINGAPORT_DATETIME @CurrentDate Output
 ;with tbl as (
Select top 5 t2.station_id, t2.station_name,count(qr_code) as total_scans
	--(case when CAST(@CurrentDate As DATE) = Cast(t1.created_at As Date) then count(qr_code) else 0 end) AS today_scans
	from asset_type_management as t2 
	left join customer_earned_points as t1
	on t1.qr_code = t2.qr_code_value

	Group by t2.station_id, t2.station_name

	order by total_scans desc

) 

,tbl2 as (

	Select t4.station_id,t4.station_name,count(t3.qr_code) as today_scans
	from asset_type_management as t4 , tbl, customer_earned_points as t3 
	
	where CAST(@CurrentDate As DATE) = Cast(t3.created_at As Date)
	and t4.station_id in (select station_id from tbl)
	 and t3.qr_code = t4.qr_code_value
	Group by t4.station_id,t4.station_name, Cast(t3.created_at As Date)
)

select tbl.station_id, tbl.station_name, tbl.total_scans, ISNULL(tbl2.today_scans,0) as today_scans from  tbl
left join tbl2 
on  tbl.station_id = tbl2.station_id
	/*

	DECLARE @CurrentDate Datetime

	EXEC GET_CURRENT_SINGAPORT_DATETIME @CurrentDate Output
	Select t4.station_id,t4.station_name,count(qr_code) as today_scans
	from asset_type_management as t4
	left join customer_earned_points as t3 
	on t3.qr_code = t4.qr_code_value
	where CAST(@CurrentDate As DATE) = Cast(t3.created_at As Date)
	Group by t4.station_id,t4.station_name, Cast(t3.created_at As Date)
	*/	
	
END