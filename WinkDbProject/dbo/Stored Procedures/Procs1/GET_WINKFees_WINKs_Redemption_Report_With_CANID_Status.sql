CREATE Procedure [dbo].[GET_WINKFees_WINKs_Redemption_Report_With_CANID_Status]
(
  @from_date datetime,
  @to_date datetime,
  @customer_id varchar(10),
  @email varchar(50),
  @customer_name varchar(50),
  @redemption_merchant_name varchar(100),
  @canid varchar(50),
  @status varchar(50)
 )
AS
BEGIN
		IF(@from_date ='' OR @to_date ='')
		BEGIN
		set @from_date= NULL
		set @to_date = NULL
		END

		IF(@email ='' or @email =NULL)
		BEGIN
		set @email= NULL

		END

		IF(@redemption_merchant_name ='' or @redemption_merchant_name = NULL)
		BEGIN
		set @redemption_merchant_name= NULL

		END


		IF(@customer_name ='' or @customer_name =NULL)
		BEGIN
		set @customer_name= NULL

		END

		IF(@customer_id ='' or @customer_id =NULL)
		BEGIN
		set @customer_id= NULL

		END

		IF(@canid ='' or @canid =NULL)
		BEGIN
			set @canid= NULL
		END

		IF(@status ='' or @status =NULL)
		BEGIN
			set @status= NULL
		END
		

		SELECT E.customer_id,CAN.CAN_ID,A.created_at, A.total_redeemed_winks,
		A.balance_redeemed_amount,A.balance_redeemed_winks,A.merchant_id,
		A.total_redeemed_amount,A.wink_fee,A.wink_fee_amount,c.email,
		c.first_name +' '+ C.last_name as customer_name,
		M.first_name+' ' +M.last_name AS merchant_name,
		A.total_redeemed_winks, (CASE WHEN can.cronjob_status = 'sent' or can.cronjob_status = 'pending' THEN 'Pending'
		WHEN can.cronjob_status = 'done' THEN 'Ready' end) as cronjob_status
			
		FROM WINK_Redemption_Detail_With_WINK_Fees AS A
		JOIN
		customer_earned_eVouchers as E
		ON A.evoucher_id = E.earned_evoucher_id
		AND E.used_status = 1 
		
		LEFT JOIN NETs_CANID_Redemption_Record_Detail CAN
		ON CAN.evoucher_id = E.earned_evoucher_id 

		JOIN 
		customer as C
		ON C.customer_id = E.customer_id
		AND (@customer_id IS NULL OR C.customer_id LIKE @customer_id +'%')
		AND (@customer_name IS NULL OR C.first_name LIKE '%'+@customer_name +'%'
		OR C.last_name LIKE '%'+@customer_name +'%')
		AND (@email IS NULL OR C.EMAIL LIKE @email +'%')
		JOIN 
		merchant as M
		ON M.merchant_id = A.merchant_id
		AND (@redemption_merchant_name IS NULL OR 
		M.first_name LIKE '%'+@redemption_merchant_name +'%'
		OR M.last_name LIKE '%'+@redemption_merchant_name +'%')

		WHERE (@from_date IS NULL OR (CAST(A.created_at AS DATE) >= 
		CAST(@from_date AS DATE) AND 
		CAST(A.created_at AS DATE) <= 
		CAST(@to_date AS DATE)))
		and (@canid is null or CAN.can_id = @canid)
		and (@status is null or CAN.cronjob_status = @status or CAN.cronjob_status = (CASE WHEN @status = 'pending' THEN 'sent' end))
	
		order by A.created_at desc
		
END
