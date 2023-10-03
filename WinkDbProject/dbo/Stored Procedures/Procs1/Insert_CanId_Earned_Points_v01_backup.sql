
CREATE PROCEDURE [dbo].[Insert_CanId_Earned_Points_v01_backup]
	(@can_id varchar (150),
	  @business_date datetime ,
	  @total_tabs int ,
	  @total_points int,
	  @created_at datetime
	)
	  
AS
BEGIN
DECLARE @customer_id  int 
DECLARE @current_date datetime
Declare @NETsPromotionPoints int
Declare @NETPromotionTotal int
Declare @NetPromotionStatus int
DEclare @NETPromotionStartDate datetime

set @NETsPromotionPoints = 0
set @NETPromotionTotal = 30000
set @NetPromotionStatus = 0
set @NETPromotionStartDate ='2018-08-22'

EXEC dbo.GET_CURRENT_SINGAPORT_DATETIME @current_date output

    IF NOT EXISTS (select 1 from wink_canid_earned_points where can_id =@can_id and CAST (business_date as DATE) = CAST (@business_date as DATE))
	BEGIN
	IF EXISTS (select can_id.customer_id from can_id where can_id.customer_canid = @can_id
	and can_id.customer_id IN (select customer.customer_id from customer where customer.status='enable')
	)
		BEGIN
		---1. Insert to canid_earned_points
			set @customer_id = (select can_id.customer_id from can_id where can_id.customer_canid = @can_id)
			INSERT INTO wink_canid_earned_points 
			(can_id,business_date,total_tabs,total_points,created_at,customer_id)
			VALUES (@can_id,@business_date,@total_tabs,@total_points,@created_at,@customer_id)
		END

	IF(@@ROWCOUNT>0)
	BEGIN
	 ---2. Check NETs Promotion
	 IF(cast(@business_date as date) > = cast(@NETPromotionStartDate as date) and @NetPromotionStatus =1)
	 BEGIN
	 print('check NETs step 1 Pass')
	 ---3. Check registered SMRT CAN ID
			 IF EXISTS (select 1 From smrt_can_1 as a where a.can = @can_id)
			 BEGIN
			 print('check NETs step 2 Pass')
				 IF NOT EXISTS (select 1 from wink_net_canid_earned_points where customer_id = @customer_id and 
				 promotion_name ='NETs2017')		 
				 BEGIN
				 print('check NETs step 3 Pass')
				  if((select count(*) from wink_net_canid_earned_points where promotion_name ='NETs2017') < @NETPromotionTotal)
					  BEGIN
					       print('check NETs step 4 Pass')
							 set @NETsPromotionPoints = 50

							 INSERT INTO wink_net_canid_earned_points 
							(can_id,business_date,total_tabs,total_points,created_at,customer_id,promotion_name)
							VALUES (@can_id,@business_date,@total_tabs,@NETsPromotionPoints,@created_at,@customer_id,'NETs2017')
					  END
				 END

			 END
	 END
	 ---4. Calculate the points
			 set @total_points = @total_points + @NETsPromotionPoints
	 ---5. Check customer balance
		 IF EXISTs (select 1 from customer_balance where customer_id = @customer_id)
			 BEGIN
				update customer_balance set total_points +=@total_points where customer_id =@customer_id
			 END
		 ELSE
			 BEGIN
			 insert into customer_balance (customer_id,total_points,total_redeemed_amt)
			 values (@customer_id,@total_points,0.00)
			 END
	END
	
	END
END



--select * from smrt_can_1