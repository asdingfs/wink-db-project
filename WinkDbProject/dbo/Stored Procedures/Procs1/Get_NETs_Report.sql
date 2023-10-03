
CREATE PROCEDURE [dbo].[Get_NETs_Report]
(

  @start_date varchar(50),    
  @end_date varchar(50)  
)
	
AS
BEGIN

DECLARE @TEMP_NETS_REPORT TABLE (
							
							customer_id int NULL,
							total_points decimal(10, 2),
							total_tabs int NULL,
							created_at datetime
							)

IF EXISTS (SELECT * FROM @TEMP_NETS_REPORT)
	BEGIN 
		DELETE FROM @TEMP_NETS_REPORT
	END

IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')    

BEGIN

INSERT INTO @TEMP_NETS_REPORT
				select p.customer_id, sum(total_points) as total_points, sum(total_tabs) as total_tabs, MAX(created_at)
				FROM wink_net_canid_earned_points As p 
				where CAST(p.created_at as DATE)>= CAST(@start_date as DATE)    
				AND CAST(p.created_at as DATE)<= CAST(@end_date as DATE)
				group by p.customer_id
				

SELECT P.customer_id,([customer].first_name + ' ' + [customer].last_name) as customer_name, [customer].email
, p.total_points, p.total_tabs				
				
FROM @TEMP_NETS_REPORT As P, customer

where customer.customer_id = P.customer_id

order by P.created_at desc




END

ELSE

BEGIN

INSERT INTO @TEMP_NETS_REPORT
				select p.customer_id, sum(total_points) as total_points, sum(total_tabs) as total_tabs, MAX(created_at)
				FROM [wink_net_canid_earned_points] As p 
				group by p.customer_id
				

SELECT P.customer_id,([customer].first_name + ' ' + [customer].last_name) as customer_name, [customer].email
, p.total_points, p.total_tabs				
				
FROM @TEMP_NETS_REPORT As P, customer

where customer.customer_id = P.customer_id

order by P.created_at desc



END

END

