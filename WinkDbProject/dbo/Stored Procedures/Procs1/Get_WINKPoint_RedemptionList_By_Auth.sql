CREATE procedure [dbo].[Get_WINKPoint_RedemptionList_By_Auth]
(@auth_token varchar(150),
@duration int
)
As
Begin
Declare @customer_id int
DECLARE @CURRENT_DATETIME Datetime ;     
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT

select @customer_id = ISNULL(customer_id,0) from customer where 
customer.auth_token = @auth_token;

-- Without Date Time Filter      
 IF OBJECT_ID('tempdb..#Customer_redeemed_points_temp') IS NOT NULL DROP TABLE #Customer_redeemed_points_temp      
      
 CREATE TABLE #Customer_redeemed_points_temp      
 (   
  customer_id int,
  redeemed_points decimal(10,2),
  created_at datetime,
  redeemed_messsge varchar(50)
        
 )

IF (@customer_id is not null and @customer_id != 0)
BEGIN
	--latest 3 months
	IF(@duration = 3)
	BEGIN
		insert into #Customer_redeemed_points_temp (customer_id ,redeemed_points,created_at,redeemed_messsge)
		select a.customer_id,a.redeemed_points,a.created_at,'Points campaign On ' 
		from winkpoint_promotion_redemption_summary as a 
		where customer_id = @customer_id
		AND (cast(a.created_at as date) BETWEEN cast(DATEADD(month, -3, GETDATE()) as date) and cast(@CURRENT_DATETIME as date));

		insert into #Customer_redeemed_points_temp (customer_id ,redeemed_points,created_at,redeemed_messsge)
		select a.customer_id,a.redeemed_points,a.created_at,'Redeemed WINKs On ' 
		from customer_earned_winks as a 
		where customer_id = @customer_id
		AND (cast(a.created_at as date) BETWEEN cast(DATEADD(month, -3, GETDATE()) as date) and cast(@CURRENT_DATETIME as date));

	END
	ELSE IF(@duration = 30)
	BEGIN
		--last 30 days
		insert into #Customer_redeemed_points_temp (customer_id ,redeemed_points,created_at,redeemed_messsge)
		select a.customer_id,a.redeemed_points,a.created_at,'Points campaign On ' 
		from winkpoint_promotion_redemption_summary as a 
		where customer_id = @customer_id
		AND CONVERT(VARCHAR(10),a.created_at,110) BETWEEN DATEADD(day,-30, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))AND cast(@CURRENT_DATETIME as date);

		insert into #Customer_redeemed_points_temp (customer_id ,redeemed_points,created_at,redeemed_messsge)
		select a.customer_id,a.redeemed_points,a.created_at,'Redeemed WINKs On ' 
		from customer_earned_winks as a 
		where customer_id = @customer_id
		AND CONVERT(VARCHAR(10),a.created_at,110) BETWEEN DATEADD(day,-30, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))AND cast(@CURRENT_DATETIME as date);

	END
	ELSE IF(@duration = 1)
	BEGIN
		--all
		insert into #Customer_redeemed_points_temp (customer_id ,redeemed_points,created_at,redeemed_messsge)
		select a.customer_id,a.redeemed_points,a.created_at,'Points campaign On ' 
		from winkpoint_promotion_redemption_summary as a 
		where customer_id = @customer_id;

		insert into #Customer_redeemed_points_temp (customer_id ,redeemed_points,created_at,redeemed_messsge)
		select a.customer_id,a.redeemed_points,a.created_at,'Redeemed WINKs On ' 
		from customer_earned_winks as a 
		where customer_id = @customer_id
	END

	ELSE IF(@duration = 0)
	BEGIN
		--only this year, for v1
		insert into #Customer_redeemed_points_temp (customer_id ,redeemed_points,created_at,redeemed_messsge)
		select a.customer_id,a.redeemed_points,a.created_at,'Points campaign On ' 
		from winkpoint_promotion_redemption_summary as a 
		where customer_id = @customer_id
		AND Year(CAST(created_at as DATE)) = YEAR(GETDATE());

		insert into #Customer_redeemed_points_temp (customer_id ,redeemed_points,created_at,redeemed_messsge)
		select a.customer_id,a.redeemed_points,a.created_at,'Redeemed WINKs On ' 
		from customer_earned_winks as a 
		where customer_id = @customer_id
		AND Year(CAST(created_at as DATE)) = YEAR(GETDATE());

	END

	select * from #Customer_redeemed_points_temp 
	--where Year(CAST(created_at as DATE)) = YEAR(GETDATE())
	order by created_at desc
END
ELSE
BEGIN
 select 0 as success , 'User is not authorised' as response_message, 0 as customer_id
 Return
END


End


