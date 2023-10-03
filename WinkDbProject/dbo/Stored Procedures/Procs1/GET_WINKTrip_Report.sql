

CREATE Procedure [dbo].[GET_WINKTrip_Report]
(
  @campaignName varchar(250),
  @from_date datetime,
  @to_date datetime,
  @customer_id varchar(10),
  @email varchar(50),
  @gender varchar(200),
  @wid varchar(30),
  @customer_name varchar(50),
  @tran_type varchar(10),
  @can_id varchar(30),
  @points_credit_status varchar(10),
  @points_expired_status varchar(10)
)
AS
BEGIN

	DECLARE @points_expired_interval int = 24

	DECLARE @current_date datetime
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

	SET arithabort on

	IF(@from_date ='' OR @to_date ='')
	BEGIN
		SET @from_date= NULL;
		SET @to_date = NULL;
	END

	IF(@email ='' or @email =NULL)
	BEGIN
		SET @email= NULL;
	END

	IF(@wid='' or @wid = NULL)
	BEGIN
		SET @wid= NULL;
	END

	IF(@tran_type ='' or @tran_type =NULL)
	BEGIN
		SET @tran_type= NULL;
	END


	IF(@points_credit_status ='' or @points_credit_status =NULL)
	BEGIN
		SET @points_credit_status= NULL;
	END

	IF(@customer_name ='' or @customer_name =NULL)
	BEGIN
		SET @customer_name= NULL;
	END

	IF(@customer_id ='' or @customer_id =NULL)
	BEGIN
		SET @customer_id= NULL;
	END

	IF(@can_id ='' or @can_id = NULL)
	BEGIN
		SET @can_id= NULL;
	END

	IF(@points_expired_status ='' or @points_expired_status =NULL)
	BEGIN
		SET @points_expired_status= NULL;
	END
	IF (@campaignName = '' or @campaignName = NULL)
	BEGIN
		SET @campaignName = NULL;
	END
	IF(@gender='' or @gender = NULL)
	BEGIN
		SET @gender= NULL;
	END

	;WITH trip AS 
	(select A.business_date,A.total_tabs,A.total_points,A.created_at,A.customer_id,A.card_type,A.points_credit_status,A.point_redemption_date,
		A.trans_amount,A.updated_at,A.gps_location,A.points_expired_status,A.can_id as can_id, A.campaign_id
		from nonstop_net_canid_earned_points AS A ,customer as D  
	 where  cast (A.business_date as date) >=  cast (@from_date as date)
		and cast (A.business_date as date) <=  cast (@to_date as date) 
		and (@wid is null or D.WID like '%'+@wid +'%')
		and (@customer_id is null or A.customer_id = @customer_id )
		AND (@can_id IS NULL or A.can_id like '%'+@can_id+'%')
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
		AND (@gender IS NULL or D.gender = @gender)
	 )

	select ROW_NUMBER() OVER(ORDER BY A.updated_at ASC) AS row_no, A.business_date,A.can_id,B.card_type,C.email,A.customer_id,A.total_points,A.gps_location,A.trans_amount,

	 C.email,A.points_expired_status,A.trans_amount,

	(C.first_name+' '+ C.last_name) as customer_name ,C.gender, (select floor(datediff(day,C.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
	A.created_at,(select dateadd(hh, @points_expired_interval, A.created_at)) as points_expired_on,A.points_credit_status, A.point_redemption_date
	,  C.WID, campaign.campaign_name
	 from trip as A 
	join 
	 customer as C
	On A.customer_id = C.customer_id
	and (@email is null or C.email like '%'+ @email +'%')
	and (@customer_name is null or (c.first_name + ' ' + c.last_name) like @customer_name + '%')
	Join nonstop_card_type as B
	on B.card_code = A.card_type
	and (  B.card_code = @tran_type)
	LEFT JOIN campaign as campaign
	ON A.campaign_id = campaign.campaign_id
	WHERE (@campaignName IS NULL OR (campaign.campaign_name like '%'+@campaignName+'%'))
	order by A.updated_at desc


END