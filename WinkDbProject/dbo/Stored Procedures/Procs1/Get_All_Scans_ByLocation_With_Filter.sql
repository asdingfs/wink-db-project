
CREATE  PROC [dbo].[Get_All_Scans_ByLocation_With_Filter]

@start_date varchar(50),
@end_date varchar(50),
@asset_type varchar(100)
AS

BEGIN

	DECLARE @CurrentDate Datetime

	EXEC GET_CURRENT_SINGAPORT_DATETIME @CurrentDate Output


	if(@start_date is null or @start_date ='')
	 set @start_date =	Null

	if(@end_date is null or @end_date ='')
	set @end_date = Null

	if(@asset_type is null or @asset_type ='')
	set @asset_type = Null

	IF (@start_date is null or @end_date is null)
	BEGIN
	
	Select temp1.station_id,temp1.station_name,ISNULL(temp1.total_scans,0) as total_scans,ISNULL(temp2.today_scans,0) as today_scans from 

	(
	Select  top 20 t2.station_id, t2.station_name,count(qr_code) as total_scans
	from asset_type_management as t2 
	left join customer_earned_points as t1
	on t1.qr_code = t2.qr_code_value
	
	where 
	(cast(t1.created_at as date) = cast(@CurrentDate as date)) 
	and 
	(@asset_type is null or t2.station_name like '%'+@asset_type+'%') 
	Group by t2.station_id, t2.station_name order by total_scans desc) as temp1

	LEFT JOIN

	(Select t4.station_id,t4.station_name,count(qr_code) as today_scans
	from asset_type_management as t4
	left join customer_earned_points as t3 
	on t3.qr_code = t4.qr_code_value
	where CAST(@CurrentDate As DATE) = Cast(t3.created_at As Date)
	Group by t4.station_id,t4.station_name, Cast(t3.created_at As Date)) as temp2

	on temp1.station_id = temp2.station_id
	order by total_scans desc

	END

	ELSE
	BEGIN
			Select temp1.station_id,temp1.station_name,ISNULL(temp1.total_scans,0) as total_scans,ISNULL(temp2.today_scans,0) as today_scans from 

			(Select top 20 t2.station_id, t2.station_name,count(qr_code) as total_scans
			from asset_type_management as t2
			left join customer_earned_points as t1
			on t1.qr_code = t2.qr_code_value
			where (((cast(t1.created_at as date) >= cast(@start_date as date)) and (cast(t1.created_at as date) <= cast(@end_date as date))))
			and (@asset_type is null or t2.station_name like '%'+@asset_type+'%') 
			Group by t2.station_id, t2.station_name
			order by total_scans desc) as temp1

			LEFT JOIN

			(Select t4.station_id,t4.station_name,count(qr_code) as today_scans
			from asset_type_management as t4
			left join customer_earned_points as t3
			on t3.qr_code = t4.qr_code_value
			where CAST(@CurrentDate As DATE) = Cast(t3.created_at As Date)
			Group by t4.station_id,t4.station_name, Cast(t3.created_at As Date)) as temp2

			on temp1.station_id = temp2.station_id
			order by total_scans desc

	END
END



