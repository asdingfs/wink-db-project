CREATE PROCEDURE [dbo].[CreateNewBranch]
	(@branch_name varchar(255),
	
	 @merchant_id int,
	 @allowed_device char(10)
	 )
	
AS
BEGIN
DECLARE @branch_code int 
-- GET LOCAL TIME
DECLARE @CURRENT_DATETIME datetimeoffset = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');

EXEC GET_BRANCH_RANDOM_NO @branch_code OUTPUT
WHILE EXISTS(SELECT * FROM branch WHERE branch_code = @branch_code)
			BEGIN
				EXEC GET_BRANCH_RANDOM_NO @branch_code OUTPUT
			END
			INSERT INTO branch (branch_name,branch_code,merchant_id,allowed_device,created_at,updated_at,branch_status)
			VALUES(@branch_name,@branch_code ,@merchant_id,@allowed_device,@CURRENT_DATETIME,@CURRENT_DATETIME, '1')

END
