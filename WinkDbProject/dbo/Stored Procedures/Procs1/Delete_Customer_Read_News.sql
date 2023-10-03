CREATE PROCEDURE [dbo].[Delete_Customer_Read_News]
	(
	 @token_id varchar(100),
	 @news_id varchar(50),
	 @success int output
	 )
AS
BEGIN
    Declare @current_datetime datetime
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime Output
    Declare @email varchar(100)
    Declare @customer_id int
   
    set @success =0
    
    IF (@token_id !='' and @token_id IS NOT NULL)
    BEGIN
    set @customer_id = (select customer_id from customer where auth_token = @token_id)
    
	 insert into customer_delete_news (news_id,customer_id,created_at,updated_at)
	 values (@news_id,@customer_id,@current_datetime,@current_datetime)
    
    
    if(@@ERROR=0)
    set @success = 1
    else 
    set @success = 0
    END
       
    
END

