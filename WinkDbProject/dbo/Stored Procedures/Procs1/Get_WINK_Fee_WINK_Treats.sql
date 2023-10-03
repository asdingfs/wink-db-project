CREATE Procedure [dbo].[Get_WINK_Fee_WINK_Treats]
(
	@from_date datetime,
	@to_date datetime,
	@customer_id varchar(10),
	@wid varchar(50),
	@email varchar(50),
	@customer_name varchar(50),
	@redemption_merchant_name varchar(100),
	@canId varchar(50),
	@status varchar(50)
 )
AS
BEGIN
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
	IF(@canId ='' or @canId =NULL)
	BEGIN
		set @canId= NULL;
	END

	IF(@status ='' or @status =NULL)
	BEGIN
		set @status= NULL;
	END

	SELECT E.customer_id,A.created_at, A.wink_fee,A.wink_fee_amount,
	A.total_redeemed_winks,A.total_redeemed_amount,
	A.balance_redeemed_amount, 
	D.can_id as canId, 
	(
		CASE 
			WHEN D.cronjob_status = 'sent' OR D.cronjob_status = 'pending' THEN 'Pending'
			WHEN D.cronjob_status = 'done' THEN 'Ready' 
		END
	) AS [status],
	c.email,
	c.first_name +' '+ C.last_name as customer_name,
	C.WID as wid,
	M.first_name+' ' +M.last_name AS merchant_name
			
	FROM WINK_Redemption_Detail_With_WINK_Fees AS A
	JOIN
	customer_earned_eVouchers as E
	ON A.evoucher_id = E.earned_evoucher_id
	AND E.used_status = 1
	JOIN NETs_CANID_Redemption_Record_Detail AS D
	ON A.evoucher_id = D.evoucher_id
	AND (@canId IS NULL OR D.can_id LIKE'%'+@canId +'%')
	and (@status IS NULL OR D.cronjob_status = @status OR D.cronjob_status = (CASE WHEN @status = 'pending' THEN 'sent' END))
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

	WHERE(@from_date IS NULL OR 
			(CAST(A.created_at AS DATE) >= CAST(@from_date AS DATE) 
			AND 
			CAST(A.created_at AS DATE) <= CAST(@to_date AS DATE)
			)
		)
	AND A.wink_fees_id != 0 AND A.wink_fees_id != 1
		
	order by A.created_at desc
		
END
