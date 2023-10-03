CREATE  PROCEDURE [dbo].[Get_All_WINKs_Confiscated_Details_Filter]
(
@from_date varchar(20),
@to_date varchar(20)
)
AS
BEGIN

IF(@from_date is null or  @from_date ='' or @to_date is null or @to_date  ='')
BEGIN
select [merchant].first_name,[merchant].last_name,[customer].email,customer.WID,
[wink_confiscated_detail].merchant_id,[wink_confiscated_detail].customer_id, 
[wink_confiscated_detail].id,[wink_confiscated_detail].created_at,
[wink_confiscated_detail].updated_at, [wink_confiscated_detail].total_winks

FROM [wink_confiscated_detail] 
INNER JOIN [merchant] 
ON [wink_confiscated_detail].merchant_id = [merchant].merchant_id  
INNER JOIN [customer]
ON [wink_confiscated_detail].customer_id = [customer].customer_id

order by [wink_confiscated_detail].created_at desc

END

ELSE

BEGIN
select [merchant].first_name,[merchant].last_name,[customer].email,customer.WID,
[wink_confiscated_detail].merchant_id,[wink_confiscated_detail].customer_id,
[wink_confiscated_detail].id,[wink_confiscated_detail].created_at,
[wink_confiscated_detail].updated_at, [wink_confiscated_detail].total_winks

FROM [wink_confiscated_detail] 
INNER JOIN [merchant] 
ON [wink_confiscated_detail].merchant_id = [merchant].merchant_id  
INNER JOIN [customer]
ON [wink_confiscated_detail].customer_id = [customer].customer_id

where CAST ([wink_confiscated_detail].created_at as date) >=CAST (@from_date as date)
and  CAST ([wink_confiscated_detail].created_at as date) <=CAST (@to_date as date)

order by [wink_confiscated_detail].created_at desc


END

	
	
END




