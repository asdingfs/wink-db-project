
CREATE PROCEDURE [dbo].[Insert_timer_test_log]
	  
AS
BEGIN
DECLARE @current_date datetime
Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

insert into timer_test_log(created_at) values(@current_date)

select 1 as response_code ,'succeed insert log'  as response_message
END

