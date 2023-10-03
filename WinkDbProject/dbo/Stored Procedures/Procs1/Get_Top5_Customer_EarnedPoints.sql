CREATE PROCEDURE [dbo].[Get_Top5_Customer_EarnedPoints]
	
AS
BEGIN
IF OBJECT_ID('tempdb..#QRScanPoint_Table') IS NOT NULL DROP TABLE #QRScanPoint_Table

	CREATE TABLE #QRScanPoint_Table
(
 total_points int,
 customer_id int


)

/*IF OBJECT_ID('tempdb..#TripPoint_Table') IS NOT NULL DROP TABLE #TripPoint_Table

	CREATE TABLE #TripPoint_Table
(
 trip_points int,
 customer_id int
)*/


Insert into #QRScanPoint_Table
Select Top 5 SUM(customer_earned_points.points)as total_points , customer_earned_points.customer_id from customer_earned_points
Group By  customer_earned_points.customer_id
order by SUM(customer_earned_points.points) desc


/*Insert into #TripPoint_Table
Select Top 5 SUM(ISNULL(wink_canid_earned_points.total_points,0)) , 
wink_canid_earned_points.customer_id from wink_canid_earned_points,#QRScanPoint_Table
WHERE #QRScanPoint_Table.customer_id = wink_canid_earned_points.customer_id
Group By  wink_canid_earned_points.customer_id*/

/*select * from #QRScanPoint_Table*/

Select #QRScanPoint_Table.customer_id,ISNULL(#QRScanPoint_Table.total_points,0)+
ISNULL((Select SUM(ISNULL(wink_canid_earned_points.total_points,0))from wink_canid_earned_points
WHERE #QRScanPoint_Table.customer_id = wink_canid_earned_points.customer_id
Group By  wink_canid_earned_points.customer_id),0) as total_points,
(customer.first_name +' '+customer.last_name)as customer_name from #QRScanPoint_Table,customer
where customer.customer_id = #QRScanPoint_Table.customer_id

END



