

CREATE Procedure [dbo].[GET_NETs_Motoring_NonStop_Report_BACKUP_20200415]
(
  @from_date datetime,
  @to_date datetime,
  @customer_id varchar(10),
  @email varchar(50),
  @can_id varchar(30),
  @customer_name varchar(50),
  @tran_type varchar(10),
  @points_credit_status varchar(10),
  @points_expired_status varchar(10)
)
AS
BEGIN

--return;

declare @points_expired_interval int = 24

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

IF(@can_id ='' or @can_id = NULL)
BEGIN
set @can_id= NULL

END

IF(@tran_type ='' or @tran_type =NULL)
BEGIN
set @tran_type= NULL

END
else if(@tran_type like '%Car%')
BEGIN
set @tran_type ='01'
END
else if(@tran_type like '%ERP%')
BEGIN
set @tran_type ='07'
END
else if(@tran_type like '%Cash%')
BEGIN
set @tran_type ='02'
END
else if(@tran_type like '%Nets%')
BEGIN
set @tran_type ='03'
END
else if(@tran_type like '%Shared%')
BEGIN
set @tran_type ='79'
END
else if(@tran_type like '%ATM%')
BEGIN
set @tran_type ='82'
END



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



IF (@from_date is  null OR @to_date is null OR @from_date ='' or @to_date ='')
BEGIN
print ('AA')
	;WITH nonstop AS 
	(select * from nonstop_net_canid_earned_points AS A   
	 where
	 /*(
	 A.created_at is not null or A.created_at !='') 
	 and */
 
	 (@can_id is null or A.can_id like @can_id +'%')
	 and (@customer_id is null or A.customer_id like @customer_id +'%')
	 and (@points_credit_status is null or A.points_credit_status = @points_credit_status)
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

	)
 

	---- Point Expired is NULL 
	       
		   
			select ROW_NUMBER() OVER(ORDER BY A.updated_at ASC) AS row_no, A.business_date,A.can_id,B.card_type,C.email,A.customer_id,A.total_points,A.gps_location,A.trans_amount,

			 C.email, A.points_expired_status,A.trans_amount,

			(C.first_name+' '+ C.last_name) as customer_name , A.created_at,(select dateadd(hh, @points_expired_interval, A.created_at)) as points_expired_on,A.points_credit_status,A.point_redemption_date

			 from nonstop as A 
			join 
			 customer as C
			On A.customer_id = C.customer_id
			and (@email is null or C.email like '%'+ @email +'%')
			and (@customer_name is null or (c.first_name + ' ' + c.last_name) like @customer_name + '%')
			Join nonstop_card_type as B
			on B.card_code = A.card_type
			and ( (@tran_type is null  and A.card_type!='08') or B.card_code = @tran_type)

			order by A.updated_at desc
			--select * from nonstop


END

ELSE

BEGIN

print ('ZW')

;WITH nonstop AS 
(select * from nonstop_net_canid_earned_points AS A where  cast (A.business_date as date) >=  cast (@from_date as date)
	and cast (A.business_date as date) <=  cast (@to_date as date) 
	and (@can_id is null or A.can_id like @can_id +'%')
	and (@customer_id is null or A.customer_id like @customer_id +'%')
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
 )

select ROW_NUMBER() OVER(ORDER BY A.updated_at ASC) AS row_no, A.business_date,A.can_id,B.card_type,C.email,A.customer_id,A.total_points,A.gps_location,A.trans_amount,

 C.email,A.points_expired_status,A.trans_amount,

(C.first_name+' '+ C.last_name) as customer_name , A.created_at,(select dateadd(hh, @points_expired_interval, A.created_at)) as points_expired_on,A.points_credit_status, A.point_redemption_date

 from nonstop as A 
join 
 customer as C
On A.customer_id = C.customer_id
and (@email is null or C.email like '%'+ @email +'%')
and (@customer_name is null or (c.first_name + ' ' + c.last_name) like @customer_name + '%')
Join nonstop_card_type as B
on B.card_code = A.card_type
and ( (@tran_type is null and A.card_type!='08') or B.card_code = @tran_type)
order by A.updated_at desc
END

END



