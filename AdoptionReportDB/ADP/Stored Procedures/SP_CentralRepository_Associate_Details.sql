
-- =================================================================  
-- Author:  <MEENU SHREE>  
-- Description: <Updating Associate_Details details>  
  
-- =================================================================  
  
  
---- PROCEDURE  
  
CREATE   PROCEDURE [ADP].[SP_CentralRepository_Associate_Details]  
  
AS  
  
BEGIN  
  
 BEGIN TRY  
  
  BEGIN TRAN  
  
IF EXISTS ( SELECT TOP 1 1 FROM [AVMCOEESA].[dbo].[GMSPMO_Associate])  
                                                           
BEGIN  
  
TRUNCATE TABLE [Adp].[CentralRepository_Associate_Details]  
INSERT INTO [Adp].[CentralRepository_Associate_Details] (  
  
  
[Associate_ID],  
[JobCode],  
[Dept_Name],  
[Designation],  
[Createddate],  
[Created by]  
  
  
)  
  
SELECT Distinct  
  
[Associate_ID],  
[JobCode],  
[Dept_Name],  
[Designation],  
Getdate(),  
'System'  
  
       
 from [AVMCOEESA].[dbo].[GMSPMO_Associate]   
  
  
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
  
  EXEC AppVisionLens.[dbo].AVL_InsertError '[Adp].[SP_CentralRepository_Associate_Details]', @ErrorMessage, 0 ,''    
  
      
  SELECT @MailSubject = CONCAT(@@SERVERNAME, ': ADP AssociateDetail Failure Notification')  
  
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

