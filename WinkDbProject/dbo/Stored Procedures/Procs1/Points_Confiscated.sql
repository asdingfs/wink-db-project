
CREATE PROCEDURE  [dbo].[Points_Confiscated] 
(

@customer_id int

)

AS
BEGIN 
DECLARE @current_date datetime
DECLARE @balanced_points int

Declare @agency_points int


EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT


--- Check agency customer 



SET @balanced_points = (SELECT (total_points - used_points) as balance from customer_balance where customer_id = @customer_id ) - ISNULL((select sum([confiscated_points]) from [winkwink].[dbo].[points_confiscated_detail]  where customer_id = @customer_id),0);

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

				    IF EXISTS (select 1 from agency_game_customers where customer_id = @customer_id)
					BEGIN
					set @agency_points = (select sum(points) from customer_earned_points where customer_id = @customer_id 
					and cast (created_at as date) >= cast ('2017-07-24' as date) and cast (created_at as date) <= cast ( '2017-08-25' as date))
										
					update agency_game_customers set total_confiscated_points =  @agency_points where customer_id = @customer_id
					
					END

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

