
CREATE PROC [dbo].[GET_REFERRAL]
(@event_name varchar(50))
AS
BEGIN

IF(@event_name is null or @event_name ='')
 set @event_name = Null

	SELECT SENDER_ID as id, EMAIL AS SENDER_EMAIL,event_name,ROW_NUMBER() OVER (Order by SENDER_ID) AS SENDER_ID,customer_id,
	(SELECT REFERRAL_EMAIL1 FROM
		(
			SELECT referral_receiver.sender_id  ,('REFERRAL_EMAIL' + CAST(ROW_NUMBER() OVER(PARTITION BY referral_receiver.sender_id ORDER BY REFERRAL_EMAIL) AS VARCHAR(50))) AS REFERRAL_EMAIL_TITLE,REFERRAL_EMAIL
			FROM referral_receiver where referral_receiver.sender_id = referral_sender.sender_id	  
		) AS T
		PIVOT (MAX(REFERRAL_EMAIL) FOR REFERRAL_EMAIL_TITLE IN (REFERRAL_EMAIL1, REFERRAL_EMAIL2, REFERRAL_EMAIL3)) AS T2) as REFERRAL_EMAIL1,
				
	(SELECT REFERRAL_EMAIL2 FROM
		(
			SELECT referral_receiver.sender_id  ,('REFERRAL_EMAIL' + CAST(ROW_NUMBER() OVER(PARTITION BY referral_receiver.sender_id ORDER BY REFERRAL_EMAIL) AS VARCHAR(50))) AS REFERRAL_EMAIL_TITLE,REFERRAL_EMAIL
			FROM referral_receiver where referral_receiver.sender_id = referral_sender.sender_id	  
		) AS T
		PIVOT (MAX(REFERRAL_EMAIL) FOR REFERRAL_EMAIL_TITLE IN (REFERRAL_EMAIL1, REFERRAL_EMAIL2, REFERRAL_EMAIL3)) AS T2) as REFERRAL_EMAIL2,

(SELECT REFERRAL_EMAIL3 FROM
	(
		SELECT referral_receiver.sender_id  ,('REFERRAL_EMAIL' + CAST(ROW_NUMBER() OVER(PARTITION BY referral_receiver.sender_id ORDER BY REFERRAL_EMAIL) AS VARCHAR(50))) AS REFERRAL_EMAIL_TITLE,REFERRAL_EMAIL
		FROM referral_receiver where referral_receiver.sender_id = referral_sender.sender_id	  
	) AS T
	PIVOT (MAX(REFERRAL_EMAIL) FOR REFERRAL_EMAIL_TITLE IN (REFERRAL_EMAIL1, REFERRAL_EMAIL2, REFERRAL_EMAIL3)) AS T2) as REFERRAL_EMAIL3,

	created_at


	FROM referral_sender
	where (@event_name is null Or event_name like '%'+@event_name+'%')
	order by referral_sender.sender_id desc
	
	
	
END


