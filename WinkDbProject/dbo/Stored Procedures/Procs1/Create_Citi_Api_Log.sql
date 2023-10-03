
CREATE PROC [dbo].[Create_Citi_Api_Log]          
@name VARCHAR(255),                                       
@email VARCHAR(250),
@phone varchar(30),
@applicationStage VARCHAR(250),
@controlFlowId varchar(500),
@application_id varchar(250)                                                                                                                     

AS
BEGIN 

DECLARE @CURRENT_DATETIME datetimeoffset = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');
--DECLARE @created_on_date datetime;

--SET  @created_on_date = convert(datetime, @created_on,20);

 INSERT INTO citi_api_log(name, email, phone,application_id,applicationStage, controlFlowId, created_on) VALUES
					(@name,@email,@phone,@application_id,@applicationStage,@controlFlowId, @CURRENT_DATETIME)


END
