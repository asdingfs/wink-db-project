CREATE  PROCEDURE [dbo].[Get_All_WINKs_Confiscated_Details_test]
(
@emails varchar(200)
)
AS
BEGIN

--DECLARE @emails VARCHAR(100) = 'nang004@gmail.com,nnk003@gmail.com';
DECLARE @Xparam XML;
--Convert @ids to XML 
SELECT @Xparam = CAST('<i>' + REPLACE(@emails,',','</i><i>') + '</i>' AS XML)
 
--Query to compare the id against the ids result set by splitting the XML nodes 
--as a result set
--SELECT * FROM table WHERE Id IN (SELECT x.i.value('.','INT') FROM @Xparam.nodes('//i') x(i))
select [merchant].first_name,[merchant].last_name,[customer].email,
[wink_confiscated_detail].merchant_id,[wink_confiscated_detail].customer_id,
[wink_confiscated_detail].id,[wink_confiscated_detail].created_at,
[wink_confiscated_detail].updated_at, [wink_confiscated_detail].total_winks
FROM [wink_confiscated_detail] 
INNER JOIN [merchant] 
ON [wink_confiscated_detail].merchant_id = [merchant].merchant_id  
INNER JOIN [customer]
ON [wink_confiscated_detail].customer_id = [customer].customer_id
where 
customer.email in (SELECT x.i.value('.','varchar(100)') FROM @Xparam.nodes('//i') x(i))
	
	
END




