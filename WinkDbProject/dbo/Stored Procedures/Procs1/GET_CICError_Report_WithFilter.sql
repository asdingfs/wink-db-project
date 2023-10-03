﻿CREATE procedure [dbo].[GET_CICError_Report_WithFilter]
(
 @from_date datetime,
 @to_date datetime,
 @can_id varchar(50),
  @file_name varchar(50),
 @action_type varchar(20)

)
AS
BEGIN
	IF(@from_date is not null and @from_date !='' and @to_date is not null and @to_date !='')
	BEGIN
		IF(@can_id is not null and @can_id !='')
		BEGIN
		 Select * from cic_table_log where CAST(created_at as date) between CAST(@from_date as date) and 
		 CAST(@to_date as date) and @can_id = can_id
	     and cic_file_name like @file_name +'%'
		 and action_type like @action_type +'%'
		 order by id desc
		END
		ELSE
		BEGIN
		 Select * from cic_table_log where CAST(created_at as date) between CAST(@from_date as date) and 
		 CAST(@to_date as date) 
		  and cic_file_name like @file_name +'%'
		 and action_type like @action_type+'%'
		  order by id desc
		END
		
	END
	ELSE
	BEGIN
		IF(@can_id is not null and @can_id !='')
		BEGIN
		 Select * from cic_table_log where @can_id = can_id
		  and cic_file_name like @file_name +'%'
		 and action_type like @action_type+'%'
		 order by id desc
		END
		ELSE
		BEGIN
		 Select * from cic_table_log 
		  where cic_file_name like @file_name +'%'
		 and action_type like @action_type+'%'
		 order by id desc
		END
		
	END

END