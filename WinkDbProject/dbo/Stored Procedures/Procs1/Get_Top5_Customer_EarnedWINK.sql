CREATE PROCEDURE [dbo].[Get_Top5_Customer_EarnedWINK]
	
AS
BEGIN
	-- Campaign REDEEM WINK Purchase Only 
IF OBJECT_ID('tempdb..#EarnedWINK_Table') IS NOT NULL DROP TABLE #EarnedWINK_Table

	CREATE TABLE #EarnedWINK_Table
(
 total_wink int,
 customer_id int


)
Insert into #EarnedWINK_Table
Select top 5 SUM(customer_earned_winks.total_winks) As total_wink , customer_earned_winks.customer_id
From customer_earned_winks 
Group By customer_earned_winks.customer_id
Order By SUM(customer_earned_winks.total_winks) Desc

/*select * from #QRScanPoint_Table*/

Select ISNULL(#EarnedWINK_Table.total_wink,0)AS total_wink,#EarnedWINK_Table.customer_id,(customer.first_name +' '+customer.last_name)as customer_name from customer,#EarnedWINK_Table
where #EarnedWINK_Table.customer_id = customer.customer_id



END
