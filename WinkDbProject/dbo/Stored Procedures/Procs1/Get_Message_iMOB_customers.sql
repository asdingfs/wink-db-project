CREATE PROC [dbo].[Get_Message_iMOB_customers]
AS

BEGIN
	--SELECT '1' AS success, 'You can use the same iMOB Shop login credentials. There is no need to create a new account. Creation of multiple accounts and scanning of stored images are not allowed.' as response_message
	SELECT '1' AS success, 'Creation of multiple accounts and scanning of stored images are not allowed.' as response_message
	return;
END