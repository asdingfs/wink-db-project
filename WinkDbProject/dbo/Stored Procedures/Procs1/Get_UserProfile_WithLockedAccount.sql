CREATE PROCEDURE [dbo].[Get_UserProfile_WithLockedAccount] 
	(@auth_token varchar(150)
	
	 )
AS
BEGIN



IF EXISTS (select 1 from customer where customer.auth_token= @auth_token)
BEGIN
	IF EXISTS (SELECT * FROM customer WHERE auth_token = @auth_token AND status = 'disable')
	BEGIN
		select 2 as success , 'Account locked. Please contact customer service.' as response_message
		Return
	END
	ELSE

	BEGIN
	select 1 as success, c.customer_id,c.first_name,
	c.last_name,c.email,c.date_of_birth,c.gender,phone_no,biometric,
	avatar_id,avatar_image,avatar_name,skin_name,team_name,WID,
	nick_name,subscribe_status,'Valid user' as response_message
	
	 from customer as c 
                             join wink_team as t 
                             on t.team_id = c.team_id 
                              LEFT JOIN 
                              (select avatar.avatar_name,avatar.id from avatar) as v
                             ON c.avatar_id = v.id 
                             Where c.auth_token = @auth_token
		Return
	END


	

END
Else
BEGIN
	select 0 as success , 'Multiple logins not allowed' as response_message
    Return
END

END