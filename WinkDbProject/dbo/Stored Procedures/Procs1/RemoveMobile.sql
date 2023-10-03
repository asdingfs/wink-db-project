CREATE PROCEDURE [dbo].[RemoveMobile]
(
 @customer_id int

)
AS
BEGIN
UPDATE customer
SET phone_no = ''
WHERE customer_id=@customer_id
END


