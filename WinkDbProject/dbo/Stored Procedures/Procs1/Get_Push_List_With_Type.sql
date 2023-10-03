
CREATE PROCEDURE [dbo].[Get_Push_List_With_Type]
	 (
	 
	  @type varchar(150)
	
	  )
AS
BEGIN


	--- Update on 13/11/2017

	If (@type is null OR @type ='')
	BEGIN
		set @type = NULL
	END

	Select ROW_NUMBER() OVER (Order by created_on ASC)AS id, notification_title, notification_message,type,
	img_url,created_on 
	from push_notification 
	where (@type is null OR push_notification.type like @type + '%')
	Order By push_notification.id DESC
END





