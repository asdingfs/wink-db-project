CREATE  PROCEDURE [dbo].[Get_All_WINKs_Confiscated_Details]
AS
BEGIN
select [merchant].first_name,[merchant].last_name,[customer].email,
[wink_confiscated_detail].merchant_id,[wink_confiscated_detail].customer_id,
[wink_confiscated_detail].id,[wink_confiscated_detail].created_at,
[wink_confiscated_detail].updated_at, [wink_confiscated_detail].total_winks

FROM [wink_confiscated_detail] 
INNER JOIN [merchant] 
ON [wink_confiscated_detail].merchant_id = [merchant].merchant_id  
INNER JOIN [customer]
ON [wink_confiscated_detail].customer_id = [customer].customer_id
	
	
END




