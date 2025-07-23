

-- =================================================================  
-- Author:  <MEENU SHREE>  
-- Description: <Updating current projectmanager details>  
  
-- =================================================================  
  
  
---- PROCEDURE  
  
  
CREATE   PROCEDURE [ADP].[SP_CentralRepository_Current_ProjectManager]  
  
AS  
  
BEGIN  
  
 BEGIN TRY  
  
  BEGIN TRAN  
  
IF EXISTS ( SELECT TOP 1 1 FROM [AVMCOEESA].[dbo].[RHMSProjectManager])  
                                                           
BEGIN  
  
MERGE  [ADP].[CentralRepository_Current_ProjectManager]  PM  
    using [AVMCOEESA].[dbo].[RHMSProjectManager] CM (NOLOCK)  
    ON PM.[PROJECT_ID] = CM.[PROJECT_ID]   
           WHEN matched THEN  
  
 UPDATE SET PM.[PROJECT_ID] = CM.[PROJECT_ID]  ,  
 PM.[PROJECT_MANAGER]=CM.[PROJECT_MANAGER],  
PM.[LastUpdatedDatetime] = CM.[LastUpdatedDatetime],  
PM.[Createddate] = getdate(),  
PM.[Created by] = 'Sysytem'  
  
WHEN NOT matched THEN   
  
INSERT  (  
  
[PROJECT_ID],  
[PROJECT_MANAGER],  
[LastUpdatedDateTime],  
[Createddate],  
[Created by]  
)  
  
VALUES (  
  
[PROJECT_ID],  
[PROJECT_MANAGER],  
[LastUpdatedDateTime],  
Getdate (),  
'System'  
  
  
);  
  
  
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
EXEC AppVisionLens.[dbo].AVL_InsertError '[Adp].[SP_CentralRepository_Current_ProjectManager]', @ErrorMessage, 0 ,''    
      
  SELECT @MailSubject = CONCAT(@@SERVERNAME, ': ADP PROJECTMANAGER Failure Notification')  
  
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

