CREATE   PROCEDURE [ADP].[DailyMainSpringEffortFrmGateway]  
AS  
BEGIN  
 BEGIN TRY   
  DECLARE @JobID INT  
  DECLARE @JobName VARCHAR(50) = 'Adoption-DailyMainSpringEfforts'  
  DECLARE @Failed VARCHAR(10) ='Failed'  
  DECLARE @Success VARCHAR(10) ='Success'  
  DECLARE @Rows int = 0  
  DECLARE @MailSubject NVARCHAR(500);    
  DECLARE @MailBody  NVARCHAR(MAX);      
  DECLARE @MailContent NVARCHAR(500);  
  DECLARE @ScriptName  NVARCHAR(100)  
    
  
  SELECT @JobID = JobID FROM [AppVisionLens].[MAS].JobMaster WHERE JobName =@JobName  
    
  IF EXISTS(SELECT TOP 1 1 FROM [AVMCOEESA].[dbo].[Adp_CTS_AVM_MAS_TIMESHEET_DART_From_MainSPR])  
  BEGIN  
   BEGIN TRANSACTION  
  
   TRUNCATE Table [AdoptionReport].[ADP].CTS_AVM_MAS_TIMESHEET_DART_VIEW  
   
   insert into [AdoptionReport].[ADP].CTS_AVM_MAS_TIMESHEET_DART_VIEW  
   ([Project Name], [ESA ProjectID], [Service Name], Hours, [Submitter ID], [Submitter Name],  
   [Submitted Date], Department, [Job_Code])  
   SELECT [Project Name], [ESA ProjectID], [Service Name], Hours, [Submitter ID],  
   [Submitter Name], [Submitted Date], Department, [Job_Code]  
   FROM [AVMCOEESA].[dbo].[Adp_CTS_AVM_MAS_TIMESHEET_DART_From_MainSPR] WITH (nolock)  
   WHERE ([Submitted Date] >= DATEADD([MONTH], - 2, GETDATE()))  
  
   SET @Rows = @Rows + @@ROWCOUNT;  
  
    IF EXISTS(SELECT TOP 1 1 FROM [AdoptionReport].[ADP].CTS_AVM_MAS_TIMESHEET_DART_VIEW)  
    BEGIN  
      
     INSERT INTO [AppVisionLens].[MAS].JobStatus   
     (JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate,InsertedRecordCount,DeletedRecordCount,UpdatedRecordCount)  
     VALUES(@JobID,GETDATE(),GETDATE(),@Success,GETDATE(),0,'Adoption-DailyMainSpringEfforts-step2',GETDATE(),@Rows,0,0)  
       
     SELECT @MailSubject = CONCAT(@@servername, ':  DailyMainSpringEfforts Job Success Notification')     
    
     SET @MailContent = 'DailyMainSpringEfforts job has been completed successfully.'      
       
     SELECT @MailBody =  [AppVisionLens].[dbo].[fn_FmtEmailBody_Message](@MailContent)  
     
	 EXEC [AppVisionLens].[AVL].[SendDBEmail] @To='Vidhya.Manohar@cognizant.com',
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody   
       
     COMMIT TRANSACTION    
  
   END  
   END  
  ELSE  
   BEGIN  
  
    DECLARE @MailSubject_NoData NVARCHAR(500);    
    DECLARE @MailBody_NoData NVARCHAR(MAX);      
    DECLARE @MailContent_NoData NVARCHAR(500);  
  
    SELECT @MailSubject_NoData = CONCAT(@@servername, ':  DailyMainSpringEfforts Job Notification')     
    
    SET @MailContent_NoData = 'There is no data from [dbo].[Adp_CTS_AVM_MAS_TIMESHEET_DART_From_MainSPR] Table.'  
  
    SELECT @MailBody_NoData =  [AppVisionLens].[dbo].[fn_FmtEmailBody_Message](@MailContent_NoData)  
    
	EXEC [AppVisionLens].[AVL].[SendDBEmail] @To='Vidhya.Manohar@cognizant.com',
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject_NoData,
    @Body = @MailBody_NoData    
     
   END   
  
END TRY    
 BEGIN CATCH   
    
  ROLLBACK TRANSACTION  
   
  INSERT INTO [AppVisionLens].[MAS].JobStatus  
  (JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate,InsertedRecordCount,DeletedRecordCount,UpdatedRecordCount)  
  VALUES(@JobID,GETDATE(),GETDATE(),@Failed,GetDate(),0,'Adoption-DailyMainSpringEfforts-step2',GETDATE(),0,0,0)  
       
  DECLARE @ErrorMessage VARCHAR(MAX);   
   
  SELECT @MailSubject = CONCAT(@@servername, ':  Job Failure Notification')     
  SELECT @ErrorMessage = ERROR_MESSAGE()   
  SET @MailContent = 'Oops! Error Occurred in Adoption-DailyMainSpringEfforts in insertion Execution at Step -2!'  
  SET @ScriptName = 'Adoption-DailyMainSpringEfforts -[ADP].[DailyMainSpringEffortFrmGateway]'  
  SELECT @MailBody =  [AppVisionLens].[dbo].[fn_FormatEmailBody](@ErrorMessage,@MailContent,'E',@ScriptName)  
  
    EXEC [AppVisionLens].[AVL].[SendDBEmail] @To='Vidhya.Manohar@cognizant.com',
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody   
    
 END CATCH    
End
