
CREATE PROCEDURE  [dbo].[Points_Confiscated_v01] 
(

@customer_id int

)

AS
BEGIN 
DECLARE @current_date datetime
DECLARE @balanced_points int
DECLARE @cic_total_points int

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

SET @balanced_points = (SELECT (total_points - used_points) as balance from customer_balance where customer_id = @customer_id ) - ISNULL((select sum([confiscated_points]) from [winkwink].[dbo].[points_confiscated_detail]  where customer_id = @customer_id),0);

select @cic_total_points = SUM(total_points) from cic_table where 
customer_id =@customer_id
and CAST(cic_table.created_at as date) <= CAST (GETDATE() as date)

INSERT INTO points_confiscated_detail
           (

		   [customer_id]
      	  ,[created_at]
          ,[updated_at]
          ,[confiscated_points]

           )
		   VALUES(

       @customer_id,
	   @current_date,
	   @current_date, 
	   @balanced_points

	 );


 IF ((SELECT @@IDENTITY) > 0)
 BEGIN

      UPDATE customer_balance 
	  SET confiscated_points = (select sum([confiscated_points]) from [winkwink].[dbo].[points_confiscated_detail]  where customer_id = @customer_id)
	  WHERE customer_id = @customer_id

	  IF(@@ROWCOUNT>0)
				BEGIN
					SELECT '1' AS response_code , 'Points confiscation is successful' AS response_message
					RETURN
				END
	  ELSE
	  BEGIN
					SELECT '0' AS response_code , 'Points confiscation is not successful' AS response_message
					RETURN
	  END
	  
END   

	 


    
     
 
END

