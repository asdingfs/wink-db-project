CREATE PROCEDURE [dbo].[Update_Customer_By_CustomerId_With_Status_Confiscate]
	(@customer_id varchar(100),
	 @first_name varchar(50),
	 @last_name varchar(50),
	 @email varchar(50),
	 @date_of_birth date,
	 @password varchar(100),
	 @gender varchar(10),
	 @updated_at datetime,
	 @can_id1 varchar(50),
	 @can_id2 varchar(50),
	 @can_id3 varchar(50),
	 @can_id1_key varchar(50),
	 @can_id2_key varchar(50),
	 @can_id3_key varchar(50),
	 @status varchar(50),
	 @group_id varchar(10),
	 @confiscate_status varchar(10)
	 )
AS
BEGIN
DECLARE @intErrorCode INT
DECLARE @existingEmail int
DECLARE @sql1 varchar(1000)

IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result

	CREATE TABLE #result
	(
	 response_code varchar(10),
	 response_message varchar(500)
	
	)

BEGIN TRY
insert into #result
  EXEC Update_Customer_By_CustomerId_With_Status @customer_id ,
	 @first_name ,
	 @last_name ,
	 @email,
	 @date_of_birth,
	 @password ,
	 @gender ,
	 @updated_at,
	 @can_id1 ,
	 @can_id2 ,
	 @can_id3,
	 @can_id1_key,
	 @can_id2_key,
	 @can_id3_key,
	 @status,
	 @group_id
	

	 IF @confiscate_status =1
		BEGIN
			--insert into #result
			EXEC WINK_Confiscated @customer_id 
	 
	 
		END

Select * from #result
END TRY
BEGIN CATCH
Select '0' as success , @@ERROR as response_message
END CATCH




	
	
END


