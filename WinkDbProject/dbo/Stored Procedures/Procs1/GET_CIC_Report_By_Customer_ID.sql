CREATE procedure [dbo].[GET_CIC_Report_By_Customer_ID]
(
 @customer_id int
)
AS
BEGIN
	 Select * from cic_table 
		 as cic,customer as c where 
		 c.customer_id = cic.customer_id and 
		 c.customer_id = @customer_id 
		 order by id desc

END
