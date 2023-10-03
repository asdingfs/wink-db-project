
CREATE PROCEDURE [dbo].[WINK_Game_Session_Players_List]
	(@campaign_id int,
	 @asset_name varchar(100),
	 @random int
	 )
AS
BEGIN

	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

	declare @sessionId int;

	SELECT TOP(1) @sessionId = id from wink_game_session 
	where asset_name = @asset_name 
	and campaign_id = @campaign_id
	and pin = @random
	and expired_at > @CURRENT_DATETIME
	order by expired_at desc;

	IF(@campaign_id = 165)
	BEGIN
		SELECT x.WID, x.option_id, x.[character] 
		FROM(
			SELECT c.WID, r.option_id, l.[character], ROW_NUMBER() OVER (PARTITION BY r.customer_id ORDER BY r.created_at DESC) rn
			FROM wink_game_customer_result as r
			left join wink_game_customer_log as l
			ON r.customer_id = l.customer_id
			AND l.campaign_id = @campaign_id
			AND cast(l.created_at as date) = cast(@CURRENT_DATETIME as date)
			left join customer as c
			ON r.customer_id = c.customer_id
			WHERE r.campaign_id = @campaign_id
			AND cast(r.created_at as date) = cast(@CURRENT_DATETIME as date)
			AND l.session_id = @sessionId
			AND r.customer_id not in(
			   select sr.customer_id
			   FROM wink_game_customer_result as sr
			   WHERE sr.campaign_id = @campaign_id
				and cast(sr.created_at as date) = cast(@CURRENT_DATETIME as date)
				group by sr.customer_id
				having count(*) = 6
			)
			GROUP BY r.customer_id, r.option_id, l.[character], r.created_at,c.WID
			HAVING count(r.customer_id) < 6
		) x
		WHERE x.rn = 1
	END
END
