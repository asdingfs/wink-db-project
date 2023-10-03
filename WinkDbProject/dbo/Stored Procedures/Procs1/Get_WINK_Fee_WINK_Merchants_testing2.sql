CREATE Procedure [dbo].[Get_WINK_Fee_WINK_Merchants_testing2]
(
  @from_date datetime,
  @to_date datetime,
  @customer_id varchar(10),
  @wid varchar(50),
  @email varchar(50),
  @customer_name varchar(50),
  @redemption_merchant_name varchar(100),
  @comm int
 )
AS

BEGIN
Declare @gst8Percent  float;
set @gst8Percent=0.08;
Declare @gst7Percent float;
set @gst7Percent=0.07;

	IF(@from_date ='' OR @to_date ='')
	BEGIN
		SET @from_date= NULL;
		SET @to_date = NULL;
	END

	IF(@email ='' or @email =NULL)
	BEGIN
		SET @email= NULL;
	END

	IF(@redemption_merchant_name ='' or @redemption_merchant_name = NULL)
	BEGIN
		SET @redemption_merchant_name= NULL;
	END

	IF(@customer_name ='' or @customer_name =NULL)
	BEGIN
		SET @customer_name= NULL;
	END

	IF(@customer_id ='' or @customer_id =NULL)
	BEGIN
		SET @customer_id= NULL;
	END

	IF(@wid is null or @wid ='')
	BEGIN
		SET @wid = NULL;
	END
	IF(@comm = 0)
	BEGIN
		SET @comm = NULL;
	END	
	IF (@from_date IS NOT NULL AND @to_date IS NOT NULL AND @from_date!='' AND @to_date !='')

		SELECT E.customer_id,A.created_at, A.wink_fee_amount,
		A.total_redeemed_winks,A.total_redeemed_amount,
		A.balance_redeemed_amount,
		c.email,
		c.first_name +' '+ C.last_name as customer_name,
		C.WID as wid,
		M.first_name+' ' +M.last_name AS merchant_name,
		M.wink_fee_percent as comm,
		--if date is >=13 Oct 2022, use gst 8%
		--if date is < 13 Oct 2022, use gst 7%.
		CASE 
			WHEN(CAST(A.created_at as date) >='2022-10-13')
			THEN (ISNULL(A.wink_fee_amount*@gst8Percent,0))
			WHEN(CAST(A.created_at as date) <'2022-10-13')
			THEN (ISNULL(A.wink_fee_amount*@gst7Percent,0))
			ELSE 0 END
			AS gst
		
		FROM WINK_Redemption_Detail_With_WINK_Fees AS A
		JOIN
		customer_earned_eVouchers as E
		ON A.evoucher_id = E.earned_evoucher_id
		AND E.used_status = 1
		JOIN 
		customer as C
		ON C.customer_id = E.customer_id
		AND (@customer_id IS NULL OR C.customer_id LIKE @customer_id +'%')
		AND (@wid is null or C.wid like '%'+@wid+'%')
		AND (@customer_name IS NULL OR C.first_name LIKE '%'+@customer_name +'%'
		OR C.last_name LIKE '%'+@customer_name +'%')
		AND (@email IS NULL OR C.EMAIL LIKE @email +'%')
		JOIN 
		merchant as M
		ON M.merchant_id = A.merchant_id
		AND (@redemption_merchant_name IS NULL OR 
		M.first_name LIKE '%'+@redemption_merchant_name +'%'
		OR M.last_name LIKE '%'+@redemption_merchant_name +'%')
		AND (@comm is null or M.wink_fee_percent = @comm)

		WHERE (@from_date IS NULL OR 
					(CAST(A.created_at AS DATE) >= CAST(@from_date AS DATE) 
					AND 
					CAST(A.created_at AS DATE) <= CAST(@to_date AS DATE)
					)
				)
		AND A.wink_fees_id = 0
		
		order by A.created_at desc
		
END
