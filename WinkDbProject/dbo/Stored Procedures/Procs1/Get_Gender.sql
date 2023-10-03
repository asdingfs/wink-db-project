CREATE PROCEDURE [dbo].[Get_Gender]
AS 


BEGIN
 
DECLARE @female int;
DECLARE @male int;
DECLARE @unknown int;
DECLARE @total int;
	
	SELECT @male = Count(*) FROM  customer where gender='male';
	print(@male)
	SELECT @female = Count(*) FROM  customer where gender='female';
	print(@female)
	SELECT @unknown = Count(*) FROM  customer where (gender <>'female' and gender <> 'male');

	SELECT top(1) @total = customer_id FROM customer 
	order by customer_id desc

	select @male as Male, @female as Female, @unknown as Unknown, @total as Total
END 