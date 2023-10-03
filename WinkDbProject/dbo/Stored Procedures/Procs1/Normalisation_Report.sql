CREATE PROC [dbo].[Normalisation_Report]
(
	@wid varchar(50),
	@customerId int,
	@customerName varchar(200),
	@email varchar(200),
	@qrCode varchar(200),
	@targetFromDate varchar(50),
	@targetEndDate varchar(50)
)
AS

BEGIN
	IF(@wid is null or @wid ='')
		SET @wid = NULL;

	IF(@customerId = 0)
		SET @customerId = NULL;

	IF(@customerName is null or @customerName ='')
		SET @customerName = NULL;

	IF(@email is null or @email ='')
		SET @email = NULL;

	IF(@qrCode is null or @qrCode ='')
		SET @qrCode = NULL;

	IF(@targetFromDate is null or @targetFromDate='')
		SET @targetFromDate = NULL;

	IF(@targetEndDate is null or @targetEndDate='')
		SET @targetEndDate = NULL;
	
	SELECT ROW_NUMBER() OVER (Order by dup.createdOn ASC)AS [no], dup.qrCode, dup.duplicateCount, dup.normalisedPoints,
	dup.createdOn, dup.affectedDate, cus.WID
	FROM duplicate_qr_normalisation AS dup
	LEFT JOIN customer AS cus 
	ON dup.customerId = cus.customer_id
	WHERE (@wid is null or cus.WID like '%'+@wid+'%')
	AND (@customerId is null or dup.customerId = @customerId)
	AND (@customerName is null or (cus.first_name +' '+cus.last_name) like '%'+@customerName+'%') 
	AND (@email is null or cus.email like '%'+@email+'%')
	AND (@qrCode is null or dup.qrCode like '%'+@qrCode+'%')
	AND (@targetFromDate is null or 
			(cast(dup.affectedDate AS DATE) between cast(@targetFromDate as DATE) and cast(@targetEndDate as DATE))
		)
	order by [no] desc
	
END



