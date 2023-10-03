CREATE PROC [dbo].[Get_UserProfile_ThirdPartyUnified_v01]
(@customer_uniqe_id VARCHAR(255),
 @thirdparty_request_key VARCHAR(255)
 )
AS

BEGIN 

IF (@thirdparty_request_key = (select secret_key from thirdparty_authentication where merchant_email ='smrtconnect@smrt.com.sg'))
BEGIN

SELECT [customer_id]
      ,[first_name]
      ,[last_name]
      ,[email]
      ,[password]
      ,[gender]
      ,[date_of_birth]
      ,[auth_token]
      ,[created_at]
      ,[updated_at]
      ,[imob_customer_id]
      ,[phone_no]
      ,[status]
      ,[group_id]
      ,[confiscated_wink_status]
      ,[subscribe_status]
      ,[confiscated_points_status]
      ,[sign_in_status]
      ,[customer_password]
      ,[avatar_id]
      ,[avatar_image]
      ,[ip_address]
      ,[ip_scanned]
      ,[skin_name]
      ,[team_id]
      ,[nick_name]
      ,[updated_password_date]
      ,[customer_unique_id]
	  , 1 as success
  FROM [dbo].[customer] where customer.customer_unique_id = @customer_uniqe_id


END
BEGIN

select  0 as success , 'Invalid request key' as response_message

END

	
	
END

--select top 1 * from customer 