CREATE PROCEDURE [dbo].[Get_RedeemedWINK_By_CampaignId]      
 (
  @start_date datetime,      
  @end_date datetime,      
  @customer_name varchar(150),      
  @customer_email varchar(150),
  @ip_address varchar(50),
  @status varchar(10),
  @customer_id INT,
  @ip_scanned varchar(30),
  @intPage int,
  @intPageSize int
	
  )      
AS      
BEGIN     

    DECLARE @intStartRow int;
    DECLARE @intEndRow int;
    DECLARE @total int
    SET @intStartRow = (@intPage -1) * @intPageSize + 1;
    SET @intEndRow = @intPage * @intPageSize;
    
    print ('@intStartRow')
    print (@intStartRow)
    print  ('@intEndRow')
    print  (@intEndRow)
    
     
	Declare @CURRENT_DATETIME Datetime      
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT   
	DECLARE @auto_status varchar(5)     

	select c.customer_id,(c.first_name+' '+c.last_name) as customer_name,c.email,c.date_of_birth,w.campaign_id,w.redeemed_points,
	w.total_winks,cam.campaign_name,(m.first_name+' '+ m.last_name) as merchant_name,
	w.created_at as redeemed_on
    from customer_earned_winks as w 
	join customer as c
	
	on w.customer_id = c.customer_id
	 join campaign as cam
	on cam.campaign_id = w.campaign_id
	join merchant as m
	on m.merchant_id = cam.merchant_id

 END

 --select * from customer_earned_winks as w



