CREATE PROCEDURE [dbo].[Get_CampaginRedeemedWINKDetail_By_MerchantId]      
 (
  @start_date datetime,      
  @end_date datetime,      
  @customer_name varchar(150),      
  @customer_email varchar(150),
  @status varchar(10),
  @customer_id INT,
  @merchant_id int,
  @campaign_id int,
  @wid varchar(50),
  @campaign_name varchar(50),
  @merchant_name varchar(50),
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
        
     
	Declare @CURRENT_DATETIME Datetime      
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT   


	if(@customer_name is null or @customer_name ='')
	 set @customer_name = NULL

	 if(@customer_email is null or @customer_email ='')
	 set @customer_email = NULL

	 if(@status is null or @status ='')
	 set @status = NULL

	 if(@customer_id is null or @customer_id ='')
		set @customer_id = NULL
	 IF(@wid is null or @wid = '')
	 BEGIN
		SET @wid = null;
	 END
	 if(@merchant_id is null or @merchant_id ='')
	 set @merchant_id = NULL

	  if(@campaign_id is null or @campaign_id ='')
	 set @campaign_id = NULL

	   if(@campaign_name is null or @campaign_name ='')
	 set @campaign_name = NULL

	   if(@merchant_name is null or @merchant_name ='')
	 set @merchant_name = NULL

	IF( @start_date is null or @start_date ='' or @end_date is null or @end_date ='')
	BEGIN
			select c.WID,c.customer_id,(c.first_name+' '+c.last_name) as customer_name,c.email,c.date_of_birth,w.campaign_id,w.redeemed_points,
			w.total_winks,cam.campaign_name,(m.first_name+' '+ m.last_name) as merchant_name,
			w.created_at as redeemed_on,w.merchant_id,
			c.gender,c.status
            ,(CONVERT(int,CONVERT(char(8),@current_datetime,112))-CONVERT(char(8),Cast(c.date_of_birth as date),112))/10000 AS age
			from customer_earned_winks as w 
			join customer as c
	
			on w.customer_id = c.customer_id
		
			and (@customer_name is null or (c.first_name like '%'+@customer_name+'%' or c.last_name like '%'+@customer_name+'%'))
			and (@customer_email is null or (c.email like @customer_email +'%'))
			and (@status is null or (c.status  like '%'+@status +'%'))
			and (@customer_id is null or (c.customer_id  =@customer_id ))
			and (@wid is null or (c.WID like '%'+@wid +'%' ))
			join campaign as cam
			on cam.campaign_id = w.campaign_id
			and (@campaign_name is null or (cam.campaign_name like '%'+@campaign_name+'%'))
			join merchant as m
			on m.merchant_id = cam.merchant_id
			and (@merchant_name is null or (m.first_name like '%'+@merchant_name +'%' or m.last_name like '%'+@merchant_name +'%'))
			and (@merchant_id is null or (m.merchant_id = @merchant_id))
			order by w.created_at desc

	END
	ELSE
	BEGIN
		select c.WID,c.customer_id,(c.first_name+' '+c.last_name) as customer_name,c.email,c.date_of_birth,w.campaign_id,w.redeemed_points,
			w.total_winks,cam.campaign_name,(m.first_name+' '+ m.last_name) as merchant_name,
			w.created_at as redeemed_on,w.merchant_id,
			c.gender,c.status
            ,(CONVERT(int,CONVERT(char(8),@current_datetime,112))-CONVERT(char(8),Cast(c.date_of_birth as date),112))/10000 AS age
			from customer_earned_winks as w 
			join customer as c
	
			on w.customer_id = c.customer_id
			and (cast(w.created_at as date) >= cast(@start_date as date) and 
			cast(w.created_at as date) <= cast(@end_date as date))
			and (@customer_name is null or (c.first_name like '%'+@customer_name+'%' or c.last_name like '%'+@customer_name+'%'))
			and (@customer_email is null or (c.email like @customer_email +'%'))
			and (@status is null or (c.status  like '%'+@status +'%'))
			and (@customer_id is null or (c.customer_id  =@customer_id ))
			and (@wid is null or (c.WID like '%'+@wid +'%' ))
			join campaign as cam
			on cam.campaign_id = w.campaign_id
			and (@campaign_name is null or (cam.campaign_name like '%'+@campaign_name+'%'))
			join merchant as m
			on m.merchant_id = cam.merchant_id
			and (@merchant_name is null or (m.first_name like '%'+@merchant_name +'%' or m.last_name like '%'+@merchant_name +'%'))
			and (@merchant_id is null or (m.merchant_id = @merchant_id))
			order by w.created_at desc
	END
 END




