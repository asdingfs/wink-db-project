

CREATE Procedure [dbo].[GET_WINKGo_WINKGate_NonStop_Report]
(
  @from_date datetime,
  @to_date datetime,
  @customer_id varchar(10),
  @email varchar(50),
  @wid varchar(30),
  @customer_name varchar(50),
  @points_credit_status varchar(10),
  @points_expired_status varchar(10),
  @campaign_name varchar(250),
  @wink_gate_id varchar(100)
)
AS
BEGIN

--return;

declare @points_expired_interval int = 24,
@tran_type varchar(10)

DECLARE @current_date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

IF(@from_date ='' OR @to_date ='')
BEGIN
set @from_date= NULL
set @to_date = NULL
END

IF(@email ='' or @email =NULL)
BEGIN
set @email= NULL

END

IF(@wid ='' or @wid = NULL)
BEGIN
set @wid = NULL

END

IF (@campaign_name = '' or @campaign_name = NULL)
 set @campaign_name = NULL

IF (@wink_gate_id = '')
 set @wink_gate_id = NULL

set @tran_type ='11'




IF(@points_credit_status ='' or @points_credit_status =NULL)
BEGIN
set @points_credit_status= NULL

END

IF(@customer_name ='' or @customer_name =NULL)
BEGIN
set @customer_name= NULL

END

IF(@customer_id ='' or @customer_id =NULL)
BEGIN
set @customer_id= NULL

END



IF(@points_expired_status ='' or @points_expired_status =NULL)
BEGIN

set @points_expired_status= NULL

END

--- Points expired 'Yes'


--normal 

IF (@from_date is  null OR @to_date is null OR @from_date ='' or @to_date ='')
BEGIN
print ('AA')
	;WITH nonstop AS 
	(select A.business_date,A.total_tabs,A.total_points,A.created_at,A.customer_id,A.points_credit_status,A.point_redemption_date, A.card_type, 
	A.trans_amount,A.updated_at,A.gps_location,A.ip_address,A.points_expired_status,D.WID, c.campaign_name, G.gate_id as wink_gate_id  from nonstop_net_canid_earned_points AS A ,
	wink_gate_booking as B, campaign as C, customer as D, wink_gate_asset as G
	 where
	
	 (A.campaign_id = C.campaign_id)
	
	 and
	 /*(
	 A.created_at is not null or A.created_at !='') 
	 and */
 
	 (@wid is null or D.WID like @wid +'%')
	 and (@customer_id is null or A.customer_id = @customer_id )
	 and (@points_credit_status is null or A.points_credit_status = @points_credit_status)
	 and (@wink_gate_id is null or  G.gate_id like '%' + @wink_gate_id + '%') 
	 and (A.wink_gate_asset_id = B.id) and (b.wink_gate_asset_id = G.id) 
	
	 and (@campaign_name is null or C.campaign_name like '%' + @campaign_name + '%' )
	 /*and (@points_expired_status is null or A.points_expired_status = @points_expired_status)
	 )*/
	 
	 and 
	(
		@points_expired_status is null  
		OR
		CASE WHEN @points_expired_status = '1' THEN (select dateadd(hh, @points_expired_interval, A.created_at))  END <= @current_date and A.points_credit_status = 0
		OR 
		CASE WHEN @points_expired_status = '0' THEN (select dateadd(hh, @points_expired_interval, A.created_at))  END > @current_date
	)
	and (
		A.customer_id = D.customer_id
	)
	)
 

	---- Point Expired is NULL 
	       
		   
			select ROW_NUMBER() OVER(ORDER BY A.updated_at ASC) AS row_no, A.business_date,B.card_type,C.email,A.customer_id,A.total_points,A.gps_location,A.ip_address,A.trans_amount,

			 C.email, A.points_expired_status,A.trans_amount,

			(C.first_name+' '+ C.last_name) as customer_name , A.created_at,(select dateadd(hh, @points_expired_interval, A.created_at)) as points_expired_on,A.points_credit_status,A.point_redemption_date
			, C.WID, A.campaign_name, A.wink_gate_id
			 from nonstop as A 
			join 
			 customer as C
			On A.customer_id = C.customer_id
			and  (@wid is null or C.WID like @wid +'%')
			and (@email is null or C.email like '%'+ @email +'%')
			and (@customer_name is null or (c.first_name + ' ' + c.last_name) like @customer_name + '%')
			Join nonstop_card_type as B
			on B.card_code = A.card_type
			and (   B.card_code = @tran_type)

			

			order by A.updated_at desc
			--select * from nonstop


END

ELSE

BEGIN

print ('ZW')

;WITH nonstop AS 
	(select A.business_date,A.total_tabs,A.total_points,A.created_at,A.customer_id,A.card_type,A.points_credit_status,A.point_redemption_date,
	A.trans_amount,A.updated_at,A.gps_location,A.points_expired_status,A.ip_address,D.WID, C.campaign_name, G.gate_id as wink_gate_id from nonstop_net_canid_earned_points AS A ,
	wink_gate_booking as B, campaign as C, customer as D, wink_gate_asset as G

 where  cast (A.business_date as date) >=  cast (@from_date as date)
	and cast (A.business_date as date) <=  cast (@to_date as date) 
	and (@wid is null or D.WID like @wid +'%')
	and (@customer_id is null or A.customer_id = @customer_id )
	and (@points_credit_status is null or A.points_credit_status = @points_credit_status)
	--and (@points_expired_status is null or A.points_expired_status = @points_expired_status)
	and 
	(
		@points_expired_status is null  
		OR
		CASE WHEN @points_expired_status = '1' THEN (select dateadd(hh, @points_expired_interval, A.created_at))  END <= @current_date and A.points_credit_status = 0
		OR 
		CASE WHEN @points_expired_status = '0' THEN (select dateadd(hh, @points_expired_interval, A.created_at))  END > @current_date
	)
	and A.customer_id = D.customer_id
	and A.campaign_id = C.campaign_id
	 and (@wink_gate_id is null or  G.gate_id like '%' + @wink_gate_id + '%') 
	 and (A.wink_gate_asset_id = B.id) and (b.wink_gate_asset_id = G.id) 
	 and (@campaign_name is null or C.campaign_name like '%' + @campaign_name + '%' )
  )

select ROW_NUMBER() OVER(ORDER BY A.updated_at ASC) AS row_no, A.business_date,B.card_type,C.email,A.customer_id,A.total_points,A.gps_location, A.ip_address, A.trans_amount,

 C.email,A.points_expired_status,A.trans_amount,

(C.first_name+' '+ C.last_name) as customer_name , A.created_at,(select dateadd(hh, @points_expired_interval, A.created_at)) as points_expired_on,A.points_credit_status, A.point_redemption_date
,  C.WID, A.campaign_name, A.wink_gate_id, A.ip_address
 from nonstop as A 
join 
 customer as C
On A.customer_id = C.customer_id
and  (@wid is null or C.WID like @wid +'%')
and (@email is null or C.email like '%'+ @email +'%')
and (@customer_name is null or (c.first_name + ' ' + c.last_name) like @customer_name + '%')
Join nonstop_card_type as B
on B.card_code = A.card_type
and ( B.card_code = @tran_type)
order by A.updated_at desc
END

END