CREATE PROCEDURE GAME_CREATE_NEW_CHECKPOINT_DETAIL
(
@checkpoint_name varchar(250),
@checkpoint_des varchar(1000),
@image1_url varchar(250),
@image2_url varchar(250),
@image3_url varchar(250),
@asset_management_id int,
@qr_code varchar(100),
@booking_id int,
@check_point_no int,
@game_hint_url varchar(1000),
@small_image varchar(250),
@event_id int 


)
AS
BEGIN
DECLARE @current_date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output
IF(@qr_code IS NOT NULL)
BEGIN
	insert into game_checkpoint_detail
	values (@checkpoint_name,
@checkpoint_des ,
@image1_url ,
@image2_url ,
@image3_url ,
@asset_management_id ,
@qr_code ,
@booking_id ,
@check_point_no ,
@current_date,
@current_date,
@game_hint_url ,
@small_image,
@event_id)
END
END
