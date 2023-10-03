CREATE PROCEDURE [dbo].[CreateNewIndustryAndLinkToMerchantId]
	(@industry_name varchar(255),
	 @industry_image varchar(1000),
	 @merchant_id int,
	 @status bit,
	 @created_at DateTime,
	 @updated_at DateTime
	 
	 )
 
AS
BEGIN
Declare @industry_id int
Declare @already_link_industryId int
INSERT INTO industry
           ([industry_name]
           ,[created_at]
           ,[updated_at]
           ,[status]
           ,[industry_image])
     VALUES
           (@industry_name
           ,@created_at
            ,@updated_at
            ,@status
            ,@industry_image)
 SET @industry_id  =  (SELECT SCOPE_IDENTITY());           
 IF (@@ROWCOUNT>0 AND @merchant_id !=0)
 Begin
  
  Set @already_link_industryId = (Select MI.industry_id from merchant_industry as MI Where MI.merchant_id = @merchant_id);

if (@already_link_industryId IS NOT NULL AND @already_link_industryId !=0)
Begin 
Update merchant_industry Set industry_id = @industry_id where merchant_id = @merchant_id

END
ElSE 
 Begin
 INSERT INTO merchant_industry
           ([merchant_id]
           ,[industry_id])
     VALUES
           (@merchant_id
           ,@industry_id)
 
 End
 
END

END
