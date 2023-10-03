CREATE PROCEDURE [dbo].[import_net_canid_earned_points]
	(@tableVar as net_canid_earned_points readonly
	)
AS
BEGIN
	insert into wink_net_canid_earned_points(
	
	[can_id] ,
	[business_date] ,
	[total_tabs] ,
	[total_points] ,
	[created_at],
	customer_id )

	select [can_id] ,
	[business_date] ,
	[total_tabs] ,
	[total_points] ,
	[created_at],
	(select can_id.customer_id from can_id
	 where can_id.customer_canid = t.can_id)
	
	 from @tableVar as t
	
	
END

select * from can_id