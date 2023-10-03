﻿CREATE procedure [dbo].[GET_CIC_Report]
(
 @from_date datetime,
 @to_date datetime,
 @can_id varchar(50)

)
AS
BEGIN
	IF(@from_date is not null and @from_date !='' and @to_date is not null and @to_date !='')
	BEGIN
		IF(@can_id is not null and @can_id !='')
		BEGIN
		 Select * from cic_table as cic,customer as c where 
		 c.customer_id = cic.customer_id and 
		 CAST(cic.created_at as date) between CAST(@from_date as date) and 
		 CAST(@to_date as date) and @can_id = cic.can_id
		 
		END
		ELSE
		BEGIN
		 Select * from cic_table as cic,customer as c where 
		 c.customer_id = cic.customer_id and 
		 CAST(cic.created_at as date) between CAST(@from_date as date) and 
		 CAST(@to_date as date) 
		 order by id desc
		END
		
	END
	ELSE
	BEGIN
		IF(@can_id is not null and @can_id !='')
		BEGIN
		  Select * from cic_table as cic,customer as c where 
		 c.customer_id = cic.customer_id and  @can_id = can_id
		 order by id desc
		END
		ELSE
		BEGIN
		 Select * from cic_table 
		 as cic,customer as c where 
		 c.customer_id = cic.customer_id
		 order by id desc
		END
		
	END

END

