
CREATE PROC [dbo].[WINKTAG_GET_LUCKY_DRAWS]
(@qrcode VARCHAR(50),
  @status int,
  @Lucky_Draw_name varchar(100),
  @winner_id varchar(100)
)
AS
BEGIN
Declare @winners_id varchar
Declare @Lucky_Drawname varchar
Declare @qr_code varchar
set @qr_code = @qrcode;


		IF(@winner_id is null or @winner_id ='')
		set @winner_id = NULL

		IF(@Lucky_Draw_name is null or @Lucky_Draw_name ='')
		set @Lucky_Draw_name = NULL

		IF(@qrcode is null or @qrcode ='')
		set @qr_code = NULL

			IF(@status is null  )
		set @status = NULL

SELECT * FROM Winktag_Lucky_Draw WHERE Lucky_Draw_Status = 1 --and survey_type !='merchant'
--AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
--AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date)
--AND CAST(@CURRENT_DATETIME as date) >= CAST('2017-07-04' as date) 
--AND CAST(@CURRENT_DATETIME as time) >= '05:30:00'
--AND CAST(@CURRENT_DATETIME as time) >= '00:00:00'
  and (@Lucky_Draw_name is null or Winktag_Lucky_Draw_name like '%'+@Lucky_Draw_name+'%')
  and (@qr_code is null or qr_code_value like '%'+@qr_code+'%')
  and (@status is null or Lucky_Draw_Status =@status)
  and (@winner_id is null or winner_id =@winner_id)
  AND winktag_lucky_draw_id != 11
order by Winktag_Lucky_Draw_id asc;
	 
END