CREATE PROCEDURE [dbo].[Remark_Customer_Read_News]
	(
	 @token_id varchar(100),
	 @success int output
	 )
AS
BEGIN
    Declare @current_datetime datetime
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime Output
    Declare @email varchar(100)
    Declare @customer_id int
    Declare @news_id int
    set @success =0
    
    IF (@token_id !='' and @token_id IS NOT NULL)
    BEGIN
    set @customer_id = (select customer_id from customer where auth_token = @token_id)
    
    set @news_id = (select Max(id) from wink_news where wink_news.news_status =1)
    IF NOT Exists (select 1 from customer_read_news where customer_id = @customer_id and news_id =@news_id)
    BEGIN
    insert into customer_read_news(news_id,customer_id,created_at)
    values (@news_id,@customer_id,GETDATE())
    
    if(@@ERROR=0)
    set @success = 1
    else 
    set @success = 0
    END
    
    
    END
END




