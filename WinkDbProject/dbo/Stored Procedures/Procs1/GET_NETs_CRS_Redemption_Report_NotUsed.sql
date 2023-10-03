CREATE Procedure [dbo].[GET_NETs_CRS_Redemption_Report_NotUsed]
(
  @from_date datetime,
  @to_date datetime,
  @customer_id varchar(10),
  @email varchar(50),
  @can_id varchar(30),
  @customer_name varchar(50),
  @nets_terminal_redemption_status varchar(10)
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

		IF(@can_id ='' or @can_id = NULL)
		BEGIN
		set @can_id= NULL

		END


		IF(@customer_name ='' or @customer_name =NULL)
		BEGIN
		set @customer_name= NULL

		END

		IF(@customer_id ='' or @customer_id =NULL)
		BEGIN
		set @customer_id= NULL

		END
		

		SELECT A.customer_id,A.can_id,A.redemption_date,A.cronjob_success_date,
		A.evoucher_amount as balanced_redemption_amount ,A.wink_charges,c.first_name +' '+ C.last_name as customer_name, C.email,
		E.redeemed_winks as balanced_redeemed_winks , F.total_redeemed_winks
		FROM NETs_CANID_Redemption_Record_Detail AS A
		JOIN
		customer_earned_eVouchers as E
		ON A.evoucher_id = E.earned_evoucher_id
		AND E.used_status = 1
		AND (@can_id IS NULL OR A.can_id LIKE @can_id)
		JOIN 
		customer as C
		ON C.customer_id = A.customer_id
		AND (@customer_id IS NULL OR C.customer_id LIKE @customer_id +'%')
		AND (@customer_name IS NULL OR C.first_name LIKE '%'+@customer_name +'%'
		OR C.last_name LIKE '%'+@customer_name +'%')
		AND (@email IS NULL OR C.EMAIL LIKE @email +'%')

		JOIN WINK_Redemption_Detail_With_WINK_Fees AS F
		ON F.evoucher_id = A.evoucher_id
		WHERE (@from_date IS NULL OR (CAST(A.redemption_date AS DATE) >= 
		CAST(@from_date AS DATE) AND 
		CAST(A.redemption_date AS DATE) <= 
		CAST(@to_date AS DATE)))
		
		

END


/*select top 1 * from WINK_Redemption_Detail_With_WINK_Fees

select top 1 * from NETs_CANID_Redemption_Record_Detail order by id desc

select top 1 * from customer_earned_eVouchers*/

