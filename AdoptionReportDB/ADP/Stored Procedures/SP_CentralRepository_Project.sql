
-- =================================================================  
-- Author:  <MEENU SHREE>  
-- Description: <Updating Project details>  
  
-- =================================================================  
  
  
---- PROCEDURE  
  
  
CREATE   PROCEDURE [ADP].[SP_CentralRepository_Project]  
  
AS  
  
BEGIN  
  
 BEGIN TRY  
  
  BEGIN TRAN  
  
IF EXISTS ( SELECT TOP 1 1 FROM [AVMCOEESA].[dbo].[RHMSProject])  
                                                           
BEGIN  
  
TRUNCATE TABLE [Adp].[CentralRepository_Project]  
  
INSERT INTO [Adp].[CentralRepository_Project] (  
  
[Project_ID] ,  
[Project_Name] ,  
[DeliveryManagerId] ,  
[Project_Owner] ,  
[Customer_ID] ,  
[Createddate],  
[Created by]  
  
)  
  
SELECT Distinct  
  
[Project_ID] ,  
[Project_Name] ,  
[DeliveryManagerId] ,  
[Project_Owner] ,  
[Customer_ID] ,  
Getdate(),  
'System'  
  
       
from [AVMCOEESA].[dbo].[RHMSProject]    
  
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
  
  EXEC AppVisionLens.[dbo].AVL_InsertError '[Adp].[SP_CentralRepository_Project]', @ErrorMessage, 0 ,''    
  
      
  SELECT @MailSubject = CONCAT(@@SERVERNAME, ': ADP Projectdetail Failure Notification')  
  
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
