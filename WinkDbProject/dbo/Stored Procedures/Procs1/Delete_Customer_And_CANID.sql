CREATE PROCEDURE [dbo].[Delete_Customer_And_CANID]

(@customer_id int)
	 

AS 


BEGIN TRANSACTION t1;

BEGIN TRY

DECLARE @result table( customer_id int);
DELETE
FROM    can_id
WHERE   customer_id = @customer_id

DELETE
FROM    customer
OUTPUT  DELETED.customer_id INTO @result
WHERE   customer_id = @customer_id



COMMIT TRANSACTION t1;


SELECT * FROM @result;
RETURN
END TRY


BEGIN CATCH

    ROLLBACK TRANSACTION t1;
	
	RETURN
END CATCH;
