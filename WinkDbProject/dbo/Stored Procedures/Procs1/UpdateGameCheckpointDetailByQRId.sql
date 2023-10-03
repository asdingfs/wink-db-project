
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateGameCheckpointDetailByQRId]
	(@qr_id int,
	 @checkpoint_name varchar(255),
	 @checkpoint_description varchar(255),
	 @hint_image1 varchar(255),
	 @hint_image2 varchar(255),
	 @full_image varchar(255),
	 @small_image varchar(255),
	 @created_at DateTime,
	 @updated_at DateTime	)
	
AS
BEGIN
	
		 
		UPDATE game_checkpoint_detail SET 
		checkpoint_name =@checkpoint_name,
		checkpoint_description =@checkpoint_description,
		hint_image1=@hint_image1,
		hint_image2=@hint_image2,
		full_image =@full_image,
		small_image=@small_image,
		created_at=@created_at,
		updated_at=@updated_at
		WHERE id= @qr_id
	
		IF(@@ROWCOUNT>0)
		BEGIN 
			SELECT '1' as response_code, 'Success' as response_message 
			RETURN
		END
		
		ELSE
		BEGIN
		SELECT '0' as response_code, 'Error in Game Check point Detail' as response_message 
			RETURN
		
		END
		
	END
	
	

