CREATE PROCEDURE [dbo].[CreateNewDriverBranch]
	(@branch_name varchar(255),
	
	 @merchant_id int,
	-- @allowed_device char(10),
	 @branch_id int out
	 )
	
AS
BEGIN
DECLARE @branch_code int 
--DECLARE @branch_id int
-- GET LOCAL TIME
DECLARE @CURRENT_DATETIME datetimeoffset = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');

EXEC GET_BRANCH_RANDOM_NO @branch_code OUTPUT
WHILE EXISTS(SELECT * FROM branch WHERE branch_code = @branch_code)
			BEGIN
				EXEC GET_BRANCH_RANDOM_NO @branch_code OUTPUT
			END
			INSERT INTO branch (branch_name,branch_code,merchant_id,created_at,updated_at)
			VALUES(@branch_name,@branch_code ,@merchant_id,@CURRENT_DATETIME,@CURRENT_DATETIME)
		
			IF @@ROWCOUNT>0
			SET @branch_id = (Select MAX(branch_id) from branch )

END
