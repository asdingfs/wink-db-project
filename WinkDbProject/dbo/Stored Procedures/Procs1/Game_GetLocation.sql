﻿
CREATE PROC [dbo].[Game_GetLocation]

AS 

BEGIN
	SELECT * FROM GAME_LOCATION ORDER BY LOCATION_ID ASC
END
