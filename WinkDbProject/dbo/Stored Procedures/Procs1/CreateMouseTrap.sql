
CREATE PROCEDURE [dbo].[CreateMouseTrap]
	(
	
	 @ip_traped varchar(100),
	 @isp_name varchar(100),
	 @from_where varchar (500),
	 @status varchar(100)
	
	)
AS
BEGIN

Declare @current_date datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

select * from wink_customer_block_ip where ip_address = @ip_traped

if(@@ROWCOUNT <= 0)
BEGIN

insert into mousetrap(time_traped , ip_traped , isp_name ,from_where,status)
     values (@current_date,@ip_traped,@isp_name,@from_where,@status)
	
END

END
