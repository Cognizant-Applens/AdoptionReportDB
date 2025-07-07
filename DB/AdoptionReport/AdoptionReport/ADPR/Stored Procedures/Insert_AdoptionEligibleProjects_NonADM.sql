  
CREATE PROCEDURE [ADPR].[Insert_AdoptionEligibleProjects_NonADM]  
  
AS  
  
BEGIN TRY  
  
BEGIN TRANSACTION  
  
--Onboarded Projects  
--SELECT DISTINCT EsaProjectID,OPL.[Project Owner / ESA PM department] AS Department,Project_Owning_Unit INTO #Dept_BU  
--FROM AppVisionLens.AVL.MAS_ProjectMaster PM   
--JOIN AppVisionLens.AVL.PRJ_ConfigurationProgress CP ON PM.ProjectId=CP.ProjectId  
--JOIN AppVisionLens.dbo.OPLMasterData OPL ON PM.EsaProjectId=OPL.Esa_Project_Id  
--WHERE PM.IsDeleted=0 AND CP.ScreenID=4 AND CP.CompletionPercentage=100 AND CP.IsDeleted=0  

SELECT DISTINCT PM.EsaProjectID,OPL.ProjectOwner_ESA_PM_Department AS Department,ProjectOwningUnit INTO #Dept_BU
FROM AppVisionLens.AVL.MAS_ProjectMaster PM 
JOIN AppVisionLens.AVL.PRJ_ConfigurationProgress CP ON PM.ProjectId=CP.ProjectId
JOIN AppVisionLens.dbo.DQR_oplmasterdata OPL ON PM.EsaProjectId=OPL.EsaProjectId
WHERE PM.IsDeleted=0 AND CP.ScreenID=4 AND CP.CompletionPercentage=100 AND CP.IsDeleted=0 

CREATE TABLE #EligibleProjects(  
 [EsaProjectID] [nvarchar](50) NULL,  
 [ReportType] [nvarchar](50) NULL,  
 [PracticeOwner] [nvarchar](50) NULL,  
 [DE_Inscope] [nvarchar](50) NOT NULL,  
 [SBU] [nvarchar](50) NOT NULL,  
 [MARKET] [nvarchar](100) NULL,  
 [MARKET_BU] [nvarchar](100) NULL,  
 [CHILDPROJECT] [nvarchar](50) NULL,  
 [IsDeleted] [bit] NULL,  
 [CreatedBy] [nvarchar](50) NULL,  
 [CreatedDate] [datetime] NULL,  
 [ModifiedBy] [nvarchar](50) NULL,  
 [ModifiedDate] [datetime] NULL  
)  
  
INSERT INTO #EligibleProjects (EsaProjectId,PracticeOwner,DE_InScope,SBU,MARKET,MARKET_BU,ChildProject,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)  
SELECT DISTINCT EsaProjectId,ProjectOwningUnit,'In Scope',ProjectOwningUnit,ProjectOwningUnit,ProjectOwningUnit,NULL,0,'System',GETDATE(),NULL,NULL FROM #Dept_BU WHERE Department LIKE 'AIA%'  
UNION  
SELECT EsaProjectId,ProjectOwningUnit,'In Scope',ProjectOwningUnit,ProjectOwningUnit,ProjectOwningUnit,NULL,0,'System',GETDATE(),NULL,NULL FROM #Dept_BU WHERE Department LIKE 'CDB%'  
UNION  
SELECT EsaProjectId,ProjectOwningUnit,'In Scope',ProjectOwningUnit,ProjectOwningUnit,ProjectOwningUnit,NULL,0,'System',GETDATE(),NULL,NULL FROM #Dept_BU WHERE Department LIKE 'EPS%' OR Department LIKE 'Moment%'  
UNION  
SELECT EsaProjectId,ProjectOwningUnit,'In Scope',ProjectOwningUnit,ProjectOwningUnit,ProjectOwningUnit,NULL,0,'System',GETDATE(),NULL,NULL FROM #Dept_BU WHERE Department LIKE 'IOT%'  
  
--SELECT * FROM #EligibleProjects  
  
--Updating ReportType based on the Department  
UPDATE #EligibleProjects SET ReportType='AIA' WHERE SBU LIKE 'AIA%'  
UPDATE #EligibleProjects SET ReportType='CDB' WHERE SBU LIKE 'CDB%'  
UPDATE #EligibleProjects SET ReportType='EPS' WHERE SBU LIKE 'EPS%' OR SBU LIKE 'Moment%'  
UPDATE #EligibleProjects SET ReportType='IOT' WHERE SBU LIKE 'IOT%'  
  
TRUNCATE TABLE ADPR.NonADM_EligibleProjects  
  
INSERT INTO ADPR.NonADM_EligibleProjects  
SELECT * FROM #EligibleProjects  
  
--Temporary Insert for CDBI Projects  
INSERT INTO ADPR.NonADM_EligibleProjects   
VALUES ('1000154323','CDBI','TECHNOLOGY','In Scope','TECHNOLOGY','TECHNOLOGY','TECHNOLOGY',NULL,0,'436569',GETDATE(),NULL,NULL)  
INSERT INTO ADPR.NonADM_EligibleProjects   
VALUES ('1000267341','CDBI','INSURANCE','In Scope','INSURANCE','INSURANCE','INSURANCE',NULL,0,'436569',GETDATE(),NULL,NULL)  
   
--SELECT * FROM ADPR.NonADM_EligibleProjects  
  
DROP TABLE #Dept_BU  
DROP TABLE #EligibleProjects  
  
COMMIT TRANSACTION  
  
 --Send Success mail notification      
 DECLARE @MailSubject VARCHAR(MAX);          
 DECLARE @MailBody  VARCHAR(MAX);        
           
 SELECT @MailSubject = CONCAT(@@servername, ' - AdoptionReport_InsertEligibleProjectList_NonADM - Job Success Notification')        
 SELECT @MailBody = '<font color="Black" face="Arial" Size = "2">Hi Team,<br><br>Project list for Non-Adm Adoption Compliance Report is refreshed successfully!<br><br>    
      Regards,<br>Solution Zone Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>'         
   
 EXEC [AppVisionLens].[AVL].[SendDBEmail] @To='AVMCoEL1Team@cognizant.com;AVMDARTL2@cognizant.com',  
    @From='ApplensSupport@cognizant.com',  
    @Subject =@MailSubject,  
    @Body = @MailBody        
  
  
END TRY  
  
BEGIN CATCH  
  
ROLLBACK TRANSACTION    
    
DECLARE @ErrorMessage VARCHAR(MAX);               
SELECT @ErrorMessage = ERROR_MESSAGE()               
    
--Send failure mail notification      
DECLARE @MailSubjectFailure VARCHAR(MAX);          
DECLARE @MailBodyFailure  VARCHAR(MAX);        
          
SELECT @MailSubjectFailure = CONCAT(@@servername, ' - AdoptionReport_InsertEligibleProjectList_NonADM - Job Failure Notification')        
SELECT @MailBodyFailure = CONCAT('<font color="Black" face="Arial" Size = "2">Hi Team, <br><br>Oops! Error occurred while refreshing the project list for Non-Adm Adoption Compliance Report!<br>        
       <br>Error: ', @ErrorMessage,        
       '<br><br>Regards,<br>Solution Zone Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')        
  
EXEC [AppVisionLens].[AVL].[SendDBEmail] @To='AVMCoEL1Team@cognizant.com;AVMDARTL2@cognizant.com',  
    @From='ApplensSupport@cognizant.com',  
    @Subject =@MailSubjectFailure,  
    @Body = @MailBodyFailure          
  
END CATCH