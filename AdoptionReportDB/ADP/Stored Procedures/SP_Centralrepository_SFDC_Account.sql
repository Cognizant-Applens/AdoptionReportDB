

-- =================================================================  
-- Author:  <MEENU SHREE>  
-- Description: <Updating SFDC account details>  
  
-- =================================================================  
  
---- PROCEDURE  
  
  
CREATE   PROCEDURE [ADP].[SP_Centralrepository_SFDC_Account]  
  
AS  
  
BEGIN  
  
 BEGIN TRY  
  
  BEGIN TRAN  
  
IF EXISTS ( SELECT TOP 1 1 FROM [AVMCOEESA].[dbo].[RHMSAccount])  
          
BEGIN    
  
MERGE  [Adp].[centralrepository_SFDC_Account]  SA  
    using [AVMCOEESA].[dbo].[RHMSAccount] CA (NOLOCK)  
    ON SA.[Peoplesoft_Customer_Id__C] = CA.[Peoplesoft_Customer_Id__C]   
           WHEN matched THEN  
  
 UPDATE SET SA.[Peoplesoft_Customer_Id__C] = CA.[Peoplesoft_Customer_Id__C]  ,  
SA.[Financial_Ultimate_Customer_Id__C] = CA.[Financial_Ultimate_Customer_Id__C] ,  
SA.[LastUpdatedDatetime] = CA.[LastUpdatedDatetime],  
SA.[Createddate] = getdate(),  
SA.[Created by] = 'Sysytem'  
  
WHEN NOT matched THEN   
  
INSERT (  
  
Peoplesoft_Customer_Id__C,  
[Financial_Ultimate_Customer_Id__C],  
[LastUpdatedDateTime],  
[Createddate],  
[Created by])  
  
VALUES (  
  
Peoplesoft_Customer_Id__C,  
[Financial_Ultimate_Customer_Id__C] ,  
[LastUpdatedDateTime],  
Getdate(),  
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
  
EXEC [AppVisionLens].[dbo].AVL_InsertError '[Adp].[SP_Centralrepository_SFDC_Account]', @ErrorMessage, 0 ,''    
  
      
  SELECT @MailSubject = CONCAT(@@SERVERNAME, ': ADP SFDC job Failure Notification')  
  
  SELECT @MailBody = CONCAT('<font color="Black" face="Arial" Size = "2">Team, <br><br>Oops! Error Occurred in AdoptionReport GATEWAY CRS Refresh during the ADP Job Execution!<br>  
       <br>Error: ', @ErrorMessage,  
       '<br><br>Regards,<br>Solution Zone Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')  
  
       DECLARE @recipientsAddress NVARCHAR(4000)='';  
       SET @recipientsAddress = (SELECT ConfigValue FROM [AppVisionLens].AVL.AppLensConfig WHERE ConfigName='Mail' AND IsActive=1);     
       EXEC [AppVisionLens].[AVL].[SendDBEmail] @To=@recipientsAddress,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody
         
        ------------------------------------------------------   
  
 END CATCH  
  
END
