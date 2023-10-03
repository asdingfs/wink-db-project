CREATE PROC [dbo].[Get_Assets_List]
	
AS
BEGIN

	select row_number() over(order by (select 0)) as row_no, booked.booking_id,main.asset_type_management_id,main.station_name,main.asset_name,main.asset_code,main.qr_code_value
	,booked.booked_status,ISNULL(campaign.campaign_name,'') AS campaign_name,ISNULL(start_date,'') as start_date,ISNULL(end_date,'') AS end_date
	from asset_type_management main left join 
	(
		--special_assets
		select asset_type_management_id as booking_id, qr_code_value,0 as campaign_id,scan_start_date as start_date,scan_end_date as end_date,created_at,updated_at,'false' as booked_status from asset_type_management where wink_asset_category = 'event'

		union
		
		--booked
		SELECT booking_id,qr_code_value,campaign_id,ISNULL(CONVERT(varchar, start_date),'') as start_date ,ISNULL(CONVERT(varchar, end_date),'') as end_date ,created_at,updated_at,'true' as booked_status FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY qr_code_value ORDER BY end_date desc) AS ROWNUM 
			FROM asset_management_booking
		) x WHERE ROWNUM = 1 AND cast((select today from VW_CURRENT_SG_TIME) as date) between cast(start_date as date) and cast(end_date as date)

		union

		--available
		SELECT asset_type_management_id as booking_id, qr_code_value,campaign_id,'' as start_date,'' as end_date,created_at,updated_at,'false' as booked_status FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY qr_code_value ORDER BY end_date desc) AS ROWNUM 
			FROM asset_management_booking
		) x WHERE ROWNUM = 1 AND cast((select today from VW_CURRENT_SG_TIME) as date) not between cast(start_date as date) and cast(end_date as date)
	) booked 
	on main.qr_code_value = booked.qr_code_value 
	Left JOIN campaign On booked.campaign_id = campaign.campaign_id
	order by main.created_at desc

END
