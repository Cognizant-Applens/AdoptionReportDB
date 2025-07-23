
-- =================================================================  
-- Author:  <MEENU SHREE>  
-- Description: <Updating Allocation history details>  
  
-- =================================================================  
  
  
  
---- PROCEDURE  
  
  
CREATE   PROCEDURE [ADP].[SP_CentralRepository_Allocation]  
  
AS  
  
BEGIN  
  
 BEGIN TRY  
  
  BEGIN TRAN  
  
IF EXISTS ( SELECT TOP 1 1 FROM [AVMCOEESA].[dbo].[CentralRepository_Allocation])  
                                                           
BEGIN  
  
TRUNCATE TABLE [Adp].[CentralRepository_Allocation]  
  
INSERT INTO [Adp].[CentralRepository_Allocation] (  
[Associate_ID],  
[Project_ID],  
[Allocation_Start_Date],  
[Allocation_End_Date],  
[Allocation_Percentage],  
[Location],  
[LastUpdatedDateTime],  
[Createddate],  
[Created by],  
[ScheduleHR]  
)  
  
SELECT distinct  
[Associate_ID],  
[Project_ID],  
[Allocation_Start_Date],  
[Allocation_End_Date],  
[Allocation_Percentage],  
[Location],  
[LASTUPDDTTM],  
Getdate(),  
'System',  
[ScheduleHR]  
from [AVMCOEESA].[dbo].[CentralRepository_Allocation]  
where [Allocation_End_Date] >= DATEADD(MONTH, -3, GETDATE())   
  
END  
  
  
COMMIT TRAN  
  
 END TRY  
  
 BEGIN CATCH      
  
DECLARE @ErrorMessage NVARCHAR(4000);      
  DECLARE @ErrorSeverity INT;      
  DECLARE @ErrorState  INT;    
  DECLARE @MailSubject VARCHAR(MAX);    
  DECLARE @MailBody  VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE(),      
    @ErrorSeverity = ERROR_SEVERITY(),      
    @ErrorState  = ERROR_STATE();   
  EXEC AppVisionLens.[dbo].AVL_InsertError '[Adp].[SP_CentralRepository_Allocation]', @ErrorMessage, 0 ,''    
      
  SELECT @MailSubject = CONCAT(@@SERVERNAME, ': ADP Allocation History Failure Notification')  
  
  SELECT @MailBody = CONCAT('<font color="Black" face="Arial" Size = "2">Team, <br><br>Oops! Error Occurred in AdoptionReport GATEWAY CRS Refresh during the ADP Job Execution!<br>  
       <br>Error: ', @ErrorMessage,  
       '<br><br>Regards,<br>Solution Zone Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')  
  
       DECLARE @recipientsAddress NVARCHAR(4000)='';  
       SET @recipientsAddress = (SELECT ConfigValue FROM AppVisionLens.AVL.AppLensConfig WHERE ConfigName='Mail' AND IsActive=1);     
       
	EXEC [AppVisionLens].[AVL].[SendDBEmail] @To=@recipientsAddress,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody  
         
        ------------------------------------------------------   
  
 END CATCH  
  
END  

