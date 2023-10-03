create procedure Create_Online_Partner
(
 @partner_name varchar(200),
 @logo varchar(200),
 @url varchar(250),
 @partner_status varchar(10)

)
As 
BEGIN
    DECLARE @current_date datetime
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

	INSERT INTO [online_partner] (partner_name,logo,url,partner_status,created_at,updated_at)
	VALUES (@partner_name,@logo,@url,@partner_status,@current_date,@current_date)
	If(@@ROWCOUNT>0)
	select 1 as success , 'Successfully created new record' as response_message
	else 
	select 0 as success , 'Fail to create new record' as response_message
END

