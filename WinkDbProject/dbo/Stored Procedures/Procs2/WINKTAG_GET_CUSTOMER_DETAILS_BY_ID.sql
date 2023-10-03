
CREATE PROCEDURE [dbo].[WINKTAG_GET_CUSTOMER_DETAILS_BY_ID]
(
	@customer_id int
)
	
AS
BEGIN
	SELECT (first_name + ' ' + last_name) AS customer_name
	, email
	, phone_no 
	FROM customer
	WHERE customer_id = @customer_id
	;
END
