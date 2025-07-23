
-- =================================================================  
-- Author:  <MEENU SHREE>  
-- Description: <Updating ActiveAllocations details>  
  
-- =================================================================  
  
  
  
---- PROCEDURE  
  
  
CREATE   PROCEDURE [ADP].[SP_CentralRepository_ActiveAllocations]  
  
AS  
  
BEGIN  
  
BEGIN TRY  
  
  
IF EXISTS ( SELECT  top 1 1 FROM [AVMCOEESA].[dbo].[GMSPMO_Associate] )  
                                                           
BEGIN  
  
TRUNCATE TABLE [Adp].[CentralRepository_ActiveAllocations]  
  
INSERT INTO [Adp].[CentralRepository_ActiveAllocations] (  
  
[Associate_ID],  
[Project_ID],  
[Allocation_Start_Date],  
[Allocation_End_Date],  
[Allocation_Percentage],  
[Location] ,  
[Createddate],  
[Created by],  
[Associate_Billability_Type]  
)  
  
SELECT   
[Associate_ID],  
[Project_ID],  
Assignmentstartdate,  
Assignmentenddate,  
Allocation_Percentage,  
Assignment_Location ,  
Getdate(),  
'System',  
[Associate_Billability_Type]  
from [AVMCOEESA].[dbo].[GMSPMO_Associate] WHERE Assignment_Status='A'  
  
END  
  
  
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
      
EXEC AppVisionLens.[dbo].AVL_InsertError '[Adp].[SP_CentralRepository_ActiveAllocations]', @ErrorMessage, 0 ,''    
  
  SELECT @MailSubject = CONCAT(@@SERVERNAME, ': ADP ActiveAllocations Failure Notification')  
  
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


