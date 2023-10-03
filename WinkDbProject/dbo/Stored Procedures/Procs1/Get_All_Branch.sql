CREATE PROCEDURE [dbo].[Get_All_Branch]	
	(@merchant_name varchar(250),
	@branch_name varchar(250),
	@branch_id int,
	@branch_status varchar(250))
AS
BEGIN

	Declare @status varchar(50)
	Declare @name varchar(250)
	Declare @branchName varchar(250)
	SET @status = ''
	SET @name = ''
	SET @branchName = ''
	

	IF (@merchant_name IS NOT NULL)
	 BEGIN
	 SET @name = @merchant_name;
	 END

	IF (@branch_status IS NOT NULL)
	BEGIN
		SET @status = @branch_status
	END

	IF (@branch_name IS NOT NULL)
	 BEGIN
	 SET @branchName = @branch_name;
	 END


	  IF (@branch_id = 0)
	 BEGIN
	 SET @branch_id = NULL;
	 END

	

	
	 Select branch.branch_id,branch.branch_name,branch.branch_code,branch.allowed_device,branch.created_at,
            branch.updated_at,branch.merchant_id,branch.branch_status,merchant.first_name,merchant.last_name
            From branch,merchant
           Where branch.merchant_id = merchant.merchant_id
            AND merchant.first_name + ' ' + merchant.last_name Like '%'+ @name +'%'
			--AND (@branch_name IS NULL OR (LTRIM(RTRIM(branch.branch_name)) Like '%'+LTRIM(RTRIM(@branch_name))+'%') )
			AND branch.branch_name like '%'+@branchName+'%'
			AND (@branch_id IS NULL OR (branch.branch_code = @branch_id))
			AND branch.branch_status like '%'+@status+'%'
			Order By branch.branch_id DESC
END
