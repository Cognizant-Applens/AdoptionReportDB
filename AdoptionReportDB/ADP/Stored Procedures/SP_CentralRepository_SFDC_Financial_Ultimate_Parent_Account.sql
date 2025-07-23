  
-- =================================================================    
-- Author:  <MEENU SHREE>    
-- Description: <Updating SFDC ParentAccount details>    
    
-- =================================================================    
    
CREATE PROCEDURE [ADP].[SP_CentralRepository_SFDC_Financial_Ultimate_Parent_Account] 
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN
        
        IF EXISTS (SELECT TOP 1 1 FROM [AVMCOEESA].[dbo].[RHMSParentCustomer])
        BEGIN
            MERGE [Adp].[CentralRepository_SFDC_Financial_Ultimate_Parent_Account] AS PA
            USING [AVMCOEESA].[dbo].[RHMSParentCustomer] AS CP WITH (NOLOCK)
            ON PA.[Financial_Ultimate_Customer_Id__C] = CP.[Financial_Ultimate_Customer_Id__C]
            WHEN MATCHED THEN
                UPDATE SET 
                    PA.[Name] = CP.[Name], 
                    PA.[LastUpdatedDatetime] = CP.[LastUpdatedDatetime], 
                    PA.[Createddate] = GETDATE(),
                    PA.[Created by] = 'System'
            WHEN NOT MATCHED THEN 
                INSERT ([Financial_Ultimate_Customer_Id__C], [Name], [LastUpdatedDateTime], [Createddate], [Created by]) 
                VALUES (CP.[Financial_Ultimate_Customer_Id__C], CP.[Name], CP.[LastUpdatedDateTime], GETDATE(), 'System');
        END
        
        COMMIT TRAN
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;

        DECLARE @ErrorMessage NVARCHAR(4000);        
  DECLARE @ErrorSeverity INT;        
  DECLARE @ErrorState  INT;      
  DECLARE @MailSubject VARCHAR(MAX);      
  DECLARE @MailBody  VARCHAR(MAX);    
    
  SELECT @ErrorMessage = ERROR_MESSAGE(),        
    @ErrorSeverity = ERROR_SEVERITY(),        
    @ErrorState  = ERROR_STATE();    
        EXEC AppVisionLens.[dbo].AVL_InsertError '[Adp].[SP_CentralRepository_SFDC_Financial_Ultimate_Parent_Account]', @ErrorMessage, 0, '';
		SELECT @MailSubject = CONCAT(@@SERVERNAME, ': ADP SFDC ParentAccount Failure Notification')    
    
		SELECT @MailBody = CONCAT('<font color="Black" face="Arial" Size = "2">Team, <br><br>Oops! Error Occurred in AdoptionReport GATEWAY CRS Refresh during the ADP Job Execution!<br>    
       <br>Error: ', @ErrorMessage,    
       '<br><br>Regards,<br>Solution Zone Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')    
    
       DECLARE @recipientsAddress NVARCHAR(4000)='';    
       SET @recipientsAddress = (SELECT ConfigValue FROM AppVisionLens.AVL.AppLensConfig WHERE ConfigName='Mail' AND IsActive=1);
        EXEC [AppVisionLens].[AVL].[SendDBEmail] @To=@recipientsAddress,  
    @From='ApplensSupport@cognizant.com',  
    @Subject =@MailSubject,  
    @Body = @MailBody    
              
 END CATCH    
    
END    
  
