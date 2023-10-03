CREATE PROCEDURE [dbo].[Get_Can_ID_By_Can_ID]
	(@can_id varchar(50))
AS
BEGIN
	SELECT * FROM can_id WHERE can_id.customer_canid = @can_id
END
