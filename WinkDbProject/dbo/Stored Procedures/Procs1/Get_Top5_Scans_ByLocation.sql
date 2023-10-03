﻿CREATE  PROCEDURE [dbo].[Get_Top5_Scans_ByLocation]
AS
BEGIN
DECLARE @CurrentDate Datetime

	EXEC GET_CURRENT_SINGAPORT_DATETIME @CurrentDate Output
	--set @CurrentDate = '2021-02-10'
	Select top 5 t2.station_id, t2.station_name, ISNULL(count(*),0) as total_scans,
	ISNULL(count(*),0) as today_scans
	/*
	ISNULL((
	 Select  count(*) 
	
	 from customer_earned_points as t3
	 left join asset_type_management as t4 
	 on t3.qr_code = t4.qr_code_value
	 Where t4.station_id = t2.station_id
	 and CAST(@CurrentDate As DATE) = Cast(t3.created_at As Date)
		
	 Group by Cast(t3.created_at As Date)
	),0) as today_scans
	*/
	 from customer_earned_points as t1 

	 left join asset_type_management as t2 
	 on t1.qr_code = t2.qr_code_value
	where t2.station_id is not null
	and CAST(@CurrentDate As DATE) = Cast(t1.created_at As Date)
	
	Group by t2.station_id, t2.station_name order by total_scans desc
	
	
END

