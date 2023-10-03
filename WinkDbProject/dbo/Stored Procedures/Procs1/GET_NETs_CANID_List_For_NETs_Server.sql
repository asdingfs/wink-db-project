CREATE PROCEDURE [dbo].[GET_NETs_CANID_List_For_NETs_Server]
(
 @request_date datetime
)
AS
BEGIN



Declare @current_date datetime

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

 --- Insert new nets can id into NETs_Sent_CANID_List
 ----- COMMENT TO TEST FOR LV
 /*
 insert into NETs_Sent_CANID_List (nets_can_id , created_date,updated_at)
 select can_id.customer_canid,@current_date ,@current_date from 
 can_id
 where CAST(LEFT(can_id.customer_canid, 4) AS nvarchar) = '1111'
 and LEN(can_id.customer_canid)=16
 and can_id.customer_canid not in (select l.nets_can_id  from NETs_Sent_CANID_List as l)
 
 update NETs_Sent_CANID_List set updated_at = @current_date where sent_status=0


 select * from NETs_Sent_CANID_List where sent_status = 0 
 and cast (updated_at as date ) = cast (@request_date as date)
  */ ------END


   --- FOR LV ONLY
  SELECT can_id.customer_canid AS nets_can_id FROM can_id WHERE  CAST(LEFT(can_id.customer_canid, 4) AS nvarchar) = '1111'
 and LEN(can_id.customer_canid)=16 and can_id.customer_canid IN ('1111700181032528' ,'1111700181032531' , '1111737999216729' , '1111737999217270' , '1111737999217417' , '1111737999218807', '1111737999510060' , '1111737999522497' , '1111737999532414' , '1111737999532718', '1111737999710662' , '1111737999719047' , '1111737999719064' , '1111737999720550', '1111737999739664', '1111737999739681' ,'1111737999739695','1111737999739707','1111737999779227','1111737999779244','1111737999779258','1111737999779261')
 
 
END

 /*select nets_can_id as nets_can_id from NETs_Sent_CANID_List

--update NETs_Sent_CANID_List set updated_at =created_date*/