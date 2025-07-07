-- =================================================================
-- Author:		<MEENU SHREE>
-- Description:	<Updating Holiday details>

-- =================================================================


---- PROCEDURE


CREATE PROCEDURE [ADP].[SP_CentralRepository_HolidayDate]

AS

BEGIN

	BEGIN TRY

		BEGIN TRAN

IF EXISTS ( SELECT TOP 1 1 FROM [$(GateWayServerName)].[$(AVMCOEESA)].[dbo].[HolidayDetails])
                                                         
BEGIN


TRUNCATE TABLE [ADP].[CentralRepository_HolidayDate]

INSERT INTO [ADP].[CentralRepository_HolidayDate]
(

[HOLIDAY],
[LOCATION],
[Createddate],
[Created by])

SELECT DISTINCT
[HOLIDAY],
[LOCATION],
getdate(),
'Sysytem' 

FROM [$(GateWayServerName)].[$(AVMCOEESA)].[dbo].[HolidayDetails]

END

COMMIT TRAN

	END TRY

	BEGIN CATCH    

DECLARE @ErrorMessage	NVARCHAR(4000);    
		DECLARE @ErrorSeverity	INT;    
		DECLARE @ErrorState		INT;  
		DECLARE @MailSubject	VARCHAR(MAX);		
		DECLARE @MailBody		VARCHAR(MAX);

		SELECT	@ErrorMessage	= ERROR_MESSAGE(),    
				@ErrorSeverity	= ERROR_SEVERITY(),    
				@ErrorState		= ERROR_STATE(); 
				
		EXEC [$(AppVisionLens)].[dbo].AVL_InsertError '[Adp].[SP_CentralRepository_HolidayDate]', @ErrorMessage, 0 ,'' 
				
		SELECT @MailSubject = CONCAT(@@SERVERNAME, ': ADP HolidayDetail Failure Notification')

		SELECT @MailBody = CONCAT('<font color="Black" face="Arial" Size = "2">Team, <br><br>Oops! Error Occurred in AdoptionReport GATEWAY CRS Refresh during the ADP Job Execution!<br>
				   <br>Error: ', @ErrorMessage,
				   '<br><br>Regards,<br>Applens Support Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')

				   DECLARE @recipientsAddress NVARCHAR(4000)='';
				   SET @recipientsAddress = (SELECT ConfigValue FROM [$(AppVisionLens)].AVL.AppLensConfig WHERE ConfigName='Mail' AND IsActive=1);   
				   EXEC msdb.dbo.sp_send_dbmail @recipients = @recipientsAddress,
				   @profile_name ='ApplensSupport',
				   @subject = @MailSubject,
				   @body = @MailBody,
				   @body_format = 'HTML';  
				   
        ------------------------------------------------------	

	END CATCH

END


